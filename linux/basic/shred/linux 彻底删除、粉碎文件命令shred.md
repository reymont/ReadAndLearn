

linux 彻底删除、粉碎文件命令shred - CSDN博客 
http://blog.csdn.net/nanyun2010/article/details/6987458

shred是一条终端命令，功能是重复覆盖文件，使得即使是昂贵的硬件探测仪器也难以将数据复原，（参见”shred –help”）。这条命令的功能足够适合实现文件粉碎的功效。

 
tiny@tiny-laptop:~$ shred --help
用法：shred [选项]... 文件...
多次覆盖文件，使得即使是昂贵的硬件探测仪器也难以将数据复原。

长选项必须使用的参数对于短选项时也是必需使用的。
  -f, --force 必要时修改权限以使目标可写
  -n, --iterations=N 覆盖N 次，而非使用默认的3 次
      --random-source=文件 从指定文件中取出随机字节
  -s, --size=N 粉碎数据为指定字节的碎片(可使用K、M 和G 作为单位)
  -u, --remove 覆盖后截断并删除文件
  -v, --verbose 显示详细信息
  -x, --exact 不将文件大小增加至最接近的块大小
  -z, --zero 最后一次使用0 进行覆盖以隐藏覆盖动作
      --help 显示此帮助信息并退出
      --version 显示版本信息并退出

如果指定文件为"-"，粉碎标准输出的数据。

如果加上--remove (-u)选项表示删除文件。默认的方式是不删除文件，因为
覆盖像/dev/hda 等的设备文件是很普遍的，而这些文件通常不应删除。当覆盖
一般文件时，绝大多数人都会使用--remove 选项。

警告：请注意使用shred 时有一个很重要的条件：
文件系统会在原来的位置覆盖指定的数据。传统的文件系统符合此条件，但许多现代
的文件系统都不符合条件。以下是会令shred 无效或不担保一定有效的文件系统的
例子：
* 有纪录结构或是日志式文件系统，如AIX 及Solaris 使用的文件系统 (以及
   JFS、ReiserFS、XFS、Ext3 等)
* 会重复写入数据，及即使一部份写入动作失败后仍可继续的文件系统，如使用
   RAID 的文件系统
* 会不时进行快照记录的文件系统，像Network Applicance 的NFS 服务器
* 文件系统是存放于缓存位置，比如NFS 第三版用户端
* 压缩文件系统
在Ext3 文件系统中，以上免责声明仅适用于启用了data=journal 模式的情况，
此时文件日志记录了附加的元数据 shred 的作用将受到影响。在data=ordered(默认)
或data=writeback 模式下shred 仍然有效。
Ext3 日志模式可通过向/etc/fstab 的挂载选项中添加data=something 进行设置，
您可以查看mount 的man 页面以获得详细信息。
另外，文件系统备份和远程镜像可能会
包含不能被删除的文件副本，这将会
允许碎片文件被恢复。
 

使用方法举例如下：
粉碎一个名为test.txt的文件命令是： 
$shred test.txt 
粉碎多个文件的命令是： 
$shred test1.txt test2.txt
这两条命令的效果是文件依旧存在，但不再是原来的文件了，对比测试可以通过先编辑一个文本文件后保存，然后使用shred命令覆盖此文件，再打开该文本文件即可看出内容不再是原有内容了。如果想要覆盖的同时删除文件（这才是粉碎的表现么），加上参数 -u，命令变为： 
$shred –u test.txt
覆盖一个挂载分区的文件命令是： 
$shred /dev/hda0        //覆盖IDE接口的第一个磁盘设备的第一分区 
$shred /dev/sda2        //覆盖SCSI或SATA接口的第一个磁盘设备的第三分区

 
在终端下使用shred命令来进行文件粉碎操作实在不方便，得益于Nautilus的可扩展性，我们可以给Ubuntu的Nautilus添加右键菜单来执行shred操作：
在终端下输入命令安装Nautilus-actions（中文名被汉化为“Nautilus动作配置”）： 
$sudo apt-get install nautilus-actions
然后单击“系统” –> “首选项” –> “Nautilus动作配置” ->单击“Define a new action”按钮
 
然后在“添加新动作”窗口中输入以下信息：
Context Label: Shred粉碎                             //你可以随便想一个名字，这里是显示在右键菜单的名字 
Tool tip: Shred粉碎机                     //一样可以随便想一个描述，这是停留在右键菜单的提示 
Icon: gtk-dialog-warning                   //可以单击Browse或者下拉菜单中选择一个图标 
路径: shred 
参数: -f -u -v -z %M

然后单击“Record all the modified”标签卡，如果只需要这个粉碎右键菜单出现在仅处理文件的时候，那么就单击“仅文件”单选框，同理如果需要出现在仅处理文件夹的时候就单击“仅文件夹”单选框，如果需要文件和文件夹上右键都能出现该粉碎菜单，那么单击“Both”单选框。另外勾选“Appears if selection has multiple files or folders”复选框
 

 
在单击“确定”按钮之后返回“Nautilus动作”窗口，单击“关闭”按钮之后再在终端中输入命令： 
$nautilus –q     //关闭Nautilus进程 
$nautilus         //启动Nautilus进程
这时候再进入主文件夹对一个文件右击，菜单中将出现“Shred粉碎”