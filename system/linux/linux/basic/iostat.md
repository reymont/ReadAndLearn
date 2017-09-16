
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [安装](#安装)
* [Linux下的/dev/sr0、/dev/cdrom、df命令、free命令](#linux下的devsr0-devcdrom-df命令-free命令)
* [Linux 内核中的 Device Mapper 机制](#linux-内核中的-device-mapper-机制)
* [查找 iostat 命令列出的dm-xx设备-GangLin_Lan-ChinaUnix博客](#查找-iostat-命令列出的dm-xx设备-ganglin_lan-chinaunix博客)
	* [iostat](#iostat)
	* [sar](#sar)
	* [dmsetup](#dmsetup)

<!-- /code_chunk_output -->
---

# 安装

```sh
yum install -y sysstat
# 使用该命令查看磁盘IO的读写情况了，看是否存在IO问题
iostat
iostat -x
```

# Linux下的/dev/sr0、/dev/cdrom、df命令、free命令

* [Linux下的/dev/sr0、/dev/cdrom、df命令、free命令 - - CSDN博客 ](http://blog.csdn.net/u012110719/article/details/42263729)

/dev/sr0是光驱的设备名，/dev/cdrom代表光驱

cdrom是sr0的软链接.你ll /dev/cdrom和ll /dev/sr0看看显示

用df命令查看磁盘驱动器当前的可用空间，用free显示当前可用内存

# Linux 内核中的 Device Mapper 机制

* [Linux 内核中的 Device Mapper 机制 ](https://www.ibm.com/developerworks/cn/linux/l-devmapper/)

本文结合具体代码对 Linux 内核中的 device mapper 映射机制进行了介绍。Device mapper 是 Linux 2.6 内核中提供的一种从逻辑设备到物理设备的映射框架机制，在该机制下，用户可以很方便的根据自己的需要制定实现存储资源的管理策略，当前比较流行的 Linux 下的逻辑卷管理器如 LVM2（Linux Volume Manager 2 version)、EVMS(Enterprise Volume Management System)、dmraid(Device Mapper Raid Tool)等都是基于该机制实现的。理解该机制是进一步分析、理解这些卷管理器的实现及设计的基础。通过本文也可以进一步理解 Linux 系统块一级 IO的设计和实现。

# 查找 iostat 命令列出的dm-xx设备-GangLin_Lan-ChinaUnix博客

* [查找 iostat 命令列出的dm-xx设备-GangLin_Lan-ChinaUnix博客 ](http://blog.chinaunix.net/uid-26230811-id-3265484.html)


## iostat

使用iostat查看磁盘io状态时，Device列显示了多个dm-xxx，但是不知道具体的设备路径。

```
[root@server2 ~]# iostat 1
avg-cpu: %user %nice %system %iowait %steal %idle
           0.00 0.00 0.00 0.00 0.00 100.00

Device: tps Blk_read/s Blk_wrtn/s Blk_read Blk_wrtn
sda 0.00 0.00 0.00 0 0
sda1 0.00 0.00 0.00 0 0
sda2 0.00 0.00 0.00 0 0
sdb 0.00 0.00 0.00 0 0
sdb1 0.00 0.00 0.00 0 0
sdc 0.00 0.00 0.00 0 0
hdc 0.00 0.00 0.00 0 0
dm-0 0.00 0.00 0.00 0 0
dm-1 0.00 0.00 0.00 0 0
dm-2 0.00 0.00 0.00 0 0
```

## sar

使用sar命令查看详细的dm-xxx信息

```sh
[root@server2 ~]# sar -d 1
Linux 2.6.18-274.el5 (server2.lanv.com) 07/06/2012
01:00:26 PM DEV tps rd_sec/s wr_sec/s avgrq-sz avgqu-sz await svctm %util
01:00:27 PM dev8-0 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00
01:00:27 PM dev8-1 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00
01:00:27 PM dev8-2 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00
01:00:27 PM dev8-16 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00
01:00:27 PM dev8-17 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00
01:00:27 PM dev8-32 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00
01:00:27 PM dev22-0 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00
01:00:27 PM dev253-0 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00
01:00:27 PM dev253-1 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00
01:00:27 PM dev253-2 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00
可以知道dm-0、dm-1、dm-2的主设备号是253（是linux内核留给本地使用的设备号），次设备号分别是0、1、2，这类设备在/dev/mapper中

[root@server2 mapper]# cd /dev/mapper/
[root@server2 mapper]# ll
total 0
crw------- 1 root root 10, 63 Jul 6 11:14 control
brw-rw---- 1 root disk 253, 0 Jul 6 11:25 vg01-lanv1
brw-rw---- 1 root disk 253, 1 Jul 6 11:26 vg01-lanv2
brw-rw---- 1 root disk 253, 2 Jul 6 11:26 vg01-lanv3
```

## dmsetup

以上信息也可以使用dmsetup命令查看

```sh
[root@server2 mapper]# dmsetup ls
vg01-lanv3 (253, 2)
vg01-lanv2 (253, 1)
vg01-lanv1 (253, 0)
看到dm-0、dm-1、dm-2的详细设备名后，知道这三个设备是属于vg01逻辑卷组的lvm设备。

[root@server2 mapper]# cd /dev/vg01/
[root@server2 vg01]# ll
total 0
lrwxrwxrwx 1 root root 22 Jul 6 11:25 lanv1 -> /dev/mapper/vg01-lanv1
lrwxrwxrwx 1 root root 22 Jul 6 11:26 lanv2 -> /dev/mapper/vg01-lanv2
lrwxrwxrwx 1 root root 22 Jul 6 11:26 lanv3 -> /dev/mapper/vg01-lanv3
现在可以知道dm-0、dm-1、dm-2的具体设备路径了
```
 
关于mapper， 是 Linux2.6 内核中支持**逻辑卷管理的通用设备映射机制**，它为实现用于存储资源管理的块设备驱动提供了一个高度模块化的内核架构，请参考：Linux 内核中的 Device Mapper 机制
关于每个主设备号和次设备号对应设备的功能，请参考：http://lxr.linux.no/linuxv2.6.38.8/Documentation/devices.txt