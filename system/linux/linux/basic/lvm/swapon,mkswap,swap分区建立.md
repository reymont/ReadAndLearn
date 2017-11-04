

swapon,mkswap,swap分区建立 - 小子无名 - 51CTO技术博客 
http://linuxroad.blog.51cto.com/765922/705586/

umount /dev/sdb1 
partprobe 


如果我们在装系统时将swap空间分小了，如何扩大swap空间呢？下面再让我们为系统建立新的swap空间吧！
一共分为三个步骤：
1，建立swap分区
2，建立swap文件
3，打开swap功能
<1>用fdisk建立swap分区
下面我以我的160GB的/dev/sdb来实验。先用fdisk建立分区。
[root@fedora15 software]# fdisk /dev/sdb
Command (m for help): p
Disk /dev/sdb: 160.0 GB, 160041885696 bytes 
255 heads, 63 sectors/track, 19457 cylinders, total 312581808 sectors 
Units = sectors of 1 * 512 = 512 bytes 
Sector size (logical/physical): 512 bytes / 512 bytes 
I/O size (minimum/optimal): 512 bytes / 512 bytes 
Disk identifier: 0x624aa2e0 
在这里我们可以看到，我的sdb硬盘共有160G，312581808个扇区，每个扇区大小为512bytes,即两个扇区组成1024bytes=1k.
   Device Boot      Start         End      Blocks   Id  System 
/dev/sdb1   *        2048     1026047      512000   83  Linux 
/dev/sdb2        25174800   312575759   143700480    f  W95 Ext'd (LBA) 
/dev/sdb3         1026048    25174015    12073984   8e  Linux LVM 
/dev/sdb5        25174863   139648319    57236728+   7  HPFS/NTFS/exFAT 
/dev/sdb6       139653108   221568479    40957686    7  HPFS/NTFS/exFAT 
/dev/sdb7       221568543   308383739    43407598+   7  HPFS/NTFS/exFAT 
/dev/sdb8       308383744   312573951     2095104    7  HPFS/NTFS/exFAT
Partition table entries are not in disk order 
可以看到我的磁盘又一个/dev/sdb2的windows扩展分区，其中sdb5-sdb8属于该扩展分区。/dev/sdb1,dev/sdb3属于Linux系统分区。现在我删除/dev/sdb1作为swap分区。
Command (m for help): d 
Partition number (1-8): 1 
Command (m for help): n 
Command action 
   l   logical (5 or over) 
   p   primary partition (1-4) 
p 
Partition number (1-4, default 1): 
Using default value 1 
First sector (2048-312581807, default 2048): 
Using default value 2048 
Last sector, +sectors or +size{K,M,G} (2048-1026047, default 1026047): 821248 
这里821248到底是多少容量呢？这里代表的是821248个扇区，一个扇区512b,所以大小为821248/2/1024=401M.这里也可以用 +401M来指定大小！
Command (m for help): t 
Partition number (1-8): 1 
Hex code (type L to list codes): 82 
Changed system type of partition 1 to 82 (Linux swap / Solaris) 
这里是改变分区的id号，默认分区为linux分区，即id=83.swap代号为82.改好了在确认下。
Command (m for help): p
Disk /dev/sdb: 160.0 GB, 160041885696 bytes 
255 heads, 63 sectors/track, 19457 cylinders, total 312581808 sectors 
Units = sectors of 1 * 512 = 512 bytes 
Sector size (logical/physical): 512 bytes / 512 bytes 
I/O size (minimum/optimal): 512 bytes / 512 bytes 
Disk identifier: 0x624aa2e0
   Device Boot      Start         End      Blocks   Id  System 
/dev/sdb1            2048      821248      409600+  82  Linux swap / Solaris 
/dev/sdb2        25174800   312575759   143700480    f  W95 Ext'd (LBA) 
/dev/sdb3         1026048    25174015    12073984   8e  Linux LVM 
/dev/sdb5        25174863   139648319    57236728+   7  HPFS/NTFS/exFAT 
/dev/sdb6       139653108   221568479    40957686    7  HPFS/NTFS/exFAT 
/dev/sdb7       221568543   308383739    43407598+   7  HPFS/NTFS/exFAT 
/dev/sdb8       308383744   312573951     2095104    7  HPFS/NTFS/exFAT
Partition table entries are not in disk order 
可以看到/dev/sdb1已经是swap格式了！记住这里一定要把它设为82，如果用默认的83的话，后面的命令mkswap就无法进行，会报错的！下面我们写入分区表吧！
Command (m for help): w 
The partition table has been altered!
Calling ioctl() to re-read partition table.
WARNING: Re-reading the partition table failed with error 16: 设备或资源忙. 
The kernel still uses the old table. The new table will be used at 
the next reboot or after you run partprobe(8) or kpartx(8) 
Syncing disks. 
看到没有，警告信息出现了！说是没有更新分区表。内核继续使用原来的分区表！需要重新启动或用partprobe/kpartx来更新分区表！那么我们用partprobe来更新看看！
[root@fedora15 software]# partprobe 
Error: Partition(s) 1 on /dev/sdb have been written, but we have been unable to inform the kernel of the change, probably because it/they are in use.  As a result, the old partition(s) will remain in use.  You should reboot now before making further changes. 
Warning: 无法以读写方式打开 /dev/sr0 (只读文件系统)。/dev/sr0 已按照只读方式打开。
提示更新错误！/dev/sdb1可能在使用。很显然我们需要看看挂载情况了。
[root@fedora15 software]# df -h /dev/sdb* 
文件系统       容量  已用  可用 已用%% 挂载点 
udev                  995M     0  995M   0% /dev 
/dev/sdb1             485M   11M  449M   3% /media/1279ae93-af95-47d9-b45b-b2c920b84554 
udev                  995M     0  995M   0% /dev 
udev                  995M     0  995M   0% /dev 
/dev/sdb5              55G   52G  2.9G  95% /media/Media 
/dev/sdb6              40G   38G  1.4G  97% /media/study 
/dev/sdb7              42G   38G  4.0G  91% /media/software 
udev                  995M     0  995M   0% /dev 
原来/dev/sdb1已经被挂了！难怪更新不成功的。赶紧卸载吧！
```sh
[root@fedora15 media]# umount /dev/sdb1 
[root@fedora15 media]# partprobe 
```
Warning: 无法以读写方式打开 /dev/sr0 (只读文件系统)。/dev/sr0 已按照只读方式打开。
可以看到，当我们卸载后，再次partprobe没有提示sdb1的错误了！更新成功，不用重启了！
<2>将分区变为swap文件
那么，现在看是建立swap文件把！用mkswap来建立！
[root@fedora15 media]# mkswap /dev/sdb1 
Setting up swapspace version 1, size = 409596 KiB 
no label, UUID=925affdc-5621-4452-9cdf-b02cff45a4a6 
好了，swap文件建立了！但是还没有投入使用呢。我们先看看现在的swap大小。
[root@fedora15 media]# free 
             total       used       free     shared    buffers     cached 
Mem:       2056192    1861004     195188          0     329908     348700 
-/+ buffers/cache:    1182396     873796 
Swap:      6291448      15668    6275780 
可以看到将近6G左右的swap空间，这个swap并不合理，内存才2G，swap根本用不找那么大的。反正硬盘空间多。。。呵呵。
<3>开启swap
我们开起/dev/sdb1的swap。
[root@fedora15 media]# swapon /dev/sdb1 
[root@fedora15 media]# free 
             total       used       free     shared    buffers     cached 
Mem:       2056192    1861368     194824          0     330048     348852 
-/+ buffers/cache:    1182468     873724 
Swap:      6701044      15668    6685376 
可以看到，swap空间变大了！大了（6701044-6291448）/1024=400M.还可以用-s来查看现在的swap情况。
[root@fedora15 media]# swapon -s 
Filename    Type  Size Used Priority 
/dev/mapper/vg_fedora1500-LogVol00      partition 4194300 7840 0 
/dev/mapper/vg_fedora15-LogVol00        partition 2097148 7828 0 
/dev/sdb1                               partition 409596 0 -1 
我们也可以用swapoff来关闭swap。
[root@fedora15 media]# swapoff /dev/mapper/vg_fedora15-LogVol00 
[root@fedora15 media]# free 
             total       used       free     shared    buffers     cached 
Mem:       2056192    1886708     169484          0     338372     358456 
-/+ buffers/cache:    1189880     866312 
Swap:      4603896       7828    4596068 
swap变小了将近2G.
<4>用某一文件来作为swap（建系统时没有多余分区，可以这样做）
如果我们没有多余的磁盘分区，但是我们有要建立一个swap，怎么办？有办法！那就是建立一个文件，然后载对文件进行格式化为swap。
[root@fedora15 media]# dd if=/dev/zero of=/tmp/swaptest bs=1M count=512 
记录了512+0 的读入 
记录了512+0 的写出 
536870912字节(537 MB)已复制，5.0684 秒，106 MB/秒
这句话的意思是，从/dev/zero中读取大小为1M的文件512块，也即512M。然后输出到/tmp/swaptest中。那么swaptest也就有512m了。 
[root@fedora15 media]# ll /tmp/swaptest -h 
-rw-r--r--. 1 root root 512M 11月  3 01:17 /tmp/swaptest 
可以看到我们生成了一个512M大小的空文件。
[root@fedora15 media]# mkswap /tmp/swaptest 
Setting up swapspace version 1, size = 524284 KiB 
no label, UUID=2783c331-37a2-41fe-81b2-e229571b0915 
[root@fedora15 media]# free 
             total       used       free     shared    buffers     cached 
Mem:       2056192    1978944      77248          0     174196     661460 
-/+ buffers/cache:    1143288     912904 
Swap:      4194300       7836    4186464 
[root@fedora15 media]# swapon /tmp/swaptest 
[root@fedora15 media]# free 
             total       used       free     shared    buffers     cached 
Mem:       2056192    1979688      76504          0     174332     661844 
-/+ buffers/cache:    1143512     912680 
Swap:      4718584       7836    4710748 
[root@fedora15 media]# swapon -s 
Filename    Type  Size Used Priority 
/dev/mapper/vg_fedora1500-LogVol00      partition 4194300 7836 0 
/tmp/swaptest                           file  524284 0 -1 
可以看到，swap增加成功了！
swap最多能够建立32个，最大为64GB.
 