linux修改用户名和密码 - 四季写爱 - 博客园 https://www.cnblogs.com/ya-qiang/p/9158435.html

修改root密码：sudo passwd root

修改用户密码（如hadoop） sudo passwd hadoop

修改主机名：sudo vi /etc/hostname 将其中的名字改为自己的名字

修改用户名：sudo  vi /etc/passwd 找到原先的用户名，将其改为自己的用户名，但是/home/“原先用户名” 中的不能更改，若更改重启后，便登陆不了系统了。

sudo     vi /etc/shadow 找到原先用户名，改为自己的用户名

以上步骤完毕后，sudo reboot重启

重启后，进入系统，发现 home 目录下用户目录还是原先用户名，但是用命令 ls -al 可以看到起用户目录所属用户已变更为你自己的用户了，下面用 “mv 用户目录名 自己的用户目录名”将目录名更改下就可以了。例如原先目录名为xxxx 现要改为用户 yyyy。用命令 mv xxxx yyyy即可。

这时候重启reboot

切记：重启后，sudo vi /etc/passwd 修改/home/“原先用户名” 中用户名为现在用户名

现在重启就可以了