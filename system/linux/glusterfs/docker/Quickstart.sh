
# http://docs.gluster.org/en/latest/Quick-Start-Guide/Quickstart/
# https://github.com/million12/docker-gluster


docker run -d --privileged million12/gluster
docker run -d --privileged million12/gluster
docker run -d --privileged million12/gluster

# 172.17.0.3 peer 172.17.0.2
docker exec -it 20f3bbbaf396 bash
gluster peer probe 172.17.0.2
# 172.17.0.2 peer 172.17.0.3
docker exec -it aaf380a90057 bash
gluster peer probe 172.17.0.3
# Step 6 - Set up a GlusterFS volume
## On both server1 and server2:
mkdir -p /data/brick1/gv0
## From any single server:
gluster volume create gv0 replica 2 172.17.0.2:/data/brick1/gv0 172.17.0.3:/data/brick1/gv0 force
gluster volume start gv0
gluster volume info
# Testing the GlusterFS volume
docker exec -it 8b61e85cf095 bash
mount -t glusterfs 172.17.0.2:/gv0 /mnt
for i in `seq -w 1 100`; do cp -rp /var/log/messages /mnt/copy-test-$i; done
## First, check the client mount point:
ls -lA /mnt/copy* | wc -l
## You should see 100 files returned. Next, check the GlusterFS brick mount points on each server:
ls -lA /data/brick1/gv0/copy*
