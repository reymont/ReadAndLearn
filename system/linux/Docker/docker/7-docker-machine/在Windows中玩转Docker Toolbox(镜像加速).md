在Windows中玩转Docker Toolbox(镜像加速) - CSDN博客 http://blog.csdn.net/chengly0129/article/details/68947265

http://www.cnblogs.com/studyzy/p/6113221.html

最近在研究虚拟化，容器和大数据，所以从Docker入手，下面介绍一下在Windows下怎么玩转Docker。
Docker本身在Windows下有两个软件，一个就是Docker，另一个是Docker Toolbox。这里我选择的是Docker Toolbox，为什么呢？参见官方文档：
https://blog.docker.com/2015/08/docker-toolbox/
首先我们从官网下载最新版的Windows Docker Toolbox。安装后会安装一个VirtualBox虚拟机，一个Kitematic，这是GUI管理Docker的工具，没有发布正式版，不推荐使用，另外还有就是我们在命令行下用到的docker-machine和docker命令了。
基本使用

安装完成Toolbox后会有一个Docker Quickstart Terminal的快捷方式，双击运行如果报错，那可能是因为你已经安装了Hyper-v，所以VirtualBox无法用64位的虚拟机。需要卸载Hyper-v。
运行后会在Virtualbox中创建一个叫做default的虚拟机，然后很有可能会卡在waiting for an IP的命令下，然后就死活不动了。我的做法是彻底放弃Docker Quickstart Terminal，根本不用这玩意儿，关掉，我们用PowerShell进行虚拟机的管理。
打开PowerShell，输入：
docker-machine ls
我们可以看到我们当前的Docker虚拟机的状态。如果什么都没有的话，那么我们可以使用以下命令创建一个Docker虚拟机。
docker-machine create --driver=virtualbox default
创建完毕后，我们在用docker-machine ls确认我们的Docker虚拟机在运行中。
然后使用以下命令获得虚拟机的环境变量：
docker-machine env default
然后再输入：
docker-machine env default | Invoke-Expression
这样我们就把当前的PowerShell和虚拟机里面的Docker Linux建立的连接，接下来就可以在PowerShell中使用docker命令了。
比如我们要查看当前有哪些镜像：
docker images
当前有哪些容器：
docker ps –a
其他各种docker命令我就不在这里累述了。
Docker虚拟机文件地址修改

默认情况下，docker-machine创建的虚拟机文件，是保存在C盘的C:\Users\用户名\.docker\machine\machines\default 目录下的，如果下载和使用的镜像过多，那么必然导致该文件夹膨胀过大，如果C盘比较吃紧，那么我们就得考虑把该虚拟机移到另一个盘上。具体操作如下：
1.使用docker-machine stop default停掉Docker的虚拟机。
2.打开VirtualBox，选择“管理”菜单下的“虚拟介质管理”，我们可以看到Docker虚拟机用的虚拟硬盘的文件disk。
3.选中“disk”，然后点击菜单中的“复制”命令，根据向导，把当前的disk复制到另一个盘上面去。
4.回到VirtualBox主界面，右键“default”这个虚拟机，选择“设置”命令，在弹出的窗口中选择“存储”选项。
5.把disk从“控制器SATA”中删除，然后重新添加我们刚才复制到另外一个磁盘上的那个文件。
这是我设置好后的界面，可以看到我在步骤3复制的时候，复制到E:\VirtualBox\default\dockerdisk.vdi文件去了。
image
6.确定，回到PowerShell，我们使用docker-machine start default就可以启动新地址的Docker虚拟机了。确保新磁盘的虚拟机没有问题。就可以把C盘那个disk文件删除了。
【注意：不要在Window中直接去复制粘贴disk文件，这样会在步骤5的时候报错的，报错的内容如下，所以一定要在VirtualBox中去复制！】
Failed to open the hard disk file D:\Docker\boot2docker-vm\boot2docker-vm.vmdk. Cannot register the hard disk 'D:\Docker\boot2docker-vm\boot2docker-vm.vmdk' {9a4ed2ae-40f7-4445-8615-a59dccb2905c} because a hard disk C:\Users\用户名\.docker\machine\machines\default\disk.vmdk' with UUID {9a4ed2ae-40f7-4445-8615-a59dccb2905c} already exists. Result Code: E_INVALIDARG (0x80070057) Component: VirtualBox Interface: IVirtualBox {fafa4e17-1ee2-4905-a10e-fe7c18bf5554} Callee RC: VBOX_E_OBJECT_NOT_FOUND (0x80BB0001)
镜像加速(http://guide.daocloud.io/dcs/docker-9153151.html)

在国内使用Docker Hub的话就特别慢，为此，我们可以给Docker配置国内的加速地址。我看了一下，DaoCloud和阿里云的镜像加速还不错，另外还有网易的蜂巢。选一个就行了。以DaoClound为例，注册账号，然后在https://www.daocloud.io/mirror 就可以看到DaoClound提供给您的镜像加速的URL。然后到PowerShell中去依次执行：
docker-machine ssh default 
sudo sed -i "s|EXTRA_ARGS='|EXTRA_ARGS='--registry-mirror=加速地址 |g" /var/lib/boot2docker/profile 
exit 
docker-machine restart default
这样重启Docker后就可以用国内的镜像来加速下载了。
试一下下载一个mysql看看快不快：
docker pull mysql
下载完镜像，我们运行一个容器：
docker run -d -p 3306:3306 --name mysql -e MYSQL_ROOT_PASSWORD=123 mysql:latest
接下来我们打开windows下的mysql客户端，服务器地址填docker虚拟机的IP地址，通过docker-machine env可以看到，我这里是192.168.99.100，然后用户名root，密码123，这样我们就可以连接到docker容器里面的mysql了。
【注意，Docker容器是在VirtualBox的虚拟机里面，不是在Windows里面，所以不能用127.0.0.1访问】