

* [linux scp命令参数及用法详解--linux远程复制拷贝命令使用实例 - 菜鸟の轨迹 - CSDN博客 ](http://blog.csdn.net/jiangkai_nju/article/details/7338177)

一般情况，本地网络跟远程网络进行数据交抱，或者数据迁移，常用的有三种方法，一是ftp,二是wget /fetch 三是，rsync 大型数据迁移用rysync，其次用fetch/wget ，最次是ftp，最慢是ftp.这几天，在忙数据迁移时，用到ssh的scp方法来迁移数据。速度与效果都很好。特别是现在许多服务器为了安全，都会改ssh默认的22端口，改成一个特殊的端口。所以。在scp或者sftp时，就要指定通过什么端口来迁移。现在，特记下这个特殊端口来scp的命令。
Linux scp命令用于linux之间复制文件和目录，具体如何使用这里好好介绍一下，从本地复制到远程、从远程复制到本地是两种使用方式。这里有具体举例：

# Linux scp 命令

scp 可以在 2个 linux 主机间复制文件；
命令基本格式：
scp [可选参数] file_source file_target

从 本地 复制到 远程
# 复制文件：
命令格式：

```sh

scp local_file remote_username@remote_ip:remote_folder
或者
scp local_file remote_username@remote_ip:remote_file
或者
scp local_file remote_ip:remote_folder
或者
scp local_file remote_ip:remote_file
第1,2个指定了用户名，命令执行后需要再输入密码，第1个仅指定了远程的目录，文件名字不变，第2个指定了文件名；
第3,4个没有指定用户名，命令执行后需要输入用户名和密码，第3个仅指定了远程的目录，文件名字不变，第4个指定了文件名；
* 例子：
scp /home/space/music/1.mp3 root@www.cumt.edu.cn:/home/root/others/music
scp /home/space/music/1.mp3 root@www.cumt.edu.cn:/home/root/others/music/001.mp3
scp /home/space/music/1.mp3 www.cumt.edu.cn:/home/root/others/music
scp /home/space/music/1.mp3 www.cumt.edu.cn:/home/root/others/music/001.mp3
```

# 复制目录：
```sh

* 命令格式：
scp -r local_folder remote_username@remote_ip:remote_folder
或者
scp -r local_folder remote_ip:remote_folder
第1个指定了用户名，命令执行后需要再输入密码；
第2个没有指定用户名，命令执行后需要输入用户名和密码；
* 例子：
scp -r /home/space/music/ root@www.cumt.edu.cn:/home/root/others/
scp -r /home/space/music/ www.cumt.edu.cn:/home/root/others/
```

上面 命令 将 本地 music 目录 复制 到 远程 others 目录下，即复制后有 远程 有 ../others/music/ 目录

# 从 远程 复制到 本地

从 远程 复制到 本地，只要将 从 本地 复制到 远程 的命令 的 后2个参数 调换顺序 即可；
例如：
scp root@www.cumt.edu.cn:/home/root/others/music /home/space/music/1.mp3
scp -r www.cumt.edu.cn:/home/root/others/ /home/space/music/
最简单的应用如下 :
scp 本地用户名 @IP 地址 : 文件名 1 远程用户名 @IP 地址 : 文件名 2
[ 本地用户名 @IP 地址 :] 可以不输入 , 可能需要输入远程用户名所对应的密码 .
可能有用的几个参数 :
-v 和大多数 linux 命令中的 -v 意思一样 , 用来显示进度 . 可以用来查看连接 , 认证 , 或是配置错误 .
-C 使能压缩选项 .
-P 选择端口 . 注意 -p 已经被 rcp 使用 .
-4 强行使用 IPV4 地址 .
-6 强行使用 IPV6 地址 .
Linux scp命令的使用方法应该可以满足大家对Linux文件和目录的复制使用了。


# 关于scp的安全方面
copy 本地的档案到远程的机器上
scp /etc/lilo.conf k@net67.ee.oit.edu.tw:/home/k
会将本地的 /etc/lilo.conf 这个档案 copy 到 net67.ee.oit.edu.tw，使用者 k 的家目录下。
copy远程机器上的档案到本地来
scp k@net67.ee.oit.edu.tw:/etc/lilo.conf /etc
会将 net67.ee.oitdu.tw 中 /etc/lilo.conf 档案 copy 到本地的 /etc 目录下。
保持从来源 host 档案的属性
scp –p k@net67.ee.tw:/etc/lilo.conf /etc
如果想使用特定端口 使用 scp –p（大写） 如 scp –p 1234 k@net67.ee.tw:/etc/lilo.conf /etc

# ssh-keygen

在此必须注意使用者的权限是否可读取远程上的档案，若想知道更多关于 scp 的使用方法，可去看看 scp 的使用手册。
ssh-keygen
产生公开钥 (pulib key) 和私人钥 (private key)，以保障 ssh 联机的安性， 当 ssh 连 shd 服务器，会交换公开钥上，系统会检查 /etc/ssh_know_hosts 内储存的 key，如果找到客户端就用这个 key 产生一个随机产生的session key 传给服务器，两端都用这个 key 来继续完成 ssh 剩下来的阶段。

它会产生 identity.pub、identity 两个档案，私人钥存放于identity，公开钥 存放于 identity.pub 中，接下来使用 scp 将 identity.pub copy 到远程机器的家目录下.ssh下的authorized_keys。 .ssh/authorized_keys(这个 authorized_keys 档案相当于协议的 rhosts 档案)， 之后使用者能够不用密码去登入。RSA的认证绝对是比 rhosts 认证更来的安全可靠。
执行：
scp identity.pub k@linux1.ee.oit.edu.tw:.ssh/authorized_keys

若在使用 ssh-keygen 产生钥匙对时没有输入密码，则如上所示不需输入密码即可从 net67.ee.oit.edu.tw 去登入 linux1.ee.oit.edu.tw。在此，这里输入的密码可以跟帐号的密码不同，也可以不输入密码。