

Ansible5：常用模块 - 无名小卒 - 51CTO技术博客 

http://breezey.blog.51cto.com/2400275/1555530/


十三、unarchive模块
用于解压文件，模块包含如下选项：
copy：在解压文件之前，是否先将文件复制到远程主机，默认为yes。若为no，则要求目标主机上压缩包必须存在。
creates：指定一个文件名，当该文件存在时，则解压指令不执行
dest：远程主机上的一个路径，即文件解压的路径 
grop：解压后的目录或文件的属组
list_files：如果为yes，则会列出压缩包里的文件，默认为no，2.0版本新增的选项
mode：解决后文件的权限
src：如果copy为yes，则需要指定压缩文件的源路径 
owner：解压后文件或目录的属主
示例如下：
- unarchive: src=foo.tgz dest=/var/lib/foo
- unarchive: src=/tmp/foo.zip dest=/usr/local/bin copy=no
- unarchive: src=https://example.com/example.zip dest=/usr/local/bin copy=no