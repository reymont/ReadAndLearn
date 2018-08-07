

find 指令a/c/m -time的用法区别

stat可以查看文件的atime、ctime、mtime
[root@localhost ~]$ stat file
Size: 49 Blocks: 8 IO Block: 4096 regular file
Device: fd00h/64768d Inode: 458037 Links: 1
Access: (0644/-rw-r--r--) Uid: ( 500/ oracle) Gid: ( 500/oinstall)
Access: 2015-07-10 11:46:05.000000000 +0800  --> -atime
Modify: 2015-07-10 11:44:37.000000000 +0800  --> -mtime
Change: 2015-07-10 11:44:37.000000000 +0800  --> -ctime

atime  最近访问 atime 及 access time 文件最近访问的时间，当你用cat,more,vi等指令访问一个文件时，atime都会更新。
mtime  最近更改 mtime 及 modify time 文件最近改动的时间，当你对文件改动修改内容时会改变这个时间。
ctime  最近改动 ctime 及 change time 文件最近状态（status）的改变时间。

这里的status指权限，用户，组，修改时间。如果这些东西改变，那么ctime会随之改变
find . –atimen        find . –ctimen            find . –mtimen

即在访问时间后面加个修饰，修饰时间的范围
n指的是24(hour)*n, +n、-n、n分别表示：

+n for greater than n (大于n) 
-n for less than n(小于n)
n for exactly n(等于n)

https://blog.csdn.net/nightfall_/article/details/51477862