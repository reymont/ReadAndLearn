

Linux系统下强制踢掉登录用户-greendays-ChinaUnix博客 
http://blog.chinaunix.net/uid-639516-id-2692539.html

linux系统root用户可强制踢制其它登录用户，首先可用＄w命令查看登录用户信息，显示信息如下：
      [root@Wang ~]# w
     
    强制踢人命令格式：pkill -kill -t tty
    解释：
    pkill -kill -t 　踢人命令
   tty　所踢用户的TTY
   如上踢出liu用户的命令为： `pkill -kill -t pts/1`
   首先用命令查看pts/0的进程号，命令如下：
   [root@Wang ~]# ps -ef | grep pts/0
   root     15846 15842 0 10:04 pts/0    00:00:00 bash
   root     15876 15846 0 10:06 pts/0    00:00:00 ps -ef
   root     15877 15846 0 10:06 pts/0    00:00:00 grep pts/0
   踢掉用户的命令：
   kill -9 15846