

### 1. 查看所有java的情况
ps -ef|grep java|awk '{print $2}'|xargs -n1 jstat -gcutil
# -t 同时输出命令
ps -ef|grep java|awk '{print $2}'|xargs -t -n1 jstat -gcutil