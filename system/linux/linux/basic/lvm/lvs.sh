#创建分区
fdisk /dev/xxx
n p w
#分区生效
partprobe
#扩大卷组
vgextend centos /dev/vda3
#查看逻辑卷
vgs
lvscan
#扩大逻辑卷
lvextend -L +35g /dev/centos/root
#逻辑卷fs调整
resize2fs /dev/centos/root



partprobe
pvcreate /dev/vda3
vgextend centos /dev/vda3
#lvextend -L +`vgs -o vg_free --rows | awk  '{print $2}'` /dev/centos/root
lvextend /dev/centos/root -l +100%FREE
resize2fs /dev/centos/root

#删除
fdisk /dev/sdb
d
umount /dev/sdb1 
partprobe 
