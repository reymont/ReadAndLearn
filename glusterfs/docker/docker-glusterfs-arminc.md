

* https://github.com/arminc/docker-glusterfs

```sh
#!/bin/bash

dd if=/dev/zero of=/gluster.xfs bs=1M count=2048 && \
mkfs.xfs -isize=512 /gluster.xfs && \
mkdir -p /mnt/glusterdata
mount -oloop,inode64,noatime /gluster.xfs /mnt/glusterdata

glusterd
sleep 20
gluster peer probe $1

#!/bin/bash
mkdir /mnt/glusterdata/gv0
gluster volume create gv0 replica 2 $1:/mnt/glusterdata/gv0 $2:/mnt/glusterdata/gv0
gluster volume start gv0
```