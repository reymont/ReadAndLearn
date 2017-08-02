

[Deploy Kubernetes w/ Ansible & Terraform – Spencer's Blog ](https://rsmitty.github.io/Terraform-Ansible-Kubernetes/)

APRIL 11, 2016
 Reading time ~6 minutes

Back after a pretty lengthy intermission! Today I want to talk about Kubernetes. I’ve recently had some clients that have been interested in running Docker containers in a production environment and, after some research and requirement gathering, we came to the conclusion that the functionality that they wanted was not easily provided with the Docker suite of tools. These are things like guaranteeing a number of replicas running at all times, easily creating endpoints and load balancers for the replicas created, and enabling more complex deployment methodologies like blue/green or rolling updates.

As it turns out, all of this stuff is included to some extent or another with Kubernetes and we were able to recommend that they explore this option to see how it works out for them. Of course, recommending is the easy part, while implementation is decidedly more complex. The desire for the proof of concept was to enable multi-cloud deployments of Kubernetes, while also remaining within their pre-chosen set of tools like Amazon AWS, OpenStack, CentOS, Ansible, etc.. To accomplish this, we were able to create a Kubernetes deployment using Hashicorp’s Terraform, Ansible, OpenStack, and Amazon. This post will talk a bit about how to roll your own cluster by adapting what I’ve seen.

Why Would I Want to do This?

This is totally a valid question. And the answer here is that you don’t… if you can help it. There are easier and more fully featured ways to deploy Kubernetes if you have open game on the tools to choose. As a recommendation, I would say that using Google Container Engine is by far the most supported and pain-free way to get started with Kubernetes. Following that, I would recommend using Amazon AWS and CoreOS as your operating system. Again, lots of people using these tools means that bugs and gotchas are well documented and easier to deal with. It should also be noted that there are OpenStack built-ins to create Kubernetes clusters, such as Magnum. Again, if you’re a one-cloud shop, this is likely easier than rolling your own.

Alas, here we are and we’ll search for a way to get it done!

What Pieces are in Play?

For the purposes of this walkthrough, there will be four pieces that you’ll need to understand:

OpenStack - An infrastructure as a service cloud platform. I’ll be using this in lieu of Amazon.
Terraform - Terraform allows for automated creation of servers, external IPs, etc. across a multitude of cloud environments. This was a key choice to allow for a seamless transition to creating resources in both Amazon and OpenStack.
Ansible - Ansible is a configuration management platform that automates things like package installation and config file setup. We will use a set of Ansible playbooks called KubeSpray Kargo to setup Kubernetes.
Kubernetes - And finally we get to K8s! All of the tools above will come together to give us a fully functioning cluster.
Clone KubeSpray’s Kargo

First we’ll want to pull down the Ansible playbooks we want to use.

If you’ve never installed Ansible, it’s quite easy on a Mac with brew install ansible. Other instructions can be found here.

Ensure git is also installed with brew install git.

Create a directory for all of your deployment files and change into that directory. I called mine ‘terra-spray’.

Issue git clone git@github.com:kubespray/kargo.git. A new directory called kargo will be created with the playbooks:

Spencers-MBP:terra-spray spencer$ ls -lah
total 104
drwxr-xr-x  13 spencer  staff   442B Apr  6 12:48 .
drwxr-xr-x  12 spencer  staff   408B Apr  5 16:45 ..
drwxr-xr-x  15 spencer  staff   510B Apr  5 16:55 kargo
Note that there are a plethora of different options available with Kargo. I highly recommend spending some time reading up on the project and the different playbooks out there in order to deploy the specific cluster type you may need.
Create Terraform Templates

We want to create two terraform templates, the first will create our OpenStack infrastructure, while the second will create an Ansible inventory file for kargo to use. Additionally, we will create a variable file where we can populate our desired OpenStack variables as needed. The Terraform syntax can look a bit daunting at first, but it starts to make sense as we look at it more and see it in action.

Create all files with touch 00-create-k8s-nodes.tf 01-create-inv.tf terraform.tfvars The .tf and .tfvars extension are terraform specific extensions.

In the variables file, terraform.tfvars, populate with the following information and update the variables to reflect your OpenStack installation:

node-count="2"
internal-ip-pool="private"
floating-ip-pool="public"
image-name="Ubuntu-14.04.2-LTS"
image-flavor="m1.small"
security-groups="default,k8s-cluster"
key-pair="spencer-key"
Now we want to create our Kubernetes master and nodes using the variables described above. Open 00-create-k8s-nodes.tf and add the following:
##Setup needed variables
variable "node-count" {}
variable "internal-ip-pool" {}
variable "floating-ip-pool" {}
variable "image-name" {}
variable "image-flavor" {}
variable "security-groups" {}
variable "key-pair" {}

##Create a single master node and floating IP
resource "openstack_compute_floatingip_v2" "master-ip" {
  pool = "${var.floating-ip-pool}"
}

resource "openstack_compute_instance_v2" "k8s-master" {
  name = "k8s-master"
  image_name = "${var.image-name}"
  flavor_name = "${var.image-flavor}"
  key_pair = "${var.key-pair}"
  security_groups = ["${split(",", var.security-groups)}"]
  network {
    name = "${var.internal-ip-pool}"
  }
  floating_ip = "${openstack_compute_floatingip_v2.master-ip.address}"
}

##Create desired number of k8s nodes and floating IPs
resource "openstack_compute_floatingip_v2" "node-ip" {
  pool = "${var.floating-ip-pool}"
  count = "${var.node-count}"
}

resource "openstack_compute_instance_v2" "k8s-node" {
  count = "${var.node-count}"
  name = "k8s-node-${count.index}"
  image_name = "${var.image-name}"
  flavor_name = "${var.image-flavor}"
  key_pair = "${var.key-pair}"
  security_groups = ["${split(",", var.security-groups)}"]
  network {
    name = "${var.internal-ip-pool}"
  }
  floating_ip = "${element(openstack_compute_floatingip_v2.node-ip.*.address, count.index)}"
}
Now, with what we have here, our infrastructure is provisioned on OpenStack. However, we want to get the information about our infrastructure into the Kargo playbooks to use as its Ansible inventory. Add the following to 01-create-inventory.tf:
resource "null_resource" "ansible-provision" {

  depends_on = ["openstack_compute_instance_v2.k8s-master","openstack_compute_instance_v2.k8s-node"]

  ##Create Masters Inventory
  provisioner "local-exec" {
    command =  "echo \"[kube-master]\n${openstack_compute_instance_v2.k8s-master.name} ansible_ssh_host=${openstack_compute_floatingip_v2.master-ip.address}\" > kargo/inventory/inventory"
  }

  ##Create ETCD Inventory
  provisioner "local-exec" {
    command =  "echo \"\n[etcd]\n${openstack_compute_instance_v2.k8s-master.name} ansible_ssh_host=${openstack_compute_floatingip_v2.master-ip.address}\" >> kargo/inventory/inventory"
  }

  ##Create Nodes Inventory
  provisioner "local-exec" {
    command =  "echo \"\n[kube-node]\" >> kargo/inventory/inventory"
  }
  provisioner "local-exec" {
    command =  "echo \"${join("\n",formatlist("%s ansible_ssh_host=%s", openstack_compute_instance_v2.k8s-node.*.name, openstack_compute_floatingip_v2.node-ip.*.address))}\" >> kargo/inventory/inventory"
  }

  provisioner "local-exec" {
    command =  "echo \"\n[k8s-cluster:children]\nkube-node\nkube-master\" >> kargo/inventory/inventory"
  }
}
This template certainly looks a little confusing, but what is happening is that Terraform is taking the information for the created Kubernetes masters and nodes and outputting the hostnames and IP addresses into the Ansible inventory format at a local path of ./kargo/inventory/inventory. A sample output looks like:

[kube-master]
k8s-master ansible_ssh_host=xxx.xxx.xxx.xxx

[etcd]
k8s-master ansible_ssh_host=xxx.xxx.xxx.xxx

[kube-node]
k8s-node-0 ansible_ssh_host=xxx.xxx.xxx.xxx
k8s-node-1 ansible_ssh_host=xxx.xxx.xxx.xxx

[k8s-cluster:children]
kube-node
kube-master
Setup OpenStack

You may have noticed in the Terraform section that we attached a k8s-cluster security group in our variables file. You will need to set this security group up to allow for the necessary ports used by Kubernetes. Follow this list and enter them into Horizon.

Hold On To Your Butts!

Now that Terraform is setup, we should be able to launch our cluster and have it provision using the Kargo playbooks we checked out. But first, one small BASH script to ensure things run in the proper order.

Create a file called cluster-up.sh and open it for editing. Paste the following:
#!/bin/bash

##Create infrastructure and inventory file
echo "Creating infrastructure"
terraform apply

##Run Ansible playbooks
echo "Quick sleep while instances spin up"
sleep 120
echo "Ansible provisioning"
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i kargo/inventory/inventory -u ubuntu -b kargo/cluster.yml
You’ll notice I included a two minute sleep to take care of some of the time when the nodes created by Terraform weren’t quite ready for an SSH session when Ansible started reaching out to them. Finally, update the -u flag in the ansible-playbook command to the user that has SSH access to the OpenStack instances you have created. I used ubuntu because that’s the default SSH user for Ubuntu cloud images.

Source your OpenStack credentials file with source /path/to/credfile.sh

Launch the cluster with ./cluster-up.sh. The Ansible deployment will take quite a bit of time as the necessary packages are downloaded and setup.

Assuming all goes as planned, SSH into your Kubernetes master and issue kubectl get-nodes:

ubuntu@k8s-master:~$ kubectl get nodes
NAME         STATUS    AGE
k8s-node-0   Ready     1m
k8s-node-1   Ready     1m