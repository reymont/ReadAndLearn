

* [Ansible常用模块 - 停止奋斗=停止生命 - 51CTO技术博客 ](http://53cto.blog.51cto.com/9899631/1704690)

Ansible通过模块的方式来完成一些远程的管理工作。可以通过ansible-doc -l查看所有模块，可以使用ansible-doc -s module来查看某个模块的参数，也可以使用ansible-doc help module来查看该模块更详细的信息。下面列出一些常用的模块：

# 1. setup
可以用来查看远程主机的一些基本信息：
ansible -i /etc/ansible/hosts test -m setup

# 2.ping
可以用来测试远程主机的运行状态：
ansible test -m ping

# 3.file
设置文件的属性
file模块包含如下选项：
    force：需要在两种情况下强制创建软链接，一种是源文件不存在但之后会建立的情况下；另一种是目标软链接已存在,需要先取消之前的软链，然后创建新的软链，有两个选项：yes|no
    group：定义文件/目录的属组
    mode：定义文件/目录的权限
    owner：定义文件/目录的属主
    path：必选项，定义文件/目录的路径
    recurse：递归的设置文件的属性，只对目录有效
    src：要被链接的源文件的路径，只应用于state=link的情况
    dest：被链接到的路径，只应用于state=link的情况
    state：
            directory：如果目录不存在，创建目录
            file：即使文件不存在，也不会被创建
            link：创建软链接
            hard：创建硬链接
            touch：如果文件不存在，则会创建一个新的文件，如果文件或目录已存在，则更新其最后修改时间
            absent：删除目录、文件或者取消链接文件
示例：
    ansible test -m file -a "src=/etc/fstab dest=/tmp/fstab state=link"
    ansible test -m file -a "path=/tmp/fstab state=absent"
    ansible test -m file -a "path=/tmp/test state=touch"

# 4.copy
复制文件到远程主机
copy模块包含如下选项：
    backup：在覆盖之前将原文件备份，备份文件包含时间信息。有两个选项：yes|no
    content：用于替代"src",可以直接设定指定文件的值
    dest：必选项。要将源文件复制到的远程主机的绝对路径，如果源文件是一个目录，那么该路径也必须是个目录
    directory_mode：递归的设定目录的权限，默认为系统默认权限
    force：如果目标主机包含该文件，但内容不同，如果设置为yes，则强制覆盖，如果为no，则只有当目标主机的目标位置不存在该文件时，才复制。默认为yes
    others：所有的file模块里的选项都可以在这里使用
    src：要复制到远程主机的文件在本地的地址，可以是绝对路径，也可以是相对路径。如果路径是一个目录，它将递归复制。在这种情况下，如果路径使用"/"来结尾，则只复制目录里的内容，如果没有使用"/"来结尾，则包含目录在内的整个内容全部复制，类似于rsync。
    validate ：The validation command to run before copying into place. The path to the file to validate is passed in via '%s' which must be present as in the visudo example below.
示例：
    ansible test -m copy -a "src=/srv/myfiles/foo.conf dest=/etc/foo.conf owner=foo group=foo mode=0644"
    ansible test -m copy -a "src=/mine/ntp.conf dest=/etc/ntp.conf owner=root group=root mode=644 backup=yes"
    ansible test -m copy -a "src=/mine/sudoers dest=/etc/sudoers validate='visudo -cf %s'"

# 5.command
在远程主机上执行命令
command模块包含如下选项：
    creates：一个文件名，当该文件存在，则该命令不执行
    free_form：要执行的linux指令
    chdir：在执行指令之前，先切换到该指定的目录
    removes：一个文件名，当该文件不存在，则该选项不执行
    executable：切换shell来执行指令，该执行路径必须是一个绝对路径
示例：
    ansible test -a "/sbin/reboot"

# 6.shell
切换到某个shell执行指定的指令，参数与command相同。
示例：
    ansible test -m shell -a "somescript.sh >> somelog.txt"

# 7.service
用于管理服务
该模块包含如下选项：
    arguments：给命令行提供一些选项
    enabled：是否开机启动  yes|no
    name：必选项，服务名称
    pattern：定义一个模式，如果通过status指令来查看服务的状态时，没有响应，就会通过ps指令在进程中根据该模式进行查找，如果匹配到，则认为该服务依然在运行
    runlevel：运行级别
    sleep：如果执行了restarted，在则stop和start之间沉睡几秒钟
    state：对当前服务执行启动，停止、重启、重新加载等操作（started,stopped,restarted,reloaded）
示例：
    ansible test -m service -a "name=httpd state=started enabled=yes"
    ansible test -m service -a "name=foo pattern=/usr/bin/foo state=started"
    ansible test -m service -a "name=network state=restarted args=eth0"

# 8.cron
用于管理计划任务
包含如下选项：
    backup：对远程主机上的原任务计划内容修改之前做备份
    cron_file：如果指定该选项，则用该文件替换远程主机上的cron.d目录下的用户的任务计划
    day：日（1-31，*，*/2,……）
    hour：小时（0-23，*，*/2，……）
    minute：分钟（0-59，*，*/2，……）
    month：月（1-12，*，*/2，……）
    weekday：周（0-7，*，……）
    job：要执行的任务，依赖于state=present
    name：该任务的描述
    special_time：指定什么时候执行，参数：reboot,yearly,annually,monthly,weekly,daily,hourly
    state：确认该任务计划是创建还是删除
    user：以哪个用户的身份执行
示例：
    ansible test -m cron -a 'name="check dirs" hour="5,2" job="ls -alh > /dev/null"'
    ansible test -m cron -a 'name="a job for reboot" special_time=reboot job="/some/job.sh"'
    ansible test -m cron -a 'name="yum autoupdate" weekday="2" minute=0 hour=12 user="root" job="YUMINTERACTIVE=0 /usr/sbin/yum-autoupdate" cron_file=ansible_yum-autoupdate'
    ansilbe test -m cron -a 'cron_file=ansible_yum-autoupdate state=absent'

# 9.filesystem
在块设备上创建文件系统
选项：
    dev：目标块设备
    force：在一个已有文件系统的设备上强制创建
    fstype：文件系统的类型
    opts：传递给mkfs命令的选项

# 10.yum
使用yum包管理器来管理软件包
选项：
    config_file：yum的配置文件
    disable_gpg_check：关闭gpg_check
    disablerepo：不启用某个源
    enablerepo：启用某个源
    list
    name：要进行操作的软件包的名字，也可以传递一个url或者一个本地的rpm包的路径
    state：状态（present，absent，latest）
示例：
    ansible test -m yum -a 'name=httpd state=latest'
    ansible test -m yum -a 'name="@Development tools" state=present'
    ansible test -m yum -a 'name=http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm state=present'
     
# 11.user
管理用户
    home:
    groups:
    uid
    password:
    name:
    createhome:
    system:
    remove:
    state:
    shell:
    需要特别说明的是，password后面指定的密码不能是明文，后面这一串密码会被直接传送到被管理主机的/etc/shadow文件中，而登陆的时候输入的密码会被hash加密以后再去与/etc/shadow中存放的密码去做对比，会出现不一致的现象。所以需要先将密码字符串进行加密处理：openssl passwd -salt -1 "123456"，然后将得到的字符串放到password中即可。

# 12.group
管理组

# 13.synchronize
使用rsync同步文件
    archive
    checksum
    delete
    dest
    src
    dest_port
    existing_only: skip createing new files on receiver
    links
    owner
    mode:(push, pull)
    recursive
    rsync_path
    times:Preserve modification times
示例：
    src=some/relative/path dest=/some/absolute/path rsync_path="sudo rsync"
    src=some/relative/path dest=/some/absolute/path archive=no links=yes
    src=some/relative/path dest=/some/absolute/path checksum=yes times=no
    src=/tmp/helloworld dest=/var/www/helloword rsync_opts=--no-motd,--exclude=.git mode=pull

# 14.mount
配置挂载点
选项：
    dump
    fstype：必选项，挂载文件的类型
    name：必选项，挂载点
    opts：传递给mount命令的参数
    passno
    src：必选项，要挂载的文件
    state：必选项
            present：只处理fstab中的配置
            absent：删除挂载点
            mounted：自动创建挂载点并挂载之
            umounted：卸载
示例：
    name=/mnt/dvd src=/dev/sr0 fstype=iso9660 opts=ro state=present
    name=/srv/disk src='LABEL=SOME_LABEL' state=present
    name=/home src='UUID=b3e48f45-f933-4c8e-a700-22a159ec9077' opts=noatime state=present

    ansible test -a 'dd if=/dev/zero of=/disk.img bs=4k count=1024'
    ansible test -a 'losetup /dev/loop0 /disk.img'
    ansible test -m filesystem 'fstype=ext4 force=yes opts=-F dev=/dev/loop0'
    ansible test -m mount 'name=/mnt src=/dev/loop0 fstype=ext4 state=mounted opts=rw'

# 15.raw
类似command，但可以传递管道
原始出处 :http://breezey.blog.51cto.com/2400275/1555530