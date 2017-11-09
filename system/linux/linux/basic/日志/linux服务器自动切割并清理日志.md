

linux服务器自动切割并清理日志 - CSDN博客
 http://blog.csdn.net/hzlsimple/article/details/51103665

需求

由于nginx的日志会不停地增大，所以需要我们自己去切割日志，方便管理，需要达到以下的效果：

按日期自动切割日志，最小单位是天。
当日志总量超过一定量时，自动直接清理日志，限定总量不能超过1000MB。
写入crontab定时任务里。
分析

nginx日志目录下分别有access.log和error.log，按照日期自动切割日志则需要将每天的日志以”yyyymmdd_access/error.log”的格式保存下来，用mv重命名每一天的日志文件即可。
清理日志就简单了，只需要判断这个文件夹下的大小，然后将一定日期之前的日志文件清理掉就ok了。
crontab任务也比较简单，详情可以看这里。
问题的关键在于，用mv重命名完昨天的日志文件后，nginx还是会向这个重命名后的文件（如access_20160409.log）写入日志，我们的目的是需要使nginx重新生成一个新的日志文件（access.log）并写入。
As we all know，linux系统下一切都是文件，所以每一个进程都有其文件描述符，而nginx进程将其自己的文件描述符写入了nginx.pid中，我们需要告诉nginx，让其重新打开一个新的日志文件（日志文件的配置详情可看这里，简单说就是让日志记录什么内容。）于是我们需要这条指令：

kill -USR1 `cat ${pid_path}`

这条指令的意思是：首先cat到nginx的pid，是一个整数，然后将信号USR1发送给这个进程，nginx进程收到这个信号后，会根据配置重新打开一个新的日志文件，并将日志写入。

实现

脚本cut_nginx_log.sh:

```sh
#!/bin/bash
log_path=/path/to/nginx/
pid_path=/path/to/nginx.pid

#清理掉指定日期前的日志
DAYS=30

#生成昨天的日志文件
mv ${log_path}access.log ${log_path}access_$(date -d "yesterday" +"%Y%m%d").log
mv ${log_path}error.log ${log_path}error_$(date -d "yesterday" +"%Y%m%d").log

kill -USR1 `cat ${pid_path}`

#文件夹大小
size=`du -b /path/to/nginx/ | awk '{print int($1/1024/1024)}'`

if [size -gt 1000];then
    find ${logs_path} -name "access_*" -type f -mtime +$DAYS -exec rm {} \;
    find ${logs_path} -name "error_*" -type f -mtime +$DAYS -exec rm {} \;
fi
```

添加至crontab： 
(每天零点自动执行)

crontab -e
0 0 * * * /path/to/script
至此就解决了自动切割并清理日志的功能，有问题的欢迎提出。