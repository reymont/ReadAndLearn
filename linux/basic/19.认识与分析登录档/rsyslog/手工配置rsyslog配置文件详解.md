
手工配置rsyslog配置文件详解 - arun_yh - 博客园 
https://www.cnblogs.com/itcomputer/p/6241421.html


手工配置

如果您无法通过脚本生成配置文件，这份指导将帮助您通过简单的复制、粘贴手动完成配置。

假定您已拥有root或sudo权限，是在通用的Linux平台使用5.8.0或更高版本的rsyslog，rsyslog能接收本地系统日志，并通过5140端口与外界连接。

1 配置系统环境

粘贴以下脚本并运行，并且保证 /var/spool/rsyslog 目录已存在，如果是Ubuntu系统，还需要对目录进行权限设置。

sudo mkdir -v /var/spool/rsyslog 
if [ "$(grep Ubuntu /etc/issue)" != "" ]; then 
sudo chown -R syslog:adm /var/spool/rsyslog 
fi
2 更新rsyslog配置文件。

打开rsyslog配置文件，它通常在 /etc/ 目录下

sudo vim /etc/rsyslog.d/rizhiyi.conf
将下列内容粘贴在这个配置文件中

复制代码
#real tran log
$ModLoad imfile 　　　　　　　　　　　　　　#装载imfile模块
$InputFilePollInterval 3 　　　　　　　　 #检查日志文件间隔（秒）
$WorkDirectory /var/spool/rsyslog       #定义工作目录。例如队列文件存储存储文件夹。

$InputFileName FILEPATH 　　　　　　　　　 #读取日志文件
$InputFileTag APPNAME 　　　　　　　　　　 #日志写入日志附加标签字符串 不要添加特殊符号
$InputFileStateFile stat_APPNAME 　　　　#定义记录偏移量数据文件名 不要添加特殊符号
$InputFileSeverity info 　　　　　　　　　#日志等级
$InputFilePersistStateInterval 20000    #回写偏移量数据到文件间隔时间（秒）
$RepeatedMsgReduction off 　　　　　　　　#关闭重复消息控制
$InputRunFileMonitor 　　　　　　　　　　　#This activates the current monitor. It has no parameters. If you forget this directive, no file monitoring will take place.
#https://www.rizhiyi.com/docs/fastuse/tag/  设置标签(rsyslog)
$template RizhiyiFormat_APPNAME,"<%pri%>%protocol-version% %timestamp:::date-rfc3339% %HOSTNAME% %app-name% %procid% %msgid% [06f69fae723038bbc5d75d29564051ea@32473     tag=\"TAG\"] %msg%\n" 
                                  #<85>          0    2014-09-14T16:52:59.814155+08:00   macbook    my_app       -      -   [91595477-c8e4-42b8-b1f9-696465b422ff@32473 tag="file_upload" tag="my_tag"]
复制代码
if $programname == 'APPNAME' then @@log.rizhiyi.com:5140;RizhiyiFormat_APPNAME 
if $programname == 'APPNAME' then ~

---------------------------------------------------------------对应的单台测试机的配置如下---------------------------------------------------------------------------------------


并替换

FILEPATH: 需要上传的日志文件的绝对路径，必须包含日志文件名。 
示例：/var/log/nginx/access.log
APPNAME: 用于标识上传的唯一应用来源，可用来定义日志分组，这将帮助您有效划分日志，缩小搜索范围。APPNAME设置正确与否直接影响到后台对日志字段的提取。如果您是VIP用户，日志易为您定制了日志解析规则，请填写日志易提供的针对该日志的APPNAME，以使定制的日志解析规则生效。 
示例： nginx_access
TAG: 标签，标识日志的扩展信息，可定义多个标识，这里替换为您自行定义的标签，可用来定义日志分组，这将帮助您有效划分日志，缩小搜索范围。 
示例： rizhiyi_search
注意:

在 /etc/rsyslog.d/ 下的rsyslog配置文件中：
$InputFileTag定义的APPNAME必须唯一，同一台主机上不同的应用应当使用不同的APPNAME，否则会导致新定义的TOKEN和TAG不生效；
$template定义的模板名必须唯一，否则会导致新定义的TOKEN和TAG不生效；
$InputFileStateFile定义的StateFile必须唯一，它被rsyslog用于记录文件上传进度，否则会导致混乱；
注意：@@log.rizhiyi.com:5140 该值为接收日志的服务器域名或者主机名。默认是log.rizhiyi.com:5140
3 重启rsyslog

$ sudo service rsyslog restart
4 验证

例如，配置文件中的tag字段已修改为"rizhiyi_search"，可使用"tag:rizhiyi_search"搜索过去一小时的事件，检查日志易是否成功接收并正确识别日志，建立索引可能需要几十秒钟时间，需要等待几十秒钟。

#参考:

http://www.voidcn.com/blog/anghlq/article/p-4958086.html

http://www.wnqzw.com/article/10798.html

附:

日志輸出模板
通過模板可以更具需要來控制日志輸出的樣式。格式如下：
$template <TEMPLATE_NAME>,"text %<PROPERTY>% more text", [<options>]
$template 爲模板指令。<TEMPLATE_NAME> 爲模板名。"" 之間的文本爲模板格式。 被 % 包含的文本對應相關的屬性。<options> 指定修改 模板功能的一些選項,例如 sql 或者 stdsql 會格式化文本爲 SQL 查詢。
動態文件輸出
通過日志和/或系統屬性決定輸出文件名。
$template DynamicFile,"/var/log/test_logs/%timegenerated%-test.log"
*.* ?DynamicFile
使用 timegenerated 生成文件名，使用該模板則在前面加上 ?。
其他例子如下：
$template DailyPerHostLogs,"/var/log/syslog/%$YEAR%/%$MONTH%/%$DAY%/%HOSTNAME%/messages.log"
根據屬性控制日志輸出格式
使用下面的格式可以對模板之中的屬性做各種修改操作從而定制日志的格式:
%<propname>[:<fromChar>:<toChar>:<options>]%
<propname> 屬性名，可用的屬性名參考上文。
<fromChar> 和 <toChar> 表示對屬性值字符串的操作範圍。 設置 <fromChar> 爲 R，<toChar> 爲正則表達式即可以通過正則 表達式定義範圍。
<options> 則表示屬性選項。完整的列表可以參考 這裏的 Property Options 節。
一些示例如下：
%msg% # 日志的完整消息文本
%msg:1:2% # 日志消息文本的最開始兩個字符
%msg:::drop-last-lf% # 日志的完整消息文本，移出最後的換行符
%timegenerated:1:10:date-rfc3339% # 時間戳的頭10個字符並按 RFC3999 標准格式化
下面是一些模板例子。
輸出日志的級別，類別，收到日志時的時間錯，主機名，消息標簽，消息正文， 加上換行符：
$template verbose,"%syslogseverity%,%syslogfacility%,%timegenerated%,%HOSTNAME%,%syslogtag%,%msg%\n"
輸出日志來源，時間以及日志標簽，正文，同時還有蜂鳴聲（\7）：
$template wallmsg,"\r\n\7Message from syslogd@%HOSTNAME% at %timegenerated% ...\r\n %syslogtag% %msg%\n\r"
格式化日志以便于直接進行 SQL 操作：
$template dbFormat,"insert into SystemEvents (Message, Facility,FromHost, Priority, DeviceReportedTime, ReceivedAt, InfoUnitID, SysLogTag) values ('%msg%', %syslogfacility%, '%HOSTNAME%',%syslogpriority%, '%timereported:::date-mysql%', '%timegenerated:::date-mysql%', %iut%, '%syslogtag%')",sql
以 json 格式輸出，方便程序解析：
$template jsonFormat,"{\"message\":\"%msg:::json%\",\"fromhost\":\"%HOSTNAME:::json%\",\"facility\":\"%syslogfacility-text%\",\"priority\":\"%syslogpriority-text%\",\"timereported\":\"%timereported:::date-rfc3339%\",\"timegenerated\":\"%timegenerated:::date-rfc3339%\"}\n"
注意，message 的內容會在最前面多一個空格，其解釋請參考這裏。
rsyslog 也提供了一些預定義的模板（以 RSYSLOG_ 爲前綴），參考 這裏 的 Reserved Template Names 節，其定義如下：
RSYSLOG_FileFormat
"%TIMESTAMP:::date-rfc3339% %HOSTNAME% %syslogtag%%msg:::sp-if-no-1st-sp%%msg:::drop-last-lf%\n\"
RSYSLOG_TraditionalFileFormat
"%TIMESTAMP% %HOSTNAME% %syslogtag%%msg:::sp-if-no-1st-sp%%msg:::drop-last-lf%\n\"
RSYSLOG_ForwardFormat
"<%PRI%>%TIMESTAMP:::date-rfc3339% %HOSTNAME% %syslogtag:1:32%%msg:::sp-if-no-1st-sp%%msg%\"
RSYSLOG_TraditionalForwardFormat
"<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag:1:32%%msg:::sp-if-no-1st-sp%%msg%\"
使用這些模板，則在動作後附加 “;template_name” 即可，例如：
:programname,startswith,"cron" -/var/log/cron;RSYSLOG_TraditionalFileFormat