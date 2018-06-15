

http://www.cnblogs.com/hadex/p/6837688.html



在 docker.service 文件中的 ExecStart 字段中，添加(或：docker run --log-driver=journald)：

--log-driver=journald \
之后：

systemctl daemon-reload
systemctl restart docker.service
配置 journald.conf（此文件的各项正文必须单独占一行，否则不生效） ：

复制代码
[Journal]
#日志存储到磁盘
Storage=persistent 
#压缩日志
Compress=yes 
#为日志添加序列号
Seal=yes 
#每个用户分别记录日志
SplitMode=uid 
#日志同步到磁盘的间隔，高级别的日志，如：CRIT、ALERT、EMERG 三种总是实时同步
SyncIntervalSec=1m 

#即制日志的最大流量，此处指 30s 内最多记录 100000 条日志，超出的将被丢弃
RateLimitInterval=30s 
#与 RateLimitInterval 配合使用
RateLimitBurst=100000

#限制全部日志文件加在一起最多可以占用多少空间，默认值是10%空间与4G空间两者中的较小者
SystemMaxUse=64G 
#默认值是15%空间与4G空间两者中的较大者
SystemKeepFree=1G 

#单个日志文件的大小限制，超过此限制将触发滚动保存
SystemMaxFileSize=128M 

#日志滚动的最大时间间隔，若不设置则完全以大小限制为准
MaxFileSec=1day
#日志最大保留时间，超过时限的旧日志将被删除
MaxRetentionSec=100year 

#是否转发符合条件的日志记录到本机的其它日志管理系统，如：rsyslog
ForwardToSyslog=yes 
ForwardToKMsg=no
#是否转发符合条件的日志到所有登陆用户的终端
ForwardToWall=yes 
MaxLevelStore=debug 
MaxLevelSyslog=err 
MaxLevelWall=emerg 
ForwardToConsole=no 
#TTYPath=/dev/console
#MaxLevelConsole=info
#MaxLevelKMsg=notice
复制代码
之后：

mkdir /var/log/journal
chown root:systemd-journal /var/log/journal
chmod 0770 /var/log/journal
systemctl reset-failed systemd-journald.service && systemctl restart systemd-journald.service
日志查看工具 journalctl 的用法：

复制代码
journalctl
    -u/--unit=docker.service \ #可以多次使用该选项，按 OR 逻辑筛选显示
    -o/--output=export \ #指定显示格式，常用三种： export、json-pretty、cat    
    -r/--reverse \ #反向显示，即较新的日志显示在最上面
    --no-pager \ #不要使用 less 或 more 分页显示
    -f/--follow \ #类似 tail -f 效果
    --flush \ #将内存中日志同步到磁盘
    -D/--directory=DIR \ #指定读取日志的路径
    --file=zLogFilePath \ #同上，指定具体文件路径，可同时使用多次指定多个文件
    --priority= "emerg" (或 0), "alert" (1), "crit" (2), "err" (3), "warning" (4), "notice" (5), "info" (6), "debug" (7) \ #指定要显示的日志等级
    --since= "2012-10-30 18:17:16" \
    --until= "2017-10-30 18:17:16" \
    --disk-usage \ #显示所有日志占用的磁盘空间
#export 格式显示的特定进程的标识字段均可以用作筛选，例如：
    CONTAINER_ID= \ #以指定容器 ID 为标识显示日志
    CONTAINER_NAME= \ #同上，指定容器名称
    _PID= \ #以容器进程 ID 为标识显示日志
    _UID= \ ＃显示以某个用户 ID 身份运行的所有容器日志
复制代码
export 格式输出样例：

 日志输出样例
每个容器对应日志中的多个唯一 ID，可以认为在宿主机上，能够 100％ 标识每一个容器，如：

_BOOT_ID    #标识宿主机是哪次启动的
_MACHINE_ID    #宿主机机器标识
CONTAINER_ID
CONTAINER_ID_FULL
CONTAINER_NAME
外部查看指定容器日志常用命令：

journalctl -u docker.service CONTAINER_ID=bc31bfa22688 -D </Path/To/LogBakDir> -o cat
形如这种的形式的，都是已滚动保存的日志（二进制形式）：

system@6c8acebb0081486ba83d698c06cd1d33-0000000000000001-00054f2c2fe295f9.journal
system@6c8acebb0081486ba83d698c06cd1d33-0000000000000017-00054f2c31c92008.journal
system@6c8acebb0081486ba83d698c06cd1d33-000000000000001d-00054f2c3311307d.journal
最后，将这些滚动日志定时复制或移动到指定位置即可。

自动布署脚本示例: 

复制代码
 1 #!/usr/bin/env sh
 2 
 3 zBakDir="/tmp"
 4 
 5 ###########################
 6 ##### docker.service ######
 7 ###########################
 8 
 9 zDockerPathA="/etc/systemd/system/docker.service"
10 zDockerPathB="/usr/lib/systemd/system/docker.service"
11 
12 if [[ 1 -eq `ls $zDockerPathA 2>/dev/null | wc -l` ]];then
13     zPathToDockerService=$zDockerPathA
14 else
15     zPathToDockerService=$zDockerPathB
16 fi
17 
18 if [[ 0 -lt `grep -c 'log-driver=' $zPathToDockerService` ]];then
19     perl -pi.bak -e 's/(?<=--log-driver=)\w+/journald/g' $zPathToDockerService
20 else
21     perl -pi.bak -e 's/(ExecStart=(\/\S+)+)/$1 --log-driver=journald /g' $zPathToDockerService
22 fi
23 
24 ##############################
25 ## systemd-journald.service ##
26 ##############################
27 
28 zJournaldConfPath="/etc/systemd/journald.conf"
29 zJournaldConf="[Journal]\nStorage=persistent\nCompress=yes\nSeal=yes\nSplitMode=uid\nSyncIntervalSec=30s\n\nRateLimitInterval=30s\nRateLimitBurst=100000\n\nSystemMaxUse=64G\nSystemKeepFree=1G\nSystemMaxFileSize=64M\nMaxFileSec=1day\nMaxRetentionSec=100year"
30 echo -e $zJournaldConf > $zJournaldConfPath
31 
32 mkdir -p /var/log/journal
33 chown -R root:systemd-journal /var/log/journal
34 chmod -R 0770 /var/log/journal
35 
36 ##############################
37 ####  Back up docker log  ####
38 ##############################
39 
40 zPath="/etc/systemd/system"
41 mkdir -p ${zPath}
42 
43 zServName="zDockerLogBakUp"
44 zBakExec="#!/usr/bin/env sh\n\ncp -np /var/log/journal/*/*@*.journal $zBakDir"
45 zBakService="[Unit]\nDescription=''\nAfter=docker.service systemd-journald.service\n\n[Service]\nExecStart=${zPath}/${zServName}.sh\n\n[Install]\nWantedBy=multi-user.target"
46 zBakTimer="[Unit]\nDescription=''\n\n[Timer]\nOnCalendar=*-*-* 02:30:00\nUnit=zDockerLogBakUp.service\n\n[Install]\nWantedBy=multi-user.target"
47 
48 echo -e "$zBakExec" > "${zPath}/${zServName}.sh"
49 echo -e $zBakService > "${zPath}/${zServName}.service"
50 echo -e $zBakTimer > "${zPath}/${zServName}.timer"
51 
52 chmod u+x ${zPath}/${zServName}.sh
53 
54 ##############################
55 ####    Start Services    ####
56 ##############################
57 
58 systemctl daemon-reload
59 systemctl reset-failed docker.service
60 systemctl restart docker.service
61 
62 systemctl reset-failed systemd-journald.service
63 systemctl restart systemd-journald.service
64 
65 systemctl enable ${zServName}.timer
复制代码
...

HADEX_ FROM HELL.