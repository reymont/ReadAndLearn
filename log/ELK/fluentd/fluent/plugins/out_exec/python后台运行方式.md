
python后台运行方式 - CSDN博客 http://blog.csdn.net/youzhouliu/article/details/75948619

在linux中执行python程序时，我们通常会用 python xx.py命令来执行，但这样执行的程序在关闭linux的控制台后，执行的程序就退出了，要让程序关闭后继续执行该怎么办？

要让python程序在关闭控制台后继续执行，我们需要使用到nohub命令。

nohup是linux下的一个命令，其用途为不挂断地运行命令。
执行python时，命令格式如下：
nohup python -u xx.py > log.out 2>&1 &

1、1是标准输出（STDOUT）的文件描述符，2是标准错误（STDERR）的文件描述符1> log.out 简化为 >
log.out，表示把标准输出重定向到log.out这个文件

2、2>&1 表示把标准错误重定向到标准输出，这里&1表示标准输出
为什么需要将标准错误重定向到标准输出的原因，是因为标准错误没有缓冲区，而STDOUT有。

就会导致commond >

log.out 2> 
log.out文件log.out被两次打开，而STDOUT和STDERR将会竞争覆盖，这肯定不是我门想要的