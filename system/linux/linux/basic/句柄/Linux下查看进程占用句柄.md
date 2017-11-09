

Linux下查看进程占用句柄 - CSDN博客 
http://blog.csdn.net/genius_lg/article/details/39206545

执行 ps -ef | grep 进程名称 ，使用root账号获取进程ID（下图中进程ID为5683，11611为其父进程ID）。
执行 ls -l /proc/进程ID/fd | wc -l ，查看句柄数量（下图中ID为5683的进程句柄数量为67）。
