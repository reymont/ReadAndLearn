

Centralized System and Docker Logging with ELK Stack | Technology Conversations https://technologyconversations.com/2015/05/18/centralized-system-and-docker-logging-with-elk-stack/

Centralized System and Docker Logging with ELK Stack
23 Replies
With Docker there was not supposed to be a need to store logs in files. We should output information to stdout/stderr and the rest will be taken care by Docker itself. When we need to inspect logs all we are supposed to do is run docker logs [CONTAINER_NAME].

With Docker and ever more popular usage of micro services, number of deployed containers is increasing rapidly. Monitoring logs for each container separately quickly becomes a nightmare. Monitoring few or even ten containers individually is not hard. When that number starts moving towards tens or hundreds, individual logging is unpractical at best. If we add distributed services the situation gets even worst. Not only that we have many containers but they are distributed across many servers.

The solution is to use some kind of centralized logging. Our favourite combination is ELK stack (ElasticSearch, LogStash and Kibana). However, centralized logging with Docker on large-scale was not a trivial thing to do (until version 1.6 was released). We had a couple of solutions but none of them seemed good enough.

We could expose container directory with logs as a volume. From there on we could tell LogStash to monitor that directory and send log entries to ElasticSearch. As an alternative we could use LogStash Forwarder and save a bit on server resources. However, the real problem was that there was not supposed to be a need to store logs in files. With Docker we should output logs only to stdout and the rest was supposed to be taken care of. Besides, exposing volumes is one of my least favourite things to do with Docker. Without any exposed volumes containers are much easier to reason with and move around different servers. This is especially true when a set of servers is treated as a data center and containers are deployed with orchestration tools like Docker Swarm or Kubernetes.

There were other options but they were all hacks, difficult to set up or resource hungry solutions.

Docker Logging Driver

In version 1.6 Docker introduced logging driver feature. While it passed mostly unnoticed, it is a very cool capability and a huge step forward in creating a comprehensive approach to logging in Docker environments.

In addition to the default json-file driver that allows us to see logs with docker logs command, we now have a choice to use syslog as an alternative. If set, it will route container output (stdout and stderr) to syslog. As a third option, it is also possible to completely suppress the writing of container output to file. That might save HD usage when that is of importance but in most cases it is something hardly anyone will need.

In this post we’ll concentrate on syslog and ways to centralize all logs to a single ELK instance.

Docker Centralized Logging

We’ll setup ELK stack, use Docker syslog log driver and, finally, send all log entries to a central location with rsyslog. Both syslog and rsyslog are pre-installed on almost all Linux distributions.

We’ll go through manual steps first. At the end of the article there will be instructions how to set up everything automatically with Ansible. If you are impatient, just jump to the end.

Vagrant

Examples in this article are based on Ubuntu and assume that you have Docker up and running. If that’s the case, please skip this chapter. For those that do not have an easy access to Ubuntu, we prepared a Vagrant VM with all that is required. If you don’t have it already, install VirtualBox and Vagrant. Once everything is set, run following commands:

git clone https://github.com/vfarcic/docker-logging-elk.git
cd docker-logging-elk
vagrant up monitoring
vagrant ssh monitoring
After those commands are executed you should be inside the Ubuntu shell with Docker installed. Now we’re ready to set up ELK.

ElasticSearch

We’ll store all our logs in ElasticSearch database. Since it uses JSON format for storing data, it will be easy to send any type of log structure. More importantly, ElasticSearch is optimized for real-time search and analytics allowing us to navigate through our logs effortlessly.

Let us run the official ElasticSearch container with port 9200 exposed. We’ll use volume to persist DB data to the /data/elasticsearch directory.

sudo mkdir -p /data/elasticsearch
sudo docker run -d --name elasticsearch -p 9200:9200 -v /data/elasticsearch:/usr/share/elasticsearch/data elasticsearch
LogStash

LogStash is a perfect solution to centralize data processing of any type. Its plugins allow us a lot of freedom to process any input, filter data and produce one or more outputs. In this case, input will be syslog. We’ll filter and mutate Docker entries so that we can distinguish them from the rest of syslog. Finally, we’ll output results to ElasticSearch that we already set up.

Container will use official LogStash image. It will expose port 25826, share host volume /data/logstash/config that will provided required configuration and, finally, will link to the ElasticSearch.

sudo docker run -d --name logstash --expose 25826 -p 25826:25826 -p 25826:25826/udp -v $PWD/conf:/conf --link elasticsearch:db logstash logstash -f /conf/syslog.conf
This container was run with -f flag that allows us to specify a configuration we’d like to use. The one we’re using (syslog.conf) looks like following.

input {
  syslog {
    type => syslog
    port => 25826
  }
}

filter {
  if "docker/" in [program] {
    mutate {
      add_field => {
        "container_id" => "%{program}"
      }
    }
    mutate {
      gsub => [
        "container_id", "docker/", ""
      ]
    }
    mutate {
      update => [
        "program", "docker"
      ]
    }
  }
}

output {
  stdout {
    codec => rubydebug
  }
  elasticsearch {
    host => db
  }
}
Those not used to LogStash configuration format might be a bit confused so let us walk you through it. Each configuration can have, among others, input, filter and output sections.

In the input section we’re telling LogStash to listen for syslog events on port 25826.

Filter section is a bit more complex and, in a nutshell, it looks for docker as a program (Docker logging driver is registering itself as a program in format docker/[CONTAINER_ID]). When it finds such program, it mutates its value into a new field container_id and updates program to be simply docker.

Finally, we’re outputting results into stdout (using rubydebug codec) and, more importantly, ElasticSearch.

With ElasticSearch up and running and LogStash listening on syslog events, we are ready to set up rsyslog.

rsyslog

rsyslog is a very fast system for processing logs. We’ll use it to deliver our syslog entries to LogStash. It is already pre-installed in Ubuntu so all we have to do is configure it to work with LogStash.

sudo cp conf/10-logstash.conf /etc/rsyslog.d/.
sudo service rsyslog restart
We copied a new rsyslog configuration and restarted the service. Configuration file is very simple.

*.* @@10.100.199.202:25826
It tells rsyslog to send all syslog entries (*.*) to a remote location (10.100.199.202:25826) using TCP protocol (@@). In this case, 10.100.199.202 is the IP of Vagrant VM we created. If you’re using your own server, please change it to the correct IP. Also, the IP is not a remote location since we are using only one server in this example. In “real” world scenarios you would set rsyslog on each server to point to the central location where ELK is deployed.

Now that we are capturing all syslog events and sending them to ElasticSearch, it is time to visualize our data.

Kibana

Kibana is an analytics and visualization platform designed to work with real-time data. It integrates seamlessly with ElasticSearch.

Unlike ElasticSearch and LogStash, there is no official Kibana image so we created one for you. It can be found in Docker Hub under vfarcic/kibana.

We’ll expose port 5601 and link it with the ElasticSearch container.

sudo docker run -d --name kibana -p 5601:5601 --link elasticsearch:db vfarcic/kibana
Kibana allows us to easily setup dashboards to serve the needs specific to the project or organization. If you are a first time user, you might be better of with an example Dashboard created to showcase the usage of system and Docker logs coming from syslog.

Following command with import sample Kibana settings. It will use a container with ElasticDump tool that provides import and export tools for ElasticSearch. The container is custom-made and can be found in Docker Hub under vfarcic/elastic-dump.

sudo docker run --rm -v $PWD/conf:/data vfarcic/elastic-dump --input=/data/es-kibana.json --output=http://10.100.199.202:9200/.kibana --type=data
Once this container is run, Kibana configuration from the file es-kibana.json was imported into the ElasticSearch database running on 10.100.199.202:9200.

Now we can take a look at Kibana dashboard that we just setup. Open http://localhost:5601 in your favourite browser.

The initial screen shows all unfiltered logs. You can add columns from the left hand side of the screen, create new searches, etc. Among Kibana settings that we imported there is a saved search called error. It filters logs so that only those that contain word error are displayed. We could have done it in many other ways but this one seemed easiest and most straightforward. Open it by clicking the Load Saved Search icon in the top-right corner of the screen. At the moment it shows very few or no errors so let us generate a few fake ones.

logger -s -p 1 "This is fake error..."
logger -s -p 1 "This is another fake error..."
logger -s -p 1 "This is one more fake error..."
Refresh the Kibana screen and you should see those three error messages.

Besides looking at logs in a list format, we can create our own dashboards. For example, click on the Dashboard top menu, then Load Saved Dashboard and select error (another one that we imported previously).

kibana

Running Container with syslog

Up until this moment we saw only system logs so let us run a new Docker container and set it up to use syslog log driver.

sudo docker run -d --name bdd -p 9000:9000 --log-driver syslog vfarcic/bdd
If we go back to Kibana, click on Discover and open Saved Search called docker, there should be, at least, three entries.

That’s it. Now we can scale this to as many containers and servers as we need. All there is to do is set up rsyslog on each server and run containers with --log-driver syslog. Keep in mind that standard docker logs command will not work any more. That’s the expected behaviour. Logs should be in one place, easy to find, filter, visualize, etc.

We’re done with this VM so let us exit and stop it.

exit
vagrant halt
Ansible

The repository that we cloned at the beginning of this article contains two more Vagrant virtual machines. One (elk) contains ElasticSearch, LogStash and Kibana. The other (docker-node) is a separate machine with one docker container up and running. While manual setup is good as a learning exercise, orchestration and deployments should be automated. One way to do that is with Ansible so let’s repeat the same process fully automated.

vagrant up elk
vagrant up docker-node
Open Kibana in http://localhost:5601. It is exactly the same setup as the one we did manually but done automatically with Ansible.

Full source code can be found in the vfarcic/docker-logging-elk GitHub repository. Feel free to take and modify Ansible setup and adapt it to your needs.

If you had trouble following this article or have any additional question, please post a comment or contact me on email (info is in the About section).

The DevOps 2.0 Toolkit

The DevOps 2.0 ToolkitIf you liked this article, you might be interested in The DevOps 2.0 Toolkit: Automating the Continuous Deployment Pipeline with Containerized Microservices book.

This book is about different techniques that help us architect software in a better and more efficient way with microservices packed as immutable containers, tested and deployed continuously to servers that are automatically provisioned with configuration management tools. It’s about fast, reliable and continuous deployments with zero-downtime and ability to roll-back. It’s about scaling to any number of servers, design of self-healing systems capable of recuperation from both hardware and software failures and about centralized logging and monitoring of the cluster.

In other words, this book envelops the whole microservices development and deployment lifecycle using some of the latest and greatest practices and tools. We’ll use Docker, Kubernetes, Ansible, Ubuntu, Docker Swarm and Docker Compose, Consul, etcd, Registrator, confd, Jenkins, and so on. We’ll go through many practices and, even more, tools.