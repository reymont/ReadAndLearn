
### 包含文件的最后修改时间
ll xsb90.txt |awk '{print  $6 "-" $7 "-" $8 }'
### 查看时间戳
stat -c %Y  xsb90.txt
### 第一行命令是得到文件的Modify时间在转换成时间格式，在和1970-01-01 00:00:00时间做差等到一个second时间
date +%s -d "`stat -c '%y' file`"
### 第二行是求出系统的时间和1970-01-01 00:00:00时间做差等到一个second时间
date +%s
### 日期格式
date "+%Y-%m-%d %H:%M:%S" -d "`stat -c '%y' file`"


### 参考
# 1. https://blog.csdn.net/u012062455/article/details/77228994
# 2. https://blog.csdn.net/paicmis/article/details/60479639