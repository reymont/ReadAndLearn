

删的不彻底如何彻底删除Linux文件(多种方法)_LINUX_操作系统_脚本之家 
http://www.jb51.net/LINUXjishu/265078.html

linux删除目录很简单，很多人还是习惯用rmdir，不过一旦目录非空，就陷入深深的苦恼之中，现在使用rm -rf命令即可。
直接rm就可以了，不过要加两个参数-rf 即：rm -rf 目录名字
删除目录、文件 rm（remove）
功能说明：删除文件或目录。
语法：rm ［-dfirv］［--help］［--version］［文件或目录。。.］
补充说明：执行rm指令可删除文件或目录，如欲删除目录必须加上参数”-r”，否则预设仅会删除文件。
参数：
-d或–directory 　直接把欲删除的目录的硬连接数据删成0，删除该目录。
-f或–force 　强制删除文件或目录。
-i或–interactive 　删除既有文件或目录之前先询问用户。
-r或-R或–recursive 　递归处理，将指定目录下的所有文件及子目录一并处理。
-v或–verbose 　显示指令执行过程。
1 删除文件夹
de》rm -rf fileNamede》
-删除文件夹实例：
rm -rf /var/log/httpd/access
将会删除/var/log/httpd/access目录以及其下所有文件、文件夹
需要提醒的是：使用这个rm -rf的时候一定要格外小心，linux没有回收站的
2 删除文件
de》rm -f fileNamede》
使用 rm -rf 的时候一定要格外小心，linux没有回收站的
删除指定文件之外的其他文件
一、Linux下删除文件和文件夹常用命令如下：
删除文件： rm file
删除文件夹： rm -rf dir
需要注意的是， rmdir 只能够删除 空文件夹。
二、删除制定文件（夹）之外的所有文件呢？
1、方法1，比较麻烦的做法是：
复制需要保留的文件到其他文件夹，然后将该目录删除， 然后将需要保留的移动 回来。
mv keep 。。/ #保留文件（夹） keep
rm -rf * #删除当前文件夹里的所有文件
mv 。。/keep 。/ #将原来的东西移动回来
2、方法2，需要在当前文件夹中进行：
rm -rf ！（keep） #删除keep文件之外的所有文件
rm -rf ！（keep1 | keep2） #删除keep1和keep2文件之外的所有文件
Linux中彻底删除文件


# shred彻底删除文件的方法：
$ shred -u file
shred会用一些随机内容覆盖文件所在的节点和数据块，并删除文件（-u参数）。
如果想清除的更彻底一点可以加-z 参数，意思是先用随机数据填充，最后再用0填充。
$ shred -u -z file
另外shred还可以清除整个分区或磁盘，比如想彻底清除/dev/sdb1分区的内容可以这样：
$ shred /dev/sdb1 （注意不要加-u参数）
shred的详细参数：
-f， --force 更改权限允许写入（如有必要）
-n， --iterations=N 重写N次，默认为3次
--random-source=FILE 从指定文件读取数据
-s， --size=N 将文件粉碎为固定大小 （可使用后缀如K、M、C等）
-u， --remove 重写后截短并移除文件
-v， --verbose 显示进度
-z， --zero - add 用0覆盖数据
–help 显示帮助
–version 显示版本信息
上面就是Linux下彻底删除文件的方法介绍了，需要特别注意的是，因为Linux没有回收站，在使用彻底删除的时候要特别小心，rm -rf命令不可随意乱用。