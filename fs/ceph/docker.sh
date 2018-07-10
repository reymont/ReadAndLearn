#创建
docker run -d --net=host \
  -e MON_IP=192.168.31.212 \
  -e CEPH_PUBLIC_NETWORK=192.168.31.0/24 \
  --name ceph ceph/demo

docker exec -it ceph bash
#最简单的ceph命令是，ceph -w，也就是watch整个ceph集群的状态
ceph -w
ceph status

#Pool是Ceph中的逻辑概念，不同的应用可以使用不同的Pool
rados lspools

#获得特定Pool的数据
rados -p .rgw ls
rados -p .rgw.root ls

#获得当前OSD所用容量。
rados df

#创建Bucket
ceph osd tree
ceph osd crush add-bucket rack01 rack
ceph osd crush add-bucket rack02 rack
ceph osd crush add-bucket rack03 rack
ceph osd tree

#移动Rack
ceph osd crush move rack01 root=default
ceph osd crush move rack02 root=default
ceph osd crush move rack03 root=default
ceph osd tree

#Object操作
##创建Pool
ceph osd pool create web-services 128 128
rados lspools
#添加Object
echo "Hello Ceph, You are Awesome like MJ" > /tmp/helloceph
rados -p web-services put object1 /tmp/helloceph
rados -p web-services ls
ceph osd map web-services object1 #指明了例如10.3c等信息
#查看Object
cd /var/lib/ceph/osd/
ls ceph-0/current/10.3c_head/
cat ceph-0/current/10.3c_head/object1__head_BAC5DEBC__a

#RBD命令
##检查Pool
##Ceph启动后默认创建rbd这个pool，使用rbd命令默认使用它，我们也可以创建新的pool。
rados lspools
ceph osd pool create rbd_pool 1024
##创建Image
##使用rbd命令创建image，创建后发现rbd这个pool会多一个rbd_directory的object。
rbd create test_image --size 1024
rbd ls
rbd --image test_image info
rados -p rbd ls
##修改Image大小
##增加Image大小可以直接使用resize子命令，如果缩小就需要添加--allow-shrink参数保证安全。
rbd --image test_image resize --size 2000
rbd --image test_image resize --size 1000 --allow-shrink
##使用Image
##通过map子命令可以把镜像映射成本地块设备，然后就可以格式化和mount了。
rbd map test_image
rbd showmapped
mkfs.ext4 /dev/rbd0
mount /dev/rbd0 /mnt/
##移除Image
umount /dev/rbd0
rbd unmap /dev/rbd0
rbd showmapped
##删除Image
##删除和Linux类似使用rm命令即可。
rbd --image test_image rm




