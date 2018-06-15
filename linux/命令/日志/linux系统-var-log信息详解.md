

linux系统/var/log信息详解 - CSDN博客 http://blog.csdn.net/swanhui/article/details/9763039

学习/var/log/message 的时候，在论坛看到有人写的： linux系统/var/log目录下的信息详解 非常不错，
连接地址：http://blog.chinaunix.net/uid-26569496-id-3199434.html
先把目前需要的部分学习了，以后在慢慢研读其他部分。
 
一、/var目录
/var 所有服务的登录的文件或错误信息文件（LOG FILES)都在/var/log下，此外，一些数据库如MySQL则在/var/lib下，还有，用户未读的邮件的默认存放地点为/var/spool/mail
二、:/var/log/
系统的引导日志:/var/log/boot.log
例如:Feb 26 10:40:48 sendmial : sendmail startup succeeded
就是邮件服务启动成功!

系统日志一般都存在/var/log下
常用的系统日志如下:
核心启动日志:/var/log/dmesg
系统报错日志:/var/log/messages
邮件系统日志:/var/log/maillog
FTP系统日志:/var/log/xferlog
安全信息和系统登录与网络连接的信息:/var/log/secure
登录记录:/var/log/wtmp      记录登录者讯录，二进制文件，须用last来读取内容    who -u /var/log/wtmp 查看信息
News日志:/var/log/spooler
RPM软件包:/var/log/rpmpkgs
XFree86日志:/var/log/XFree86.0.log
引导日志:/var/log/boot.log   记录开机启动讯息，dmesg | more
cron(定制任务日志)日志:/var/log/cron
 
安全信息和系统登录与网络连接的信息:/var/log/secure
 
文件 /var/run/utmp 記錄著現在登入的用戶。
文件 /var/log/wtmp 記錄所有的登入和登出。
文件 /var/log/lastlog 記錄每個用戶最後的登入信息。
文件 /var/log/btmp 記錄錯誤的登入嘗試。
 

less /var/log/auth.log 需要身份确认的操作
三、部分命令详解
 
   /var/log/messages
 
    messages 日志是核心系统日志文件。它包含了系统启动时的引导消息，以及系统运行时的其他状态消息。IO 错误、网络错误和其他系统错误都会记录到这个文件中。其他信息，比如某个人的身份切换为 root，也在这里列出。如果服务正在运行，比如 DHCP 服务器，您可以在 messages 文件中观察它的活动。通常，/var/log/messages 是您在做故障诊断时首先要查看的文件。
   /var/log/XFree86.0.log
这个日志记录的是 Xfree86 Xwindows 服务器最后一次执行的结果。如果您在启动到图形模式时遇到了问题，一般情况从这个文件中会找到失败的原因。
  http://www.guanwei.org/post/LINUXnotes/01/linuxlogs.html
 
     成 功地管理任何系统的关键之一，是要知道系统中正在发生什么事。Linux 中提供了异常日志，并且日志的细节是可配置的。Linux 日志都以明文形式存储，所以用户不需要特殊的工具就可以搜索和阅读它们。还可以编写脚本，来扫描这些日志，并基于它们的内容去自动执行某些功能。 Linux 日志存储在 /var/log 目录中。这里有几个由系统维护的日志文件，但其他服务和程序也可能会把它们的日志放在这里。大多数日志只有root账户才可以读，不过修改文件的访问权限 就可以让其他人可读。
日志文件分类
/var/log/boot.log
该文件记录了系统在引导过程中发生的事件，就是Linux系统开机自检过程显示的信息。
/var/log/cron
该 日志文件记录crontab守护进程crond所派生的子进程的动作，前面加上用 户、登录时间和PID，以及派生出的进程的动作。CMD的一个动作是cron派生出一个调度进程的常见情况。REPLACE（替换）动作记录用户对它的 cron文件的更新，该文件列出了要周期性执行的任务调度。 RELOAD动作在REPLACE动作后不久发生，这意味着cron注意到一个用户的cron文件被更新而cron需要把它重新装入内存。该文件可能会查 到一些反常的情况。
/var/log/maillog
该日志文件记录了每一个发送到系统或从系统发出的电子邮件的活动。它可以用来查看用户使用哪个系统发送工具或把数据发送到哪个系统。下面是该日志文件的片段：
Sep 4 17:23:52 UNIX sendmail[1950]: g849Npp01950: from=root, size=25,
class=0, nrcpts=1,
msgid=<200209040923.g849Npp01950@redhat.pfcc.com.cn>,
relay=root@localhost
Sep 4 17:23:55 UNIX sendmail[1950]: g849Npp01950: to=lzy@fcceec.net,
ctladdr=root (0/0), delay=00:00:04, xdelay=00:00:03, mailer=esmtp, pri=30025,
relay=fcceec.net. [10.152.8.2], dsn=2.0.0, stat=Sent (Message queued)
/var/log/messages
 
该日志文件是许多进程日志文件的汇总，从该文件可以看出任何入侵企图或成功的入侵。如以下几行：
Sep 3 08:30:17 UNIX login[1275]: FAILED LOGIN 2 FROM (null) FOR suying,
Authentication failure
Sep 4 17:40:28 UNIX -- suying[2017]: LOGIN ON pts/1 BY suying FROM
fcceec.www.ec8.pfcc.com.cn
Sep 4 17:40:39 UNIX su(pam_unix)[2048]: session opened for user root by suying(uid=999)
   该 文件的格式是每一行包含日期、主机名、程序名，后面是包含PID或内核标识的方括 号、一个冒号和一个空格，最后是消息。该文件有一个不足，就是被记录的入侵企图和成功的入侵事件，被淹没在大量的正常进程的记录中。但该文件可以由 /etc/syslog文件进行定制。由 /etc/syslog.conf配置文件决定系统如何写入/var/messages。有关如何配置/etc/syslog.conf文件决定系统日志 记录的行为，将在后面详细叙述。
/var/log/syslog
默 认RedHat Linux不生成该日志文件，但可以配置/etc/syslog.conf让系统生成该日志文件。它和/etc/log/messages日志文件不同， 它只记录警告信息，常常是系统出问题的信息，所以更应该关注该文件。要让系统生成该日志文件，在/etc/syslog.conf文件中加上： *.warning /var/log/syslog 该日志文件能记录当用户登录时login记录下的错误口令、Sendmail的问题、su命令执行失败等信息。下面是一条记录：
 
Sep 6 16:47:52 UNIX login(pam_unix)[2384]: check pass; user unknown
/var/log/secure
该日志文件记录与安全相关的信息。该日志文件的部分内容如下：
Sep 4 16:05:09 UNIX xinetd[711]: START: ftp pid=1815 from=127.0.0.1
Sep 4 16:05:09 UNIX xinetd[1815]: USERID: ftp OTHER :root
Sep 4 16:07:24 UNIX xinetd[711]: EXIT: ftp pid=1815 duration=135(sec)
Sep 4 16:10:05 UNIX xinetd[711]: START: ftp pid=1846 from=127.0.0.1
Sep 4 16:10:05 UNIX xinetd[1846]: USERID: ftp OTHER :root
Sep 4 16:16:26 UNIX xinetd[711]: EXIT: ftp pid=1846 duration=381(sec)
Sep 4 17:40:20 UNIX xinetd[711]: START: telnet pid=2016 from=10.152.8.2
 
/var/log/lastlog
   该 日志文件记录最近成功登录的事件和最后一次不成功的登录事件，由login生成。 在每次用户登录时被查询，该文件是二进制文件，需要使用 lastlog命令查看，根据UID排序显示登录名、端口号和上次登录时间。如果某用户从来没有登录过，就显示为"**Never logged in**"。该命令只能以root权限执行。简单地输入lastlog命令后就会看到类似如下的信息：
Username Port From Latest
root tty2 Tue Sep 3 08:32:27 +0800 2002
bin **Never logged in**
daemon **Never logged in**
adm **Never logged in**
lp **Never logged in**
sync **Never logged in**
shutdown **Never logged in**
halt **Never logged in**
mail **Never logged in**
news **Never logged in**
uucp **Never logged in**
operator **Never logged in**
games **Never logged in**
gopher **Never logged in**
ftp ftp UNIX Tue Sep 3 14:49:04 +0800 2002
nobody **Never logged in**
nscd **Never logged in**
mailnull **Never logged in**
ident **Never logged in**
rpc **Never logged in**
rpcuser **Never logged in**
xfs **Never logged in**
gdm **Never logged in**
postgres **Never logged in**
apache **Never logged in**
lzy tty2 Mon Jul 15 08:50:37 +0800 2002
suying tty2 Tue Sep 3 08:31:17 +0800 2002
 
   系统账户诸如bin、daemon、adm、uucp、mail等决不应该登录，如果发现这些账户已经登录，就说明系统可能已经被入侵了。若发现记录的时间不是用户上次登录的时间，则说明该用户的账户已经泄密了。
 
/var/log/wtmp
   该 日志文件永久记录每个用户登录、注销及系统的启动、停机的事件。因此随着系统正常 运行时间的增加，该文件的大小也会越来越大，增加的速度取决于系统用户登录的次数。该日志文件可以用来查看用户的登录记录，last命令就通过访问这个文 件获得这些信息，并以反序从后向前显示用户的登录记录，last也能根据用户、终端 tty或时间显示相应的记录。
 
命令last有两个可选参数：
last -u 用户名 显示用户上次登录的情况。
last -t 天数 显示指定天数之前的用户登录情况。
 
/var/run/utmp
   该 日志文件记录有关当前登录的每个用户的信息。因此这个文件会随着用户登录和注销系 统而不断变化，它只保留当时联机的用户记录，不会为用户保留永久的记录。系统中需要查询当前用户状态的程序，如 who、w、users、finger等就需要访问这个文件。该日志文件并不能包括所有精确的信息，因为某些突发错误会终止用户登录会话，而系统没有及时 更新 utmp记录，因此该日志文件的记录不是百分之百值得信赖的。
 
以 上提及的3个文件（/var/log/wtmp、/var/run/utmp、 /var/log/lastlog）是日志子系统的关键文件，都记录了用户登录的情况。这些文件的所有记录都包含了时间戳。这些文件是按二进制保存的，故 不能用less、cat之类的命令直接查看这些文件，而是需要使用相关命令通过这些文件而查看。其中，utmp和wtmp文件的数据结构是一样的，而 lastlog文件则使用另外的数据结构，关于它们的具体的数据结构可以使用man命令查询。
 
每 次有一个用户登录时，login程序在文件lastlog中查看用户的UID。如果存在，则把用户上次登录、注销时间和主机名写到标准输出中，然后 login程序在lastlog中记录新的登录时间，打开utmp文件并插入用户的utmp记录。该记录一直用到用户登录退出时删除。utmp文件被各种 命令使用，包括who、w、users和finger。
 
下一步，login程序打开文件wtmp附加用户的utmp记录。当用户登录退出时，具有更新时间戳的同一utmp记录附加到文件中。wtmp文件被程序last使用。
 
/var/log/xferlog
   该日志文件记录FTP会话，可以显示出用户向FTP服务器或从服务器拷贝了什么文件。该文件会显示用户拷贝到服务器上的用来入侵服务器的恶意程序，以及该用户拷贝了哪些文件供他使用。
 
   该 文件的格式为：第一个域是日期和时间，第二个域是下载文件所花费的秒数、远程系统 名称、文件大小、本地路径名、传输类型（a：ASCII，b：二进制）、与压缩相关的标志或tar，或"_"（如果没有压缩的话）、传输方向（相对于服务 器而言：i代表进，o代表出）、访问模式（a：匿名，g：输入口令，r：真实用户）、用户名、服务名（通常是ftp）、认证方法（l：RFC931，或 0），认证用户的ID或"*"。下面是该文件的一条记录：
 
Wed Sep 4 08:14:03 2002 1 begin_of_the_skype_highlighting 03 2002 1 免费  end_of_the_skype_highlighting UNIX 275531
/var/ftp/lib/libnss_files-2.2.2.so b _ o a -root@UNIX ftp 0 * c
/var/log/kernlog
 
 
RedHat Linux默认没有记录该日志文件。要启用该日志文件，必须在/etc/syslog.conf文件中添加一行：kern.* /var/log/kernlog 。这样就启用了向/var/log/kernlog文件中记录所有内核消息的功能。该文件记录了系统启动时加载设备或使用设备的情况。一般是正常的操作， 但如果记录了没有授权的用户进行的这些操作，就要注意，因为有可能这就是恶意用户的行为。下面是该文件的部分内容：
 
Sep 5 09:38:42 UNIX kernel: NET4: Linux TCP/IP 1.0 for NET4.0
Sep 5 09:38:42 UNIX kernel: IP Protocols: ICMP, UDP, TCP, IGMP
Sep 5 09:38:42 UNIX kernel: IP: routing cache hash table of 512 buckets, 4Kbytes
Sep 5 09:38:43 UNIX kernel: TCP: Hash tables configured (established 4096 bind 4096)
Sep 5 09:38:43 UNIX kernel: Linux IP multicast router 0.06 plus PIM-SM
Sep 5 09:38:43 UNIX kernel: NET4: Unix domain sockets 1.0/SMP for Linux NET4.0.
Sep 5 09:38:44 UNIX kernel: EXT2-fs warning: checktime reached, running e2fsck is recommended
Sep 5 09:38:44 UNIX kernel: VFS: Mounted root (ext2 filesystem).
Sep 5 09:38:44 UNIX kernel: SCSI subsystem driver Revision: 1.00
/var/log/Xfree86.x.log
 
 
 
该 日志文件记录了X-Window启动的情况。另外，除了/var/log/外，恶 意用户也可能在别的地方留下痕迹，应该注意以下几个地方：root 和其他账户的shell历史文件；用户的各种邮箱，如.sent、mbox，以及存放在/var/spool/mail/ 和 /var/spool/mqueue中的邮箱；临时文件/tmp、/usr/tmp、/var/tmp；隐藏的目录；其他恶意用户创建的文件，通常是以 "."开头的具有隐藏属性的文件等。
 
四、具体命令
 
   wtmp和utmp文件都是二进制文件，它们不能被诸如tail之类的命令剪贴或合并（使用cat命令）。用户需要使用who、w、users、last和ac等命令来使用这两个文件包含的信息。
 
who命令
 
who命令查询utmp文件并报告当前登录的每个用户。who的默认输出包括用户名、终端类型、登录日期及远程主机。例如，键入who命令，然后按回车键，将显示如下内容：
chyang pts/0 Aug 18 15:06
ynguo pts/2 Aug 18 15:32
ynguo pts/3 Aug 18 13:55
lewis pts/4 Aug 18 13:35
ynguo pts/7 Aug 18 14:12
ylou pts/8 Aug 18 14:15
 
如果指明了wtmp文件名，则who命令查询所有以前的记录。命令who /var/log/wtmp将报告自从wtmp文件创建或删改以来的每一次登录。
 
w命令
 
w命令查询utmp文件并显示当前系统中每个用户和它所运行的进程信息。例如，键入w命令，然后按回车键，将显示如下内容：
 
 
3:36pm up 1 day, 22:34, 6 users, load average: 0.23, 0.29, 0.27
USER TTY FROM LOGIN@ IDLE JCPU PCPU WHAT
chyang pts/0 202.38.68.242 3:06pm 2:04 0.08s 0.04s -bash
ynguo pts/2 202.38.79.47 3:32pm 0.00s 0.14s 0.05 w
lewis pts/3 202.38.64.233 1:55pm 30:39 0.27s 0.22s -bash
lewis pts/4 202.38.64.233 1:35pm 6.00s 4.03s 0.01s sh /home/users/
ynguo pts/7 simba.nic.ustc.e 2:12pm 0.00s 0.47s 0.24s telnet mail
ylou pts/8 202.38.64.235 2:15pm 1:09m 0.10s 0.04s -bash
users命令
 
users命令用单独的一行打印出当前登录的用户，每个显示的用户名对应一个登录会话。如果一个用户有不止一个登录会话，那他的用户名将显示相同的次数。例如，键入users命令，然后按回车键，将显示如下内容：
chyang lewis lewis ylou ynguo ynguo
last命令
 
last命令往回搜索wtmp来显示自从文件第一次创建以来登录过的用户。例如：
 
chyang pts/9 202.38.68.242 Tue Aug 1 08:34 - 11:23 (02:49)
cfan pts/6 202.38.64.224 Tue Aug 1 08:33 - 08:48 (00:14)
chyang pts/4 202.38.68.242 Tue Aug 1 08:32 - 12:13 (03:40)
lewis pts/3 202.38.64.233 Tue Aug 1 08:06 - 11:09 (03:03)
lewis pts/2 202.38.64.233 Tue Aug 1 07:56 - 11:09 (03:12)
 
如果指明了用户，那么last只报告该用户的近期活动，例如，键入last ynguo命令，然后按回车键，将显示如下内容：
 
ynguo pts/4 simba.nic.ustc.e Fri Aug 4 16:50 - 08:20 (15:30)
ynguo pts/4 simba.nic.ustc.e Thu Aug 3 23:55 - 04:40 (04:44)
ynguo pts/11 simba.nic.ustc.e Thu Aug 3 20:45 - 22:02 (01:16)
ynguo pts/0 simba.nic.ustc.e Thu Aug 3 03:17 - 05:42 (02:25)
ynguo pts/0 simba.nic.ustc.e Wed Aug 2 01:04 - 03:16 1+02:12)
ynguo pts/0 simba.nic.ustc.e Wed Aug 2 00:43 - 00:54 (00:11)
ynguo pts/9 simba.nic.ustc.e Thu Aug 1 20:30 - 21:26 (00:55)
 
ac命令
 
ac命令根据当前的/var/log/wtmp文件中的登录进入和退出来报告用户连接的时间（小时），如果不使用标志，则报告总的时间。例如，键入ac命令，然后按回车键，将显示如下内容：
total 5177.47
键入ac -d命令，然后按回车键，将显示每天的总的连接时间：
 
Aug 12 total 261.87
Aug 13 total 351.39
Aug 14 total 396.09
Aug 15 total 462.63
Aug 16 total 270.45
Aug 17 total 104.29
Today total 179.02
 
键入ac -p命令，然后按回车键，将显示每个用户的总的连接时间：
 
ynguo 193.23
yucao 3.35
rong 133.40
hdai 10.52
zjzhu 52.87
zqzhou 13.14
liangliu 24.34
total 5178.24
 
lastlog命令
 
lastlog 文件在每次有用户登录时被查询。可以使用lastlog命令检查某特 定用户上次登录的时间，并格式化输出上次登录日志 /var/log/lastlog的内容。它根据UID排序显示登录名、端口号（tty）和上次登录时间。如果一个用户从未登录过，lastlog显示 **Never logged**。注意需要以root身份运行该命令，例如：
 
rong 5 202.38.64.187 Fri Aug 18 15:57:01 +0800 2000
dbb **Never logged in**
xinchen **Never logged in**
pb9511 **Never logged in**
xchen 0 202.38.64.190 Sun Aug 13 10:01:22 +0800 2000
 
另外，可加一些参数，例如，"last -u 102"命令将报告UID为102的用户；"last -t 7"命令表示限制为上一周的报告。
 
五、进程统计
 
   UNIX 可以跟踪每个用户运行的每条命令，如果想知道昨晚弄乱了哪些重要的文件，进 程统计子系统可以告诉你。它还对跟踪一个侵入者有帮助。与连接时间日志不同，进程统计子系统默认不激活，它必须启动。在Linux系统中启动进程统计使用 accton命令，必须用root身份来运行。
   accton命令的形式为：accton file，file必须事先存在。
  先使用touch命令创建pacct文件：touch /var/log/pacct，然后运行accton：accton /var/log/pacct。一旦accton被激活，就可以使用lastcomm命令监测系统中任何时候执行的命令。若要关闭统计，可以使用不带任何 参数的accton命令。
 
lastcomm命令报告以前执行的文件。不带参数时，lastcomm命令显示当前统计文件生命周期内记录的所有命令的有关信息。包括命令名、用户、tty、命令花费的CPU时间和一个时间戳。如果系统有许多用户，输入则可能很长。看下面的例子：
 
crond F root ?? 0.00 secs Sun Aug 20 00:16
promisc_check.s S root ?? 0.04 secs Sun Aug 20 00:16
promisc_check root ?? 0.01 secs Sun Aug 20 00:16
grep root ?? 0.02 secs Sun Aug 20 00:16
tail root ?? 0.01 secs Sun Aug 20 00:16
sh root ?? 0.01 secs Sun Aug 20 00:15
ping S root ?? 0.01 secs Sun Aug 20 00:15
ping6.pl F root ?? 0.01 secs Sun Aug 20 00:15
sh root ?? 0.01 secs Sun Aug 20 00:15
ping S root ?? 0.02 secs Sun Aug 20 00:15
ping6.pl F root ?? 0.02 secs Sun Aug 20 00:15
sh root ?? 0.02 secs Sun Aug 20 00:15
ping S root ?? 0.00 secs Sun Aug 20 00:15
ping6.pl F root ?? 0.01 secs Sun Aug 20 00:15
sh root ?? 0.01 secs Sun Aug 20 00:15
ping S root ?? 0.01 secs Sun Aug 20 00:15
sh root ?? 0.02 secs Sun Aug 20 00:15
ping S root ?? 1.34 secs Sun Aug 20 00:15
locate root ttyp0 1.34 secs Sun Aug 20 00:15
accton S root ttyp0 0.00 secs Sun Aug 20 00:15
 
   进程统计的一个问题是pacct文件可能增长得十分迅速。这时需要交互式地或经过 cron机制运行sa命令来保证日志数据在系统控制内。sa命令报告、清理并维护进程统计文件。它能把/var/log/pacct中的信息压缩到摘要文 件/var/log/savacct和 /var/log/usracct中。这些摘要包含按命令名和用户名分类的系统统计数据。在默认情况下sa先读它们，然后读pacct文件，使报告能包含 所有的可用信息。sa的输出有下面一些标记项。


/var/log目录下的20个Linux日志文件功能详解 :

如果愿意在Linux环境方面花费些时间，首先就应该知道日志文件的所在位置以及它们包含的内容。在系统运行正常的情况下学习了解这些不同的日志文件有助于你在遇到紧急情况时从容找出问题并加以解决。

以下介绍的是20个位于/var/log/ 目录之下的日志文件。其中一些只有特定版本采用，如dpkg.log只能在基于Debian的系统中看到。
/var/log/messages — 包括整体系统信息，其中也包含系统启动期间的日志。此外，mail，cron，daemon，kern和auth等内容也记录在var/log/messages日志中。
/var/log/dmesg — 包含内核缓冲信息（kernel ring buffer）。在系统启动时，会在屏幕上显示许多与硬件有关的信息。可以用dmesg查看它们。
/var/log/auth.log — 包含系统授权信息，包括用户登录和使用的权限机制等。
/var/log/boot.log — 包含系统启动时的日志。
/var/log/daemon.log — 包含各种系统后台守护进程日志信息。
/var/log/dpkg.log – 包括安装或dpkg命令清除软件包的日志。
/var/log/kern.log – 包含内核产生的日志，有助于在定制内核时解决问题。
/var/log/lastlog — 记录所有用户的最近信息。这不是一个ASCII文件，因此需要用lastlog命令查看内容。
/var/log/maillog /var/log/mail.log — 包含来着系统运行电子邮件服务器的日志信息。例如，sendmail日志信息就全部送到这个文件中。
/var/log/user.log — 记录所有等级用户信息的日志。
/var/log/Xorg.x.log — 来自X的日志信息。
/var/log/alternatives.log – 更新替代信息都记录在这个文件中。
/var/log/btmp – 记录所有失败登录信息。使用last命令可以查看btmp文件。例如，”last -f /var/log/btmp | more“。
/var/log/cups — 涉及所有打印信息的日志。
/var/log/anaconda.log — 在安装Linux时，所有安装信息都储存在这个文件中。
/var/log/yum.log — 包含使用yum安装的软件包信息。
/var/log/cron — 每当cron进程开始一个工作时，就会将相关信息记录在这个文件中。
/var/log/secure — 包含验证和授权方面信息。例如，sshd会将所有信息记录（其中包括失败登录）在这里。
/var/log/wtmp或/var/log/utmp — 包含登录信息。使用wtmp可以找出谁正在登陆进入系统，谁使用命令显示这个文件或信息等。
/var/log/faillog – 包含用户登录失败信息。此外，错误登录命令也会记录在本文件中。

除了上述Log文件以外， /var/log还基于系统的具体应用包含以下一些子目录：
/var/log/httpd/或/var/log/apache2 — 包含服务器access_log和error_log信息。
/var/log/lighttpd/ — 包含light HTTPD的access_log和error_log。
/var/log/mail/ – 这个子目录包含邮件服务器的额外日志。
/var/log/prelink/ — 包含.so文件被prelink修改的信息。
/var/log/audit/ — 包含被 Linux audit daemon储存的信息。
/var/log/samba/ – 包含由samba存储的信息。
/var/log/sa/ — 包含每日由sysstat软件包收集的sar文件。
/var/log/sssd/ – 用于守护进程安全服务。

除了手动存档和清除这些日志文件以外，还可以使用logrotate在文件达到一定大小后自动删除。可以尝试用vi，tail，grep和less等命令查看这些日志文件。