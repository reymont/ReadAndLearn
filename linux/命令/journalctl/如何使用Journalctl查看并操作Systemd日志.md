

如何使用Journalctl查看并操作Systemd日志 - CSDN博客 http://blog.csdn.net/zstack_org/article/details/56274966

内容简介

作为最具吸引力的优势，systemd拥有强大的处理与系统日志记录功能。在使用其它工具时，日志往往被分散在整套系统当中，由不同的守护进程及进程负责处理，这意味着我们很难跨越多种应用程序对其内容进行解读。

相比之下，systemd尝试提供一套集中化管理方案，从而统一打理全部内核及用户级进程的日志信息。这套系统能够收集并管理日志内容，而这也就是我们所熟知的journal。

Journal的实现归功于journald守护进程，其负责处理由内核、initrd以及服务等产生的信息。在今天的教程中，我们将探讨如何使用journalctl工具，并在其帮助下访问并操作journal内部的数据。

总体思路

Systemd journal的深层驱动力在于以集中方式管理对来自任意来源的日志信息。由于大部分引导进程都是由systemd进程处理的，因此我们有理由以标准化方式实现日志的收集与访问。其中jornald守护进程会收集全部来源的数据并将其以二进制格式加以存储，从而轻松实现动态操作。

这种作法能够实现多种收益。通过单一工具与数据交互，管理员能够以动态方式显示日志数据。另外，我们也可以轻松查看历史引导数据，或者将日志条目同其它相关服务加以结合，从而 完成通信问题调试。

将日志数据以二进制形式存储还意味着这些数据可根据需求随时以二进制输出格式显示。例如，大家可以通过标准syslog格式查看日志以实现日常管理，并在需要使用图形服务时将各条目作为JSON对象交由图形化服务处理。由于数据不会以纯文本形式被写入磁盘，因此我们无需进行任何格式转换。

大家可以将systemd journal与现有syslog方案配合使用，也可利用其替代现有syslog功能，具体取决于实际需求。尽管systemd journal足以涵盖大部分管理工作需求，但其同时也能够补充现有日志记录机制。例如，大家可以建立一套集中式syslog服务器，从而对来自多台服务器的数据进行编译；或者，我们也能够利用systemd journal将来自多项服务的日志汇总在单一系统当中。

设置系统时间

使用二进制journal的一大好处在于，它能够以UTC或者本地时间显示日志记录。在默认情况下，systemd会以本地时间显示结果。

有鉴于此，在我们开始使用journal之前，首先要确保时区得到正确设置。Systemd套件中还提供一款timedatectl工具，专门用于解决此类问题。

首先，利用list-timezones选项查看可用时区：

timedatectl list-timezones
1
2
结果将列出系统上可用的全部时区。而后选择与服务器所在地相匹配的项目，并使用set-timezone选项加以设置：

sudo timedatectl set-timezone zone
1
2
为了确保我们的设备使用正确的时间，可单独使用timedatectl命令或者添加status选项。显示结果如下：

timedatectl status

Local time: Thu 2015-02-05 14:08:06 EST
Universal time: Thu 2015-02-05 19:08:06 UTC
    RTC time: Thu 2015-02-05 19:08:06
   Time zone: America/New_York (EST, -0500)
 NTP enabled: no
NTP synchronized: no
RTC in local TZ: no
  DST active: n/a
1
2
3
4
5
6
7
8
9
10
11
第一行所示应为正确时间。

基础日志查看

要查看journald守护进程收集到的日志，可使用journalctl命令。

在单独使用时，系统中的每个journal条目都会被显示在单一pager中供我们浏览。条目时间越早，排列越靠前：

journalctl

-- Logs begin at Tue 2015-02-03 21:48:52 UTC, end at Tue 2015-02-03 22:29:38 UTC. --
Feb 03 21:48:52 localhost.localdomain systemd-journal[243]: Runtime journal is using 6.2M (max allowed 49.
Feb 03 21:48:52 localhost.localdomain systemd-journal[243]: Runtime journal is using 6.2M (max allowed 49.
Feb 03 21:48:52 localhost.localdomain systemd-journald[139]: Received SIGTERM from PID 1 (systemd).
Feb 03 21:48:52 localhost.localdomain kernel: audit: type=1404 audit(1423000132.274:2): enforcing=1 old_en
Feb 03 21:48:52 localhost.localdomain kernel: SELinux: 2048 avtab hash slots, 104131 rules.
Feb 03 21:48:52 localhost.localdomain kernel: SELinux: 2048 avtab hash slots, 104131 rules.
Feb 03 21:48:52 localhost.localdomain kernel: input: ImExPS/2 Generic Explorer Mouse as /devices/platform/
Feb 03 21:48:52 localhost.localdomain kernel: SELinux:  8 users, 102 roles, 4976 types, 294 bools, 1 sens,
Feb 03 21:48:52 localhost.localdomain kernel: SELinux:  83 classes, 104131 rules

. . .
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
大家可以一页页进行翻看，不过如果系统运行时间较长，那么systemd中的日志也将成千上万，这也证明了journal数据库中可观的数据量。

其格式与标准的syslog日志非常相似。然而，其收集数据的来源较syslog要丰富得多。其中包含有来自先前引导进程、内核、initrd以及应用程序标准错误与输出的日志。这一切都可在journal中查看到。

大家可能还注意到，全部时间戳都以本地时间为准。由于已经为系统正确设置了本地时间，所以显示的时间戳也都准确无误。

如果大家希望以UTC显示时间戳，则可使用–utc标记：

journalctl --utc
1
2
按时间进行journal过滤

浏览大量数据当然有其作用，但信息量过于庞大则会让我们很难甚至根本不可能找到真正重要的内容。因此，journalctl提供了极为关键的过滤选项。

显示当前引导进程下的日志

其中最常用的就是-b标记了，其将显示全部最近一次重新引导后收集到的journal条目。

journalctl -b
1
2
通过这种方式，我们能够识别并管理源自当前环境下的信息。

如果不使用这项功能，而且显示的引导数量超过一天，那么journalctl会在在系统关闭处插入说明：

. . .

-- Reboot --

. . .
1
2
3
4
5
6
这种方式能够帮助我们有效区分来自不同引导会话的信息。

过往引导记录

大家通常只需要查看当前引导环境下的信息，但有时候查看过往引导记录也非常必要。Journal能够保存大量过往引导信息，从而允许journalctl轻松显示相关内容。

有些版本会在默认情况下保存过往引导信息，而有些则默认禁用这项功能。要启用此功能，可以使用以下功能以创建用于存储journal信息的目录：

- sudo mkdir -p /var/log/journal
1
2
或者直接编辑journal配置文件：

- sudo nano /etc/systemd/journald.conf
1
2
在[Journal]区段下将Storage=选项设定为“persistent”以启用持久记录：

/etc/systemd/journald.conf

. . .
[Journal]
Storage=persistent
1
2
3
4
5
6
当启用保存过往引导信息功能后，journalctl会提供额外命令以帮助大家将各引导记录作为独立单元操作。要查看Journald中已经记录的引导信息，可使用–list-boots选项：

journalctl --list-boots

-2 caf0524a1d394ce0bdbcff75b94444fe Tue 2015-02-03 21:48:52 UTC—Tue 2015-02-03 22:17:00 UTC
-1 13883d180dc0420db0abcb5fa26d6198 Tue 2015-02-03 22:17:03 UTC—Tue 2015-02-03 22:19:08 UTC
 0 bed718b17a73415fade0e4e7f4bea609 Tue 2015-02-03 22:19:12 UTC—Tue 2015-02-03 23:01:01 UTC
1
2
3
4
5
6
这里每次引导都将显示为一行。第一列可用于在journalctl中引用该次引导。如果大家需要更为准确的引用方式，则可在第二列中找到引导ID。末尾记录的两次时间为当次引导的开始与结束时间。

要显示这些引导中的具体信息，则可使用第一或者第二列提供的信息。

例如，要查看上次引导的journal记录，则可使用-1相对指针配合-b标记：

journalctl -b -1
1
2
另外，也可以使用引导ID：

journalctl -b caf0524a1d394ce0bdbcff75b94444fe
1
2
时间窗

按照引导环境查看日志条目当然非常重要，但我们往往还需要使用与系统引导无关的时间窗作为浏览基准。这种情况在长期运行的服务器当中较为常见。

大家可以利用–since与–until选项设定时间段，二者分别负责说明给定时间之前与之后的记录。

时间值可以多种格式输出。对于绝对时间值，大家可以使用以下格式：

YYYY-MM-DD HH:MM:SS
1
2
例如，我们可以通过以下命令查看全部2015年1月10日下午5：15之后的条目：

journalctl --since "2015-01-10 17:15:00"
1
2
如果以上格式中的某些组成部分未进行填写，系统会直接进行默认填充。例如，如果日期部分未填写，则会直接显示当前日期。如果时间部分未填写，则缺省使用“00：00：00”（午夜）。第二字段亦可留空，默认值为“00”：

journalctl --since "2015-01-10" --until "2015-01-11 03:00"
1
2
另外，journal还能够理解部分相对值及命名简写。例如，大家可以使用“yesterday”、“today”、“tomorrow”或者“now”等表达。另外，我们也可以使用“-”或者“+”设定相对值，或者使用“ago”之前的表达。

获取昨天数据的命令如下：

journalctl –since yesterday

要获得早9：00到一小时前这段时间内的报告，可使用以下命令：

journalctl --since 09:00 --until "1 hour ago"
1
2
如大家所见，时间窗的过滤机制非常灵活且易用。

按信息类型过滤

现在我们要探讨如何利用感兴趣的服务或者组件类型实现过滤。Systemd journal同样提供多种方式供大家选择。

按单元

最常用的此类过滤方式当数按单元过滤了。我们可以使用-u选项实现这一效果。

例如，要查看系统上全部来自Nginx单元的日志，可使用以下命令：

journalctl -u nginx.service
1
2
一般来讲，我们可能需要同时按单元与时间进行信息过滤。例如，检查今天某项服务的运行状态：

journalctl -u nginx.service --since today
1
2
我们还可以充分发挥journal查看多种单元信息的优势。例如，如果我们的Nginx进程接入某个PHP-FPM单元以处理动态内容，则可将这两个单元合并并获取按时间排序的查询结果：

journalctl -u nginx.service -u php-fpm.service --since today
1
2
这种能力对于不同程序间交互及系统调试显然非常重要。

按进程、用户或者群组ID

由于某些服务当中包含多个子进程，因此如果我们希望通过进程ID实现查询，也可以使用相关过滤机制。

这里需要指定_PID字段。例如，如果PID为8088，则可输入：

journalctl _PID=8088
1
2
有时候我们可能希望显示全部来自特定用户或者群组的日志条目，这就需要使用_UID或者_GID。例如，如果大家的Web服务器运行在www-data用户下，则可这样找到该用户ID：

id -u www-data

33
1
2
3
4
接下来，我们可以使用该ID返回过滤后的journal结果：

journalctl _UID=33 --since today
1
2
Systemd journal拥有多种可实现过滤功能的字段。其中一些来自被记录的进程，有些则由journald用于自系统中收集特定时间段内的日志。

之前提到的_PID属于后一种。Journal会自动记录并检索进程PID，以备日后过滤之用。大家可以查看当前全部可用journal字段：

man systemd.journal-fields
1
2
下面来看针对这些字段的过滤机制。-F选项可用于显示特定journal字段内的全部可用值。

例如，要查看systemd journal拥有条目的群组ID，可使用以下命令：

journalctl -F _GID

32
99
102
133
81
84
100
0
124
87
1
2
3
4
5
6
7
8
9
10
11
12
13
其将显示全部journal已经存储至群组ID字段内的值，并可用于未来的过滤需求。

按组件路径

我们也可以提供路径位置以实现过滤。

如果该路径指向某个可执行文件，则journalctl会显示与该可执行文件相关的全部条目。例如，要找到与bash可执行文件相关的条目：

journalctl /usr/bin/bash
1
2
一般来讲，如果某个单元可用于该可执行文件，那么此方法会更为明确且能够提供更好的相关信息（与子进程相关的条目等）。但有时候，这种作法则无法奏效。

显示内核信息

内核信息通常存在于dmesg输出结果中，journal同样可对其进行检索。要只显示此类信息，可添加-k或者–dmesg标记：

journalctl -k
1
2
默认情况下，其会显示当前引导环境下的全部内核信息。大家也可以使用常规的引导选择标记对此前的引导记录进行查询。例如，要查询五次之前引导环境的信息：

journalctl -k -b -5
1
2
按优先级

管理员们可能感兴趣的另一种过滤机制为信息优先级。尽管以更为详尽的方式查看日志也很有必要，不过在理解现有信息时，低优先级日志往往会分散我们的注意力并导致理解混乱。

大家可以使用journalctl配合-p选项显示特定优先级的信息，从而过滤掉优先级较低的信息。

例如，只显示错误级别或者更高的日志条目：

journalctl -p err -b
1
2
这将只显示被标记为错误、严重、警告或者紧急级别的信息。Journal的这种实现方式与标准syslog信息在级别上是一致的。大家可以使用优先级名称或者其相关量化值。以下各数字为由最高到最低优先级：

0: emerg
1: alert
2: crit
3: err
4: warning
5: notice
6: info
7: debug
以上为可在-p选项中使用的数字或者名称。选定某一优先级会显示等级与之等同以及更高的信息。

修改journal显示内容

到这里，过滤部分已经介绍完毕。我们也可以使用多种方式对输出结果进行修改，从而调整journalctl的显示内容。

截断或者扩大输出结果

我们可以缩小或者扩大输出结果，从而调整journalctl的显示方式。

在默认情况下，journalctl会在pager内显示各条目，并通过右箭头键访问其信息。

如果大家希望截断输出内容，向其中插入省略号以代表被移除的信息，则可使用–no-full选项：

journalctl --no-full

. . .

Feb 04 20:54:13 journalme sshd[937]: Failed password for root from 83.234.207.60...h2
Feb 04 20:54:13 journalme sshd[937]: Connection closed by 83.234.207.60 [preauth]
Feb 04 20:54:13 journalme sshd[937]: PAM 2 more authentication failures; logname...ot
1
2
3
4
5
6
7
8
大家也可以要求其显示全部信息，无论其是否包含不可输出的字符。具体方式为添加-a标记：

journalctl -a
1
2
标准输出结果

默认情况下，journalctl会在pager内显示输出结果以便于查阅。如果大家希望利用文本操作工具对数据进行处理，则可能需要使用标准格式。在这种情况下，我们需要使用–no-pager选项：

journalclt --no-pager
1
2
这样相关结果即可根据需要被重新定向至磁盘上的文件或者处理工具当中。

输出格式

如果大家需要对journal条目进行处理，则可能需要使用更易使用的格式以简化数据解析工作。幸运的是，journal能够以多种格式进行显示，只须添加-o选项加格式说明即可。

例如，我们可以将journal条目输出为JSON格式：

journalctl -b -u nginx -o json

{ "__CURSOR" : "s=13a21661cf4948289c63075db6c25c00;i=116f1;b=81b58db8fd9046ab9f847ddb82a2fa2d;m=19f0daa;t=50e33c33587ae;x=e307daadb4858635", "__REALTIME_TIMESTAMP" : "1422990364739502", "__MONOTONIC_TIMESTAMP" : "27200938", "_BOOT_ID" : "81b58db8fd9046ab9f847ddb82a2fa2d", "PRIORITY" : "6", "_UID" : "0", "_GID" : "0", "_CAP_EFFECTIVE" : "3fffffffff", "_MACHINE_ID" : "752737531a9d1a9c1e3cb52a4ab967ee", "_HOSTNAME" : "desktop", "SYSLOG_FACILITY" : "3", "CODE_FILE" : "src/core/unit.c", "CODE_LINE" : "1402", "CODE_FUNCTION" : "unit_status_log_starting_stopping_reloading", "SYSLOG_IDENTIFIER" : "systemd", "MESSAGE_ID" : "7d4958e842da4a758f6c1cdc7b36dcc5", "_TRANSPORT" : "journal", "_PID" : "1", "_COMM" : "systemd", "_EXE" : "/usr/lib/systemd/systemd", "_CMDLINE" : "/usr/lib/systemd/systemd", "_SYSTEMD_CGROUP" : "/", "UNIT" : "nginx.service", "MESSAGE" : "Starting A high performance web server and a reverse proxy server...", "_SOURCE_REALTIME_TIMESTAMP" : "1422990364737973" }

. . .
1
2
3
4
5
6
这种方式对于工具解析非常重要。大家也可以使用json-pretty格式以更好地处理数据结构：

journalctl -b -u nginx -o json-pretty

{
"__CURSOR" : "s=13a21661cf4948289c63075db6c25c00;i=116f1;b=81b58db8fd9046ab9f847ddb82a2fa2d;m=19f0daa;t=50e33c33587ae;x=e307daadb4858635",
"__REALTIME_TIMESTAMP" : "1422990364739502",
"__MONOTONIC_TIMESTAMP" : "27200938",
"_BOOT_ID" : "81b58db8fd9046ab9f847ddb82a2fa2d",
"PRIORITY" : "6",
"_UID" : "0",
"_GID" : "0",
"_CAP_EFFECTIVE" : "3fffffffff",
"_MACHINE_ID" : "752737531a9d1a9c1e3cb52a4ab967ee",
"_HOSTNAME" : "desktop",
"SYSLOG_FACILITY" : "3",
"CODE_FILE" : "src/core/unit.c",
"CODE_LINE" : "1402",
"CODE_FUNCTION" : "unit_status_log_starting_stopping_reloading",
"SYSLOG_IDENTIFIER" : "systemd",
"MESSAGE_ID" : "7d4958e842da4a758f6c1cdc7b36dcc5",
"_TRANSPORT" : "journal",
"_PID" : "1",
"_COMM" : "systemd",
"_EXE" : "/usr/lib/systemd/systemd",
"_CMDLINE" : "/usr/lib/systemd/systemd",
"_SYSTEMD_CGROUP" : "/",
"UNIT" : "nginx.service",
"MESSAGE" : "Starting A high performance web server and a reverse proxy server...",
"_SOURCE_REALTIME_TIMESTAMP" : "1422990364737973"
}

. . .
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
以下为可用于显示的各类格式：

cat: 只显示信息字段本身。
export: 适合传输或备份的二进制格式。
json: 标准JSON，每行一个条目。
json-pretty: JSON格式，适合人类阅读习惯。
json-sse: JSON格式，经过打包以兼容server-sent事件。
short: 默认syslog类输出格式。
short-iso: 默认格式，强调显示ISO 8601挂钟时间戳。
short-monotonic: 默认格式，提供普通时间戳。
short-precise: 默认格式，提供微秒级精度。
verbose: 显示该条目的全部可用journal字段，包括通常被内部隐藏的字段。
这些选项允许大家以最适合需求的格式显示journal条目。

活动进程监控

Journalctl命令还能够帮助管理员以类似于tail的方式监控活动或近期进程。这项功能内置于journalctl当中，允许大家在无需借助其它工具的前提下实现访问。

显示近期日志

要显示特定数量的记录，大家可以使用-n选项，具体方式为tail -n。

默认情况下，其会显示最近十条记录：

journalctl -n
1
2
大家可以在-n之后指定要查看的条目数量：

journalctl -n 20
1
2
追踪日志

要主动追踪当前正在编写的日志，大家可以使用-f标记。方式同样为tail -f：

journalctl -f
1
2
Journal维护

存储这么多数据当然会带来巨大压力，因此我们还需要了解如何清理部分陈旧日志以释放存储空间。

了解现有磁盘使用量

大家可以利用–disk-usage标记查看journal的当前磁盘使用量：

journalctl --disk-usage

Journals take up 8.0M on disk.
1
2
3
4
删除旧有日志

如果大家打算对journal记录进行清理，则可使用两种不同方式（适用于systemd 218及更高版本）。

如果使用–vacuum-size选项，则可硬性指定日志的总体体积，意味着其会不断删除旧有记录直到所占容量符合要求：

sudo journalctl --vacuum-size=1G
1
2
另一种方式则是使用–vacuum-time选项。任何早于这一时间点的条目都将被删除。

例如，去年之后的条目才能保留：

sudo journalctl --vacuum-time=1years
1
2
限定Journal扩展

大家可以配置自己的服务器以限定journal所能占用的最高容量。要实现这一点，我们需要编辑/etc/systemd/journald.conf文件。

以下条目可用于限定journal体积的膨胀速度：

SystemMaxUse=: 指定journal所能使用的最高持久存储容量。
SystemKeepFree=: 指定journal在添加新条目时需要保留的剩余空间。
SystemMaxFileSize=: 控制单一journal文件大小，符合要求方可被转为持久存储。
RuntimeMaxUse=: 指定易失性存储中的最大可用磁盘容量（/run文件系统之内）。
RuntimeKeepFree=: 指定向易失性存储内写入数据时为其它应用保留的空间量（/run文件系统之内）。
RuntimeMaxFileSize=: 指定单一journal文件可占用的最大易失性存储容量（/run文件系统之内）。
通过设置上述值，大家可以控制journald对服务器空间的消耗及保留方式。

总结

到这里，systemd journal对系统及应用数据的收集与管理机制就介绍完毕了。其出色的灵活性源自将广泛的元数据自动记录至集中化日志之内。另外，journalctl命令则显著简化了journal的使用方式，从而让更多管理员得以利用它完成面向不同应用组件的分析与相关调试工作。

本文来源自DigitalOcean Community。英文原文：How To Use Journalctl to View and Manipulate Systemd Logs By Justin Ellingwood

翻译：diradw