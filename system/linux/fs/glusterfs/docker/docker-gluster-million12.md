

* GitHub - million12/docker-gluster: Docker Image of GlusterFS daemon. 
https://github.com/million12/docker-gluster


This is GluserFS Daeomon onlye Docker Image. Based on CentOS 7

Usage

docker pull million12/gluster

Or, if you prefer to build it on your own:
docker build -t million12/gluster .

Run the image as daemon:
docker run -d --net host --privileged million12/gluster

Create new volume

docker exec -ti docker_id gluster volume create my_volume_name /my/mount_point/brick
docker exec -ti d0ad3607bd9e gluster volume create my_volume_name stripe /my/mount_point/brick


Now start that volume:
docker exec -ti docker_id gluster volume start my_volume_name

Mount GlusterFS:
mount -f glusterfs $GLUSTER_IP:/my_volume_name /my/mount_point/

Authors

Author: Marcin Ryzycki (marcin@m12.io)
Author: Przemyslaw Ozgo (linux@ozgo.info)

Sponsored by Typostrap.io - the new prototyping tool for building highly-interactive prototypes of your website or web app. Built on top of TYPO3 Neos CMS and Zurb Foundation framework.