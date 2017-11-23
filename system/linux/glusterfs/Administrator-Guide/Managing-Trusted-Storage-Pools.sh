
# http://docs.gluster.org/en/latest/Administrator%20Guide/Storage%20Pools/
# https://github.com/million12/docker-gluster

# A storage pool is a trusted network of storage servers. Before 
# you can configure a GlusterFS volume, you must create a trusted 
# storage pool consisting of the storage servers that will provide 
# bricks to the volume.

# When you start the first server, the storage pool consists of 
# that server alone. To add additional storage servers to the 
# storage pool, run the peer probe command on that server.

# The firewall on the servers must be configured to allow access to port 24007.

docker run -d --privileged million12/gluster
docker run -d --privileged million12/gluster
docker run -d --privileged million12/gluster
docker run -d --privileged million12/gluster

gluster peer probe 172.17.0.3
gluster peer probe 172.17.0.4
gluster peer probe 172.17.0.5

# Verify the peer status from the first server (server1):
gluster peer status
# to remove server4 from the trusted storage pool:
gluster peer detach 172.17.0.5
