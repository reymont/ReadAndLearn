

测试glusterfs 与 kubernetes节点容错 - 简书 http://www.jianshu.com/p/9163585d6780

参考http://www.jianshu.com/p/f70d370582ef
做好 glusterfs 和 heketi 测试服务

创建StorageClass

wget https://raw.githubusercontent.com/4admin2root/daocloud/master/statefulset/glusterfs-sc.yaml
kubectl apply -f glusterfs-sc.yaml
需修改其中的glusterid

创建zookeeper StatefulSet

kubectl apply -f https://raw.githubusercontent.com/4admin2root/daocloud/master/statefulset/zookeeper.yaml
注意：所有node节点需要安装glusterfs，否则出现如下错误

 the following error information was pulled from the glusterfs log to help diagnose this issue: glusterfs: could not open log file for pod: zk-0
  28m   1m  18  kubelet, cloud4ourself-mykc3.novalocal      Warning FailedMount MountVolume.SetUp failed for volume "kubernetes.io/glusterfs/78767b6a-2655-11e7-917d-fa163ee91167-pvc-786bd3ff-2655-11e7-917d-fa163ee91167" (spec.Name: "pvc-786bd3ff-2655-11e7-917d-fa163ee91167") pod "78767b6a-2655-11e7-917d-fa163ee91167" (UID: "78767b6a-2655-11e7-917d-fa163ee91167") with: glusterfs: mount failed: mount failed: exit status 32
Mounting command: mount
Mounting arguments: 10.9.5.97:vol_6a87e2c55d6ffdfeec98a292fdbeecbc /var/lib/kubelet/pods/78767b6a-2655-11e7-917d-fa163ee91167/volumes/kubernetes.io~glusterfs/pvc-786bd3ff-2655-11e7-917d-fa163ee91167 glusterfs [log-level=ERROR log-file=/var/lib/kubelet/plugins/kubernetes.io/glusterfs/pvc-786bd3ff-2655-11e7-917d-fa163ee91167/zk-0-glusterfs.log]
Output: mount: unknown filesystem type 'glusterfs'
yum install centos-release-gluster glusterfs-fuse -y

检查结果

#mykc2是master
[root@cloud4ourself-mykc2 ~]# kubectl get pod
NAME      READY     STATUS              RESTARTS   AGE
zk-0      1/1       Running             0          2m
zk-1      1/1       Running             0          2m
zk-2      0/1       ContainerCreating   0          1m
[root@cloud4ourself-mykc2 ~]# kubectl get pvc
NAME           STATUS    VOLUME                                     CAPACITY   ACCESSMODES   STORAGECLASS   AGE
datadir-zk-0   Bound     pvc-a4fb4148-265c-11e7-917d-fa163ee91167   5Gi        RWO           slow           2m
datadir-zk-1   Bound     pvc-bb4e4c2d-265c-11e7-917d-fa163ee91167   5Gi        RWO           slow           2m
datadir-zk-2   Bound     pvc-cb91250c-265c-11e7-917d-fa163ee91167   5Gi        RWO           slow           1m
[root@cloud4ourself-mykc2 ~]# kubectl get pv
NAME                                       CAPACITY   ACCESSMODES   RECLAIMPOLICY   STATUS    CLAIM                  STORAGECLASS   REASON    AGE
pvc-a4fb4148-265c-11e7-917d-fa163ee91167   5Gi        RWO           Delete          Bound     default/datadir-zk-0   slow                     2m
pvc-bb4e4c2d-265c-11e7-917d-fa163ee91167   5Gi        RWO           Delete          Bound     default/datadir-zk-1   slow                     2m
pvc-cb91250c-265c-11e7-917d-fa163ee91167   5Gi        RWO           Delete          Bound     default/datadir-zk-2   slow                     1m

[root@cloud4ourself-mykc3 ~]# df -T |grep gluster
10.9.5.96:vol_20a0be112ce354bcd480081e95d2f00f fuse.glusterfs   5230592   33408   5197184   1% /var/lib/kubelet/pods/a4fced20-265c-11e7-917d-fa163ee91167/volumes/kubernetes.io~glusterfs/pvc-a4fb4148-265c-11e7-917d-fa163ee91167
[root@cloud4ourself-mykc3 ~]# ls -l /var/lib/kubelet/pods/a4fced20-265c-11e7-917d-fa163ee91167/volumes/kubernetes.io~glusterfs/pvc-a4fb4148-265c-11e7-917d-fa163ee91167
total 8
drwxr-xr-x 3 xzx xzx 4096 Apr 21 14:35 data
drwxr-xr-x 3 xzx xzx 4096 Apr 21 14:35 log
[root@cloud4ourself-mykc3 ~]# cat /var/lib/kubelet/pods/a4fced20-265c-11e7-917d-fa163ee91167/volumes/kubernetes.io~glusterfs/pvc-a4fb4148-265c-11e7-917d-fa163ee91167/data/myid
1
[root@cloud4ourself-c1 heketi]# df -h
Filesystem                                                                              Size  Used Avail Use% Mounted on
/dev/vda1                                                                                30G  7.4G   23G  25% /
devtmpfs                                                                                1.9G     0  1.9G   0% /dev
tmpfs                                                                                   1.9G     0  1.9G   0% /dev/shm
tmpfs                                                                                   1.9G   17M  1.9G   1% /run
tmpfs                                                                                   1.9G     0  1.9G   0% /sys/fs/cgroup
tmpfs                                                                                   380M     0  380M   0% /run/user/0
/dev/mapper/vg_fbc394e08d421c9e2ae70ded80b1c14e-brick_ab13482ad50c60838b1292cfa2f866b2  5.0G   33M  5.0G   1% /var/lib/heketi/mounts/vg_fbc394e08d421c9e2ae70ded80b1c14e/brick_ab13482ad50c60838b1292cfa2f866b2
/dev/mapper/vg_fbc394e08d421c9e2ae70ded80b1c14e-brick_15d8521c9352b19982af1d9c736f340a  5.0G   33M  5.0G   1% /var/lib/heketi/mounts/vg_fbc394e08d421c9e2ae70ded80b1c14e/brick_15d8521c9352b19982af1d9c736f340a
/dev/mapper/vg_fbc394e08d421c9e2ae70ded80b1c14e-brick_8a69cb4a293fbd66225c41fdef8c259e  5.0G   33M  5.0G   1% /var/lib/heketi/mounts/vg_fbc394e08d421c9e2ae70ded80b1c14e/brick_8a69cb4a293fbd66225c41fdef8c259e
模拟gluster单brick失败：Replicated Glusterfs Volume

#reboot c1(10.9.5.97)，使用如下命令进行每秒写入
zookeeper@zk-0:/var/lib/zookeeper$ for i in {1..1000}; do date;echo $i| tee -a a.out; sleep 1; done
#持续，不间断
#reboot c2(10.9.5.96)，使用如下命令进行每秒写入
zookeeper@zk-0:/var/lib/zookeeper$ for i in {1..1000}; do date;echo $i| tee -a a.out; sleep 1; done
Fri Apr 21 07:28:59 UTC 2017
7
Fri Apr 21 07:29:00 UTC 2017
8
Fri Apr 21 07:29:01 UTC 2017
9
Fri Apr 21 07:29:15 UTC 2017
10
#短暂中14s等待后，继续写入
[root@cloud4ourself-mykc3 ~]# ss -antp |grep 5.9[6,7]
ESTAB      0      0      10.9.5.94:49151              10.9.5.96:24007               users:(("glusterfs",pid=7738,fd=6))
ESTAB      0      0      10.9.5.94:49149              10.9.5.97:49152               users:(("glusterfs",pid=7738,fd=8))
ESTAB      0      0      10.9.5.94:49148              10.9.5.96:49152               users:(("glusterfs",pid=7738,fd=11))
[root@cloud4ourself-mykc3 ~]# ss -antp |grep 5.9[6,7]
ESTAB      0      0      10.9.5.94:49149              10.9.5.97:49152               users:(("glusterfs",pid=7738,fd=8))
[root@cloud4ourself-mykc3 ~]# ss -antp |grep 5.9[6,7]
ESTAB      0      0      10.9.5.94:49151              10.9.5.96:24007               users:(("glusterfs",pid=7738,fd=6))
TIME-WAIT  0      0      10.9.5.94:49150              10.9.5.96:24007
ESTAB      0      0      10.9.5.94:49149              10.9.5.97:49152               users:(("glusterfs",pid=7738,fd=8))
ESTAB      0      0      10.9.5.94:49148              10.9.5.96:49152               users:(("glusterfs",pid=7738,fd=11))
#以上是重启前、中、后zk-0对应node上的连接情况

#检查glusterfs 服务器端文件，发现文件a.out一致

模拟node维护

16:25:06[root@cloud4ourself-mykc2 ~]# kubectl get pod -o wide
NAME      READY     STATUS    RESTARTS   AGE       IP               NODE
zk-0      1/1       Running   0          1d        192.168.165.19   cloud4ourself-mykc3.novalocal
zk-1      1/1       Running   0          1h        192.168.179.67   cloud4ourself-mykc5.novalocal
zk-2      1/1       Running   1          2h        192.168.55.75    cloud4ourself-mykc1.novalocal
16:26:25[root@cloud4ourself-mykc2 ~]# kubectl cordon cloud4ourself-mykc1.novalocal
node "cloud4ourself-mykc1.novalocal" cordoned

16:26:39[root@cloud4ourself-mykc2 ~]# kubectl drain cloud4ourself-mykc1.novalocal
node "cloud4ourself-mykc1.novalocal" already cordoned
error: DaemonSet-managed pods (use --ignore-daemonsets to ignore): calico-node-cfrgh, kube-proxy-7z8g9

16:30:06[root@cloud4ourself-mykc2 ~]# kubectl drain cloud4ourself-mykc1.novalocal --ignore-daemonsets
node "cloud4ourself-mykc1.novalocal" already cordoned
WARNING: Ignoring DaemonSet-managed pods: calico-node-cfrgh, kube-proxy-7z8g9
pod "zk-2" evicted
node "cloud4ourself-mykc1.novalocal" drained


16:31:33[root@cloud4ourself-mykc2 ~]# kubectl get pod -o wide
NAME      READY     STATUS    RESTARTS   AGE       IP               NODE
zk-0      1/1       Running   0          1d        192.168.165.19   cloud4ourself-mykc3.novalocal
zk-1      1/1       Running   0          1h        192.168.179.67   cloud4ourself-mykc5.novalocal
zk-2      1/1       Running   0          48s       192.168.139.69   cloud4ourself-mykc4.novalocal


[root@cloud4ourself-mykc4 ~]# df -T |grep gluster
10.9.5.96:vol_615f2a0c3de9a76069b23ac1e868fdbb fuse.glusterfs   5230592   33408   5197184   1% /var/lib/kubelet/pods/7d6b1e42-2991-11e7-917d-fa163ee91167/volumes/kubernetes.io~glusterfs/pvc-cb91250c-265c-11e7-917d-fa163ee91167

16:37:51[root@cloud4ourself-mykc2 ~]# kubectl uncordon cloud4ourself-mykc1.novalocal
node "cloud4ourself-mykc1.novalocal" uncordoned

16:39:00[root@cloud4ourself-mykc2 ~]# kubectl drain cloud4ourself-mykc4.novalocal --ignore-daemonsets
node "cloud4ourself-mykc4.novalocal" already cordoned
WARNING: Ignoring DaemonSet-managed pods: calico-node-fqllc, kube-proxy-gwgt4
pod "zk-2" evicted
node "cloud4ourself-mykc4.novalocal" drained
16:39:46[root@cloud4ourself-mykc2 ~]# kubectl get pod -o wide
NAME      READY     STATUS    RESTARTS   AGE       IP               NODE
zk-0      1/1       Running   0          1d        192.168.165.19   cloud4ourself-mykc3.novalocal
zk-1      1/1       Running   0          1h        192.168.179.67   cloud4ourself-mykc5.novalocal
zk-2      1/1       Running   0          34s       192.168.55.77    cloud4ourself-mykc1.novalocal
模拟kubernetes node失败

有zookeeper.yaml文件定义了反亲和性，所以临时加一个node进行测试
参考 ansible playbook
https://github.com/4admin2root/daocloud/tree/master/roles/kubeadm_init

[root@cloud4ourself-mykc2 ~]# kubectl get nodes
NAME                            STATUS    AGE       VERSION
cloud4ourself-mykc1.novalocal   Ready     7d        v1.6.1
cloud4ourself-mykc2.novalocal   Ready     7d        v1.6.1
cloud4ourself-mykc3.novalocal   Ready     7d        v1.6.1
cloud4ourself-mykc4.novalocal   Ready     1d        v1.6.1
cloud4ourself-mykc5.novalocal   Ready     2m        v1.6.1

#手动关闭mykc3
16:46:25[root@cloud4ourself-mykc2 ~]# kubectl get nodes
NAME                            STATUS     AGE       VERSION
cloud4ourself-mykc1.novalocal   Ready      10d       v1.6.1
cloud4ourself-mykc2.novalocal   Ready      11d       v1.6.1
cloud4ourself-mykc3.novalocal   NotReady   11d       v1.6.1
cloud4ourself-mykc4.novalocal   Ready      5d        v1.6.1
cloud4ourself-mykc5.novalocal   Ready      3d        v1.6.1
#等几分钟（居然这么久）
16:46:33[root@cloud4ourself-mykc2 ~]# kubectl get pod -o wide
NAME      READY     STATUS    RESTARTS   AGE       IP               NODE
zk-0      1/1       Unknown   0          1d        192.168.165.19   cloud4ourself-mykc3.novalocal
zk-1      1/1       Running   0          1h        192.168.179.67   cloud4ourself-mykc5.novalocal
zk-2      1/1       Running   0          7m        192.168.55.77    cloud4ourself-mykc1.novalocal

#这种情况下，对应statefulset pod不会在其他节点上启动
#参考https://github.com/kubernetes/kubernetes/blob/b0ce93f9be25c762fd4b746077fcda2aaa5b12bd/CHANGELOG.md#notable-changes-to-existing-behavior
#于是手动删除节点
17:13:51[root@cloud4ourself-mykc2 ~]# kubectl get pod -o wide
NAME      READY     STATUS    RESTARTS   AGE       IP               NODE
zk-0      1/1       Unknown   0          1d        192.168.165.19   cloud4ourself-mykc3.novalocal
zk-1      1/1       Running   0          2h        192.168.179.67   cloud4ourself-mykc5.novalocal
zk-2      1/1       Running   0          34m       192.168.55.77    cloud4ourself-mykc1.novalocal
17:13:58[root@cloud4ourself-mykc2 ~]# kubectl delete node cloud4ourself-mykc3.novalocal
node "cloud4ourself-mykc3.novalocal" deleted
17:14:12[root@cloud4ourself-mykc2 ~]# kubectl get pod -o wide
NAME      READY     STATUS    RESTARTS   AGE       IP               NODE
zk-0      1/1       Unknown   0          1d        192.168.165.19   cloud4ourself-mykc3.novalocal
zk-1      1/1       Running   0          2h        192.168.179.67   cloud4ourself-mykc5.novalocal
zk-2      1/1       Running   0          34m       192.168.55.77    cloud4ourself-mykc1.novalocal
17:14:17[root@cloud4ourself-mykc2 ~]# kubectl get pod -o wide
NAME      READY     STATUS    RESTARTS   AGE       IP               NODE
zk-0      1/1       Unknown   0          1d        192.168.165.19   cloud4ourself-mykc3.novalocal
zk-1      1/1       Running   0          2h        192.168.179.67   cloud4ourself-mykc5.novalocal
zk-2      1/1       Running   0          34m       192.168.55.77    cloud4ourself-mykc1.novalocal
17:14:26[root@cloud4ourself-mykc2 ~]# kubectl get pod -o wide
NAME      READY     STATUS    RESTARTS   AGE       IP               NODE
zk-0      1/1       Unknown   0          1d        192.168.165.19   cloud4ourself-mykc3.novalocal
zk-1      1/1       Running   0          2h        192.168.179.67   cloud4ourself-mykc5.novalocal
zk-2      1/1       Running   0          34m       192.168.55.77    cloud4ourself-mykc1.novalocal
17:14:27[root@cloud4ourself-mykc2 ~]# kubectl get pod -o wide
NAME      READY     STATUS              RESTARTS   AGE       IP               NODE
zk-0      0/1       ContainerCreating   0          1s        <none>           cloud4ourself-mykc4.novalocal
zk-1      1/1       Running             0          2h        192.168.179.67   cloud4ourself-mykc5.novalocal
zk-2      1/1       Running             0          34m       192.168.55.77    cloud4ourself-mykc1.novalocal

遇到问题

kubelet 日志报错
Apr 25 16:55:07 cloud4ourself-mykc4 kubelet: E0425 16:55:07.519097    2172 kubelet_volumes.go:114] Orphaned pod "d9b7505c-297d-11e7-917d-fa163ee91167" found, but volume paths are still present on disk.
pod由于volume paths没有被清除，手动到/var/lib/kubelet/pods/下清除该pod

作者：老吕子
链接：http://www.jianshu.com/p/9163585d6780
來源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。