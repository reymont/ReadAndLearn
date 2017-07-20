

- [deviantony/docker-elk: The ELK stack powered by Docker and Compose. ](https://github.com/deviantony/docker-elk)


Docker ELK stack

Join the chat at https://gitter.im/deviantony/docker-elk Elastic Stack version

Run the latest version of the ELK (Elasticsearch, Logstash, Kibana) stack with Docker and Docker Compose.

It will give you the ability to analyze any data set by using the searching/aggregation capabilities of Elasticsearch and the visualization power of Kibana.

Based on the official Docker images:

elasticsearch
logstash
kibana
Note: Other branches in this project are available:

ELK 5 with X-Pack support: https://github.com/deviantony/docker-elk/tree/x-pack
ELK 5 in Vagrant: https://github.com/deviantony/docker-elk/tree/vagrant
ELK 5 with Search Guard: https://github.com/deviantony/docker-elk/tree/searchguard
#Contents

* 1.Requirements
  * Host setup
  * SELinux
* 2.Getting started
  * Bringing up the stack
  * Initial setup
* 3.Configuration
  * How can I tune the Kibana configuration?
  * How can I tune the Logstash configuration?
  * How can I tune the Elasticsearch configuration?
  * How can I scale out the Elasticsearch cluster?
* 4.Storage
  * How can I persist Elasticsearch data?
* 5.Extensibility
  * How can I add plugins?
  * How can I enable the provided extensions?
* 6.JVM tuning
  * How can I specify the amount of memory used by a service?
  * How can I enable a remote JMX connection to a service?
#Requirements

Host setup

Install Docker version 1.10.0+
Install Docker Compose version 1.6.0+
Clone this repository
SELinux

On distributions which have SELinux enabled out-of-the-box you will need to either re-context the files or set SELinux into Permissive mode in order for docker-elk to start properly. For example on Redhat and CentOS, the following will apply the proper context:

$ chcon -R system_u:object_r:admin_home_t:s0 docker-elk/
Usage

Bringing up the stack

Start the ELK stack using docker-compose:

$ docker-compose up
You can also choose to run it in background (detached mode):

$ docker-compose up -d
Give Kibana about 2 minutes to initialize, then access the Kibana web UI by hitting http://localhost:5601 with a web browser.

By default, the stack exposes the following ports:

5000: Logstash TCP input.
9200: Elasticsearch HTTP
9300: Elasticsearch TCP transport
5601: Kibana
WARNING: If you're using boot2docker, you must access it via the boot2docker IP address instead of localhost.

WARNING: If you're using Docker Toolbox, you must access it via the docker-machine IP address instead of localhost.

Now that the stack is running, you will want to inject some log entries. The shipped Logstash configuration allows you to send content via TCP:

$ nc localhost 5000 < /path/to/logfile.log
Initial setup

Default Kibana index pattern creation

When Kibana launches for the first time, it is not configured with any index pattern.

Via the Kibana web UI

NOTE: You need to inject data into Logstash before being able to configure a Logstash index pattern via the Kibana web UI. Then all you have to do is hit the Create button.

Refer to Connect Kibana with Elasticsearch for detailed instructions about the index pattern configuration.

On the command line

Run this command to create a Logstash index pattern:

$ curl -XPUT -D- 'http://localhost:9200/.kibana/index-pattern/logstash-*' \
    -H 'Content-Type: application/json' \
    -d '{"title" : "logstash-*", "timeFieldName": "@timestamp", "notExpandable": true}'
This command will mark the Logstash index pattern as the default index pattern:

$ curl -XPUT -D- 'http://localhost:9200/.kibana/config/5.5.0' \
    -H 'Content-Type: application/json' \
    -d '{"defaultIndex": "logstash-*"}'
Configuration

NOTE: Configuration is not dynamically reloaded, you will need to restart the stack after any change in the configuration of a component.

How can I tune the Kibana configuration?

The Kibana default configuration is stored in kibana/config/kibana.yml.

It is also possible to map the entire config directory instead of a single file.

How can I tune the Logstash configuration?

The Logstash configuration is stored in logstash/config/logstash.yml.

It is also possible to map the entire config directory instead of a single file, however you must be aware that Logstash will be expecting a log4j2.properties file for its own logging.

How can I tune the Elasticsearch configuration?

The Elasticsearch configuration is stored in elasticsearch/config/elasticsearch.yml.

You can also specify the options you want to override directly via environment variables:

elasticsearch:

  environment:
    network.host: "_non_loopback_"
    cluster.name: "my-cluster"
How can I scale out the Elasticsearch cluster?

Follow the instructions from the Wiki: Scaling out Elasticsearch

Storage

How can I persist Elasticsearch data?

The data stored in Elasticsearch will be persisted after container reboot but not after container removal.

In order to persist Elasticsearch data even after removing the Elasticsearch container, you'll have to mount a volume on your Docker host. Update the elasticsearch service declaration to:

elasticsearch:

  volumes:
    - /path/to/storage:/usr/share/elasticsearch/data
This will store Elasticsearch data inside /path/to/storage.

NOTE: beware of these OS-specific considerations:

Linux: the unprivileged elasticsearch user is used within the Elasticsearch image, therefore the mounted data directory must be owned by the uid 1000.
macOS: the default Docker for Mac configuration allows mounting files from /Users/, /Volumes/, /private/, and /tmp exclusively. Follow the instructions from the documentation to add more locations.
Extensibility

How can I add plugins?

To add plugins to any ELK component you have to:

Add a RUN statement to the corresponding Dockerfile (eg. RUN logstash-plugin install logstash-filter-json)
Add the associated plugin code configuration to the service configuration (eg. Logstash input/output)
Rebuild the images using the docker-compose build command
How can I enable the provided extensions?

A few extensions are available inside the extensions directory. These extensions provide features which are not part of the standard Elastic stack, but can be used to enrich it with extra integrations.

The documentation for these extensions is provided inside each individual subdirectory, on a per-extension basis. Some of them require manual changes to the default ELK configuration.

JVM tuning

How can I specify the amount of memory used by a service?

By default, both Elasticsearch and Logstash start with 1/4 of the total host memory allocated to the JVM Heap Size.

The startup scripts for Elasticsearch and Logstash can append extra JVM options from the value of an environment variable, allowing the user to adjust the amount of memory that can be used by each component:

Service	Environment variable
Elasticsearch	ES_JAVA_OPTS
Logstash	LS_JAVA_OPTS
To accomodate environments where memory is scarce (Docker for Mac has only 2 GB available by default), the Heap Size allocation is capped by default to 256MB per service in the docker-compose.yml file. If you want to override the default JVM configuration, edit the matching environment variable(s) in the docker-compose.yml file.

For example, to increase the maximum JVM Heap Size for Logstash:

logstash:

  environment:
    LS_JAVA_OPTS: "-Xmx1g -Xms1g"
How can I enable a remote JMX connection to a service?

As for the Java Heap memory (see above), you can specify JVM options to enable JMX and map the JMX port on the docker host.

Update the {ES,LS}_JAVA_OPTS environment variable with the following content (I've mapped the JMX service on the port 18080, you can change that). Do not forget to update the -Djava.rmi.server.hostname option with the IP address of your Docker host (replace DOCKER_HOST_IP):

logstash:

  environment:
    LS_JAVA_OPTS: "-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.managemen