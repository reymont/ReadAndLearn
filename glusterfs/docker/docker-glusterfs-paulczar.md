

* https://github.com/paulczar/docker-glusterfs

# Gluster Docker Image

This docker image will run Glusterfs.

If etcd is available it will automatically cluster itself as a 2 node (brick?) replica.

GlusterFS will not work with aufs docker needs to be running in btrfs mode. It also needs to have the `CAP_SYS_ADMIN` capability, or go crazy and `enable privileged mode`.

This is currently an MVP. It does not [yet] support more than 2 bricks and does not auto-heal on failure.

Fetching

$ git clone https://github.com/paulczar/docker-glusterfs.git
cd docker-glusterfs
Building

$ docker build -t paulczar/glusterfs .
Running

Single Node

    $ docker run -d --cap-add=SYS_ADMIN paulczar/glusterfs
    Starting rpcbind daemon....
    ==> $HOST not set.  booting glusterfs without clustering.
    [2014-10-18 18:03:08.189597] I [glusterfsd.c:1959:main] 0-glusterd: Started running glusterd version 3.5.2 (glusterd --pid-file=/app/gluster.pid --log-file=- --no-daemon)
    ...
     ...
    Volume Name: vol1
    Type: Distribute
    Volume ID: 5caf37e8-1fca-4368-ab34-73008950b9cc
    Status: Started
    Number of Bricks: 1
    Transport-type: tcp
    Bricks:
    Brick1: 94ba6e92c799:/export/vol1
    glusterd --pid-file=/app/gluster.pid --log-file=- --no-daemon
Glusterfs Cluster

When etcd is available glusterfs will attempt to start up and create a two node replica.

An example Vagrantfile is provided which will start a 2 node CoreOS cluster each node running glusterfs

$ vagrant up
$ ssh coreos-01
$ journalctl -f -u glusterfs
Oct 18 17:48:50 core-01 sh[6186]: Starting rpcbind daemon....
Oct 18 17:49:08 core-01 sh[6186]: Starting GlusterFS
...
Oct 18 17:49:09 core-01 sh[6186]: ==> glusterfs running...
Oct 18 17:49:09 core-01 sh[6186]: ==> Performing Election...
Oct 18 17:49:09 core-01 sh[6186]: -----> Hurruh I win!
...
Oct 18 17:49:41 core-01 sh[6186]: Volume Name: vol1
Oct 18 17:49:41 core-01 sh[6186]: Type: Replicate
Oct 18 17:49:41 core-01 sh[6186]: Volume ID: 1d9f5073-e196-4c0b-abfe-667a8ba21d
Oct 18 17:49:41 core-01 sh[6186]: Status: Started
Oct 18 17:49:41 core-01 sh[6186]: Number of Bricks: 1 x 2 = 2
Oct 18 17:49:41 core-01 sh[6186]: Transport-type: tcp
Oct 18 17:49:41 core-01 sh[6186]: Bricks:
Oct 18 17:49:41 core-01 sh[6186]: Brick1: 249eb2d2de7f:/export/vol1
Oct 18 17:49:41 core-01 sh[6186]: Brick2: 61035944ced3:/export/vol1
At this point we can actually console into the container by running glusterfs which is a function we inject in the user-data to use nsenter to get a shell inside the glusterfs container... but that's less interesting than actually mounting the gluster volume and testing the replication works.

$ /usr/bin/docker run -t -i --cap-add=SYS_ADMIN paulczar/glusterfs:latest bash
$ service rpcbind start
$ mkdir -p /mnt/vol11
$ mkdir -p /mnt/vol12
$ mount -o mountproto=tcp -t nfs 172.17.8.101:/vol1 /mnt/vol11
$ mount -o mountproto=tcp -t nfs 172.17.8.102:/vol1 /mnt/vol12
$ echo hello > /mnt/vol11/bacon
$ ls /mnt/vol12/bacon
There are some hints that you need to pass via environment variables to make this magic happen. These are provided in the glusterfs unit in user-data.erb. Explore user-data.erb, bin/boot, and bin/functions to see how the sausage is made.

cluster hints

These are the only madatory ones. the rest default to sensible values.

HOST - set this to the Host IP that you want to publish as your endpoint.
ETCD_HOST - set if the etcd endpoint is different to the Host IP above.
Development

You can use vagrant in developer mode which will install the service but not run it. it will also enable debug mode on the start script, share the local path into /home/coreos/share via nfs and build the image locally. This takes quite a while as it builds the image on each VM, but once its up further rebuilds should be quick thanks to the caches.

$ dev=1 vagrant up
$ vagrant ssh core-01
Author(s)

Paul Czarkowski (paul@paulcz.net)

License

Copyright 2014 Paul Czarkowski

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.