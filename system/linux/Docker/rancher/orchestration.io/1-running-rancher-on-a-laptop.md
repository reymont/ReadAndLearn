Building the Micro Datacenter - Running Rancher on a Laptop | Rancher Labs 
http://rancher.com/running-rancher-on-a-laptop/

Chris Urwin on May 18, 2016

developer-virtualboxThe ultimate goal for a developer is to have their own data center, enabling them to test their services in an exact live replica. However, the life of a developer is full of compromises. Data is a reduced set or anonymized, and companies aren’t quite ready to pay for a data center per developmer.

Today, i’ll provide an overview of how using Rancher and a local machine can eliminate some of these compromises. Our goal is to provide developers with an environment that is as representative as possible of what will eventually be running in production, and we’re going to use the magic of Docker and Rancher to do it.

If you’ve experienced any of the following:

Shared development environment being broken with multiple issues
Inconsistent test data
Network issues delaying development
Then hopefully I’ll be able to give you some ideas on how you can address these.

Rancher and Docker can Help
Replicating a data center where all services run on bare metal doesn’t translate to a laptop. Moving towards virtual machines helped in part because users can run multiple services. The issues then become physical. Either disk I/O makes it unusable, or there isn’t enough memory to run a reasonable representation of production. This is where Docker and Rancher can help. Docker containers start quickly and Rancher helps with things like orchestration, networking and load balancing.

With this combination, it is now possible to get closer to running a Data center on your laptop. This idea has become incredibly popular the last six months as a number of very large organizations have started providing a full docker management layer to developers to run locally.  Companies are making this investment because they are able to reap a broad variety of benefits, including:

Developers are more familiar with the tools when it comes to issues seen live
Developers catch issues before they hand over their code
Developers are able to work in isolation, even offline
New developers can be onboarded in minutes instead of days or weeks
DevOps gets handed an immutable container that should “just work.”
So how do we go about it? For the purpose of this blog, I’m going assume Docker Toolbox is being used on a Mac or Windows. Downloads and instructions on installing this can be found at https://www.docker.com/products/docker-toolbox.

First, let’s see what it looks like:

Urwin 1

We are going to run a couple of Virtual Machines, one running just the Rancher Server, another running as a host and running an application stack. There are a couple of reasons for running in this configuration. First, it’s more representative of live, and second, your application won’t be able to starve Rancher of resources if there is an issue.

So first things first, let’s create a VirtualBox VM with 512GB and 8GB disk. We’ll call this one Rancher:

docker-machine create rancher --driver virtualbox --virtualbox-cpu-count "-1" --virtualbox-disk-size "8000" --virtualbox-memory "512" --virtualbox-boot2docker-url=https://github.com/boot2docker/boot2docker/releases/download/v1.10.3/boot2docker.iso
We specify the URL for Docker v1.10.3 given that is what Rancher runs on.

Docker Toolbox is ideal for running Docker locally, but it does have some challenges. One of these is that it uses DHCP, which is fine if you don’t want to host a static service. However, to get around this ssh to the Rancher machine, add the following lines to /var/lib/boot2docker/profile:

sudo cat /var/run/udhcpc.eth1.pid | xargs sudo kill
sudo ifconfig eth1 <ip address to assign> netmask <subnet mask> broadcast <broadcast address> up
At this point, you will have an error in docker-machine about the IP address not matching. Run the following on the host OS to solve this:

docker-machine regenerate-certs rancher -f
This will then give our Rancher server a static IP address.

You can then run:

docker run -d --restart=always -p 8080:8080 rancher/server
After a few minutes, you will have a Rancher Server running on port 8080 of the IP address you specified. Fixing the IP address of the Rancher server is important as this is where any hosts agents that we deploy will need to point to.

After logging into the Rancher Server, go to “add host” and generate the custom agent command. Copy it and keep it as we are going to use it to add a host.

Let’s now create a second VM. Use the same command as above but adjust the name, memory and disk space to suit your development requirements.

Again once the VM has started, you can go in and assign it a static IP address.

Now, we come across another limitation of the boot2docker VM; its data persistence.

If we add a Rancher agent to a host, it creates a /var/lib/rancher folder and stores some information in it. Reboot the VM and this gets destroyed. Thus, when the agent comes up again it thinks it’s a new server and things go downhill from there.

Luckily there is a workaround to this. Before running the Rancher agent script log onto the host, run the following:

sudo mkdir /mnt/sda1/var/lib/rancher
This will create us a folder that persists between reboots. Now, on every boot I’ll need to map this folder to /var/lib/rancher. So editing /var/lib/boot2docker/profile again and add the following:

sudo mkdir /var/lib/rancher
sudo mount -r /mnt/sda1/var/lib/rancher /var/lib/rancher
This will ensure that our agent state persists between reboots.

Now ssh to the machine and run the custom agent string that you obtained from the Rancher server.

Now you’ve got a Rancher Server, with a host all running locally that is just waiting for you to deploy your application stack to it.

This is where it is up to you to take it to the next level.  But now, you have a functioning Rancher/Docker environment. You should be able to pull from an external repository, script your application to build locally or just run a catalog entry.

While this way of developing isn’t perfect, it is “good enough” for a large number of scenarios and is certainly worth investigating as a way to improve development.

In our online meetup on 26th May 2016, we are going to be extending from this blog by looking at how this can look if you bring Jenkins and Git into the solution. We’ll also be joined by a user who will share how this has impacted their developer productivity, and enabled them to onboard new developers much more quickly.