

linux下用cron定时执行任务的方法_Linux_脚本之家 
http://www.jb51.net/article/15008.htm

名称 : crontab 

使用权限 : 所有使用者 

使用方式 : 

crontab file [-u user]-用指定的文件替代目前的crontab。 
crontab-[-u user]-用标准输入替代目前的crontab. 
crontab-1[user]-列出用户目前的crontab. 
crontab-e[user]-编辑用户目前的crontab. 
crontab-d[user]-删除用户目前的crontab. 
crontab-c dir- 指定crontab的目录。 
crontab文件的格式：M H D m d cmd. 

基本格式 : 

* * * * * command 
分 时 日 月 周 命令 
M: 分钟（0-59）。每分钟用*或者 */1表示 
H：小时（0-23）。（0表示0点） 
D：天（1-31）。 
m: 月（1-12）。 
d: 一星期内的天（0~6，0为星期天）。 

cmd要运行的程序，程序被送入sh执行，这个shell只有`USER,HOME,SHELL`这三个环境变量 

说明 : 

crontab 是用来让使用者在固定时间或固定间隔执行程序之用，换句话说，也就是类似使用者的时程表。-u user 是指设定指定 user 的时程表，这个前提是你必须要有其权限(比如说是 root)才能够指定他人的时程表。如果不使用 -u user 的话，就是表示设定自己的时程表。 

参数 : 

crontab -e : 执行文字编辑器来设定时程表，内定的文字编辑器是 VI，如果你想用别的文字编辑器，则请先设定 VISUAL 环境变数来指定使用那个文字编辑器(比如说 setenv VISUAL joe) 
crontab -r : 删除目前的时程表 
crontab -l : 列出目前的时程表 
crontab file [-u user]-用指定的文件替代目前的crontab。 

时程表的格式如下 : 

f1 f2 f3 f4 f5 program 

其中 f1 是表示分钟，f2 表示小时，f3 表示一个月份中的第几日，f4 表示月份，f5 表示一个星期中的第几天。program 表示要执行的程序。 
当 f1 为 * 时表示每分钟都要执行 program，f2 为 * 时表示每小时都要执行程序，其馀类推 
当 f1 为 a-b 时表示从第 a 分钟到第 b 分钟这段时间内要执行，f2 为 a-b 时表示从第 a 到第 b 小时都要执行，其馀类推 
当 f1 为 */n 时表示每 n 分钟个时间间隔执行一次，f2 为 */n 表示每 n 小时个时间间隔执行一次，其馀类推
当 f1 为 a, b, c,... 时表示第 a, b, c,... 分钟要执行，f2 为 a, b, c,... 时表示第 a, b, c...个小时要执行，其馀类推 

使用者也可以将所有的设定先存放在档案 file 中，用 crontab file 的方式来设定时程表。 

例子 : 

```sh
#每天早上7点执行一次 /bin/ls : 
0 7 * * * /bin/ls 
#在 12 月内, 每天的早上 6 点到 12 点中，每隔3个小时执行一次 /usr/bin/backup : 
0 6-12/3 * 12 * /usr/bin/backup 
#周一到周五每天下午 5:00 寄一封信给 alex@domain.name : 
0 17 * * 1-5 mail -s "hi" alex@domain.name < /tmp/maildata 
#每月每天的午夜 0 点 20 分, 2 点 20 分, 4 点 20 分....执行 echo "haha" 
20 0-23/2 * * * echo "haha" 
```
注意 : 

当程序在你所指定的时间执行后，系统会寄一封信给你，显示该程序执行的内容，若是你不希望收到这样的信，请在每一行空一格之后加上 > /dev/null 2>&1 即可 

例子2 : 
```sh
#每天早上6点10分 
10 6 * * * date 
#每两个小时 
0 */2 * * * date 
#晚上11点到早上8点之间每两个小时，早上8点 
0 23-7/2，8 * * * date 
#每个月的4号和每个礼拜的礼拜一到礼拜三的早上11点 
0 11 4 * mon-wed date 
#1月份日早上4点 
0 4 1 jan * date 
```

范例 

$crontab -l 列出用户目前的crontab. 

/usr/lib/cron/cron.allow表示谁能使用crontab命令。如果它是一个空文件表明没有一个用户能安排作业。如果这个文件不存在，而有另外一个文件/usr/lib/cron/cron.deny,则只有不包括在这个文件中的用户才可以使用crontab命令。如果它是一个空文件表明任何用户都可安排作业。两个文件同时存在时cron.allow优先，如果都不存在，只有超级用户可以安排作业。 

crontab文件的一些例子： 

```sh
30 21 * * * /usr/local/etc/rc.d/lighttpd restart 
#上面的例子表示每晚的21:30重启apache。 
45 4 1,10,22 * * /usr/local/etc/rc.d/lighttpd restart 
#上面的例子表示每月1、10、22日的4 : 45重启apache。 
10 1 * * 6,0 /usr/local/etc/rc.d/lighttpd restart 
#上面的例子表示每周六、周日的1 : 10重启apache。 
0,30 18-23 * * * /usr/local/etc/rc.d/lighttpd restart 
#上面的例子表示在每天18 : 00至23 : 00之间每隔30分钟重启apache。 
0 23 * * 6 /usr/local/etc/rc.d/lighttpd restart 
#上面的例子表示每星期六的11 : 00 pm重启apache。 
* */1 * * * /usr/local/etc/rc.d/lighttpd restart 
#每一小时重启apache 
* 23-7/1 * * * /usr/local/etc/rc.d/lighttpd restart 
#晚上11点到早上7点之间，每隔一小时重启apache 
0 11 4 * mon-wed /usr/local/etc/rc.d/lighttpd restart 
#每月的4号与每周一到周三的11点重启apache 
0 4 1 jan * /usr/local/etc/rc.d/lighttpd restart 
#一月一号的4点重启apache 
```
例子： 

每两个时间值中间使用逗号分隔。 

除了数字还有几个个特殊的符号就是”*”、”/”和”-”、”,”，*代表所有的取值范围内的数字，”/”代表每的意思,”*/5″表示每5个单位，”-”代表从某个数字到某个数字,”,”分开几个离散的数字。 

```sh
#每天早上6点 
0 6 * * * echo "Good morning." >> /tmp/test.txt //注意单纯echo，从屏幕上看不到任何输出，因为cron把任何输出都email到root的信箱了。 
#每两个小时 
0 */2 * * * echo "Have a break now." >> /tmp/test.txt 
#晚上11点到早上8点之间每两个小时，早上八点 
0 23-7/2，8 * * * echo "Have a good dream：）" >> /tmp/test.txt 
#每个月的4号和每个礼拜的礼拜一到礼拜三的早上11点 
0 11 4 * 1-3 command line 
#1月1日早上4点 
0 4 1 1 * command line 
```
每次编辑完某个用户的cron设置后，cron自动在/var/spool/cron下生成一个与此用户同名的文件，此用户的cron信息都记录在这个文件中，这个文件是不可以直接编辑的，只可以用crontab -e 来编辑。cron启动后每过一份钟读一次这个文件，检查是否要执行里面的命令。因此此文件修改后不需要重新启动cron服务。 

2.编辑/etc/crontab 文件配置cron 

`cron 服务每分钟不仅要读一次/var/spool/cron内的所有文件`，
还需要读一次/etc/crontab,

因此我们配置这个文件也能运用cron服务做一些事情。用crontab配置是针对某个用户的，
而编辑`/etc/crontab是针对系统的任务`。此文件的文件格式是： 

SHELL=/bin/bash 

PATH=/sbin:/bin:/usr/sbin:/usr/bin 

MAILTO=root //如果出现错误，或者有数据输出，数据作为邮件发给这个帐号 

HOME=/ //使用者运行的路径,这里是根目录 

# run-parts 

01 * * * * root run-parts /etc/cron.hourly //每小时执行/etc/cron.hourly内的脚本 

02 4 * * * root run-parts /etc/cron.daily //每天执行/etc/cron.daily内的脚本 

22 4 * * 0 root run-parts /etc/cron.weekly //每星期执行/etc/cron.weekly内的脚本 

42 4 1 * * root run-parts /etc/cron.monthly //每月去执行/etc/cron.monthly内的脚本 

二、cron 定时 

cron是一个linux下的定时执行工具，可以在无需人工干预的情况下运行作业。由于Cron 是Linux的内置服务，但它不自动起来，可以用以下的方法启动、关闭这个服务： 

/sbin/service crond start //启动服务 
/sbin/service crond stop //关闭服务 
/sbin/service crond restart //重启服务 
/sbin/service crond reload //重新载入配置 

你也可以将这个服务在系统启动的时候自动启动： 

在/etc/rc.d/rc.local这个脚本的末尾加上： 

/sbin/service crond start 

现在Cron这个服务已经在进程里面了，我们就可以用这个服务了，Cron服务提供以下几种接口供大家使用：

1、直接用crontab命令编辑 

cron服务提供crontab命令来设定cron服务的，以下是这个命令的一些参数与说明： 
crontab -u //设定某个用户的cron服务，一般root用户在执行这个命令的时候需要此参数 
crontab -l //列出某个用户cron服务的详细内容 
crontab -r //删除某个用户的cron服务 
crontab -e //编辑某个用户的cron服务 

比如说root查看自己的cron设置：`crontab -u root -l`
再例如，root想删除fred的cron设置：`crontab -u fred -r`
在编辑cron服务时，编辑的内容有一些格式和约定，输入：crontab -u root -e 

进入vi编辑模式，编辑的内容一定要符合下面的格式：*/1 * * * * ls >> /tmp/ls.txt 

这个格式的前一部分是对时间的设定，后面一部分是要执行的命令，如果要执行的命令太多，可以把这些命令写到一个脚本里面，然后在这里直接调用这个脚本就可以了，调用的时候记得写出命令的完整路径。时间的设定我们有一定的约定，前面五个*号代表五个数字，数字的取值范围和含义如下： 
分钟 （0-59） 
小時 （0-23） 
日期 （1-31） 
月份 （1-12） 
星期 （0-6）//0代表星期天 

除了数字还有几个个特殊的符号就是"*"、"/"和"-"、","，*代表所有的取值范围内的数字，"/"代表每的意思,"*/5"表示每5个单位，"-"代表从某个数字到某个数字,","分开几个离散的数字 

cron用法很简单：先来一个速成的： 
第一步：写cron脚本文件。例如：取名一个 crontest.cron的文本文件，只需要写一行： 
             15,30,45,59 * * * * echo "xgmtest.........." >> xgmtest.txt 
             表示，每隔15分钟，执行打印一次命令 
第二步：添加定时任务。执行命令 “crontab crontest.cron”。搞定 
第三步：如不放心，可以输入 "crontab -l" 查看是否有定时任务 
详细信息： 

crontab用法  
　　crontab命令用于安装、删除或者列出用于驱动cron后台进程的表格。也就是说，用户把需要执行的命令序列放到crontab文件中以获得执行。每个用户都可以有自己的crontab文件。下面就来看看如何创建一个crontab文件。  

　　在/var/spool/cron下的crontab文件不可以直接创建或者直接修改。crontab文件是通过crontab命令得到的。现在假设有个用户名为foxy，需要创建自己的一个crontab文件。首先可以使用任何文本编辑器建立一个新文件，然后向其中写入需要运行的命令和要定期执行的时间。  

　　然后存盘退出。假设该文件为/tmp/test.cron。再后就是使用crontab命令来安装这个文件，使之成为该用户的crontab文件。键入：  

　　crontab test.cron  

　　这样一个crontab 文件就建立好了。可以转到/var/spool/cron目录下面查看，发现多了一个foxy文件。这个文件就是所需的crontab 文件。用more命令查看该文件的内容可以发现文件头有三行信息：  

　　#DO NOT EDIT THIS FILE -edit the master and reinstall.  
　　#（test.cron installed on Mon Feb 22 14:20:20 1999）  
　　#（cron version --$Id:crontab.c，v 2.13 1994/01/17 03:20:37 vivie Exp $）  
　　大概意思是：  

　　#切勿编辑此文件——如果需要改变请编辑源文件然后重新安装。  

　　#test.cron文件安装时间：14:20:20 02/22/1999  

　　如果需要改变其中的命令内容时，还是需要重新编辑原来的文件，然后再使用crontab命令安装。  

　　可以使用crontab命令的用户是有限制的。如果/etc/cron.allow文件存在，那么只有其中列出的用户才能使用该命令；如果该文件不存在但cron.deny文件存在，那么只有未列在该文件中的用户才能使用crontab命令；如果两个文件都不存在，那就取决于一些参数的设置，可能是只允许超级用户使用该命令，也可能是所有用户都可以使用该命令。  

　　crontab命令的语法格式如下：  

　　crontab [-u user] file  

　　crontab [-u user]{-l -r -e}  

　　第一种格式用于安装一个新的crontab 文件，安装 淳褪莊ile所指的文件，如果使用“-”符号作为文件名，那就意味着使用标准输入作为安装来源。  

　　-u 如果使用该选项，也就是指定了是哪个具体用户的crontab 文件将被修改。如果不指定该选项，crontab 将默认是操作者本人的crontab ，也就是执行该crontab 命令的用户的crontab 文件将被修改。但是请注意，如果使用了su命令再使用crontab 命令很可能就会出现混乱的情况。所以如果是使用了su命令，最好使用-u选项来指定究竟是哪个用户的crontab文件。  

　　-l 在标准输出上显示当前的crontab。  
　　-r 删除当前的crontab文件。  
　　-e 使用VISUAL或者EDITOR环境变量所指的编辑器编辑当前的crontab文件。当结束编辑离开时，编辑后的文件将自动安装。  

　　[例7]  

　　# crontab -l #列出用户目前的crontab。  
　　10 6 * * * date  
　　0 /2 * * date  
　　0 23-7/2，8 * * * date  
　　#  

　　在crontab文件中如何输入需要执行的命令和时间。该文件中每行都包括六个域，其中前五个域是指定命令被执行的时间，最后一个域是要被执行的命令。每个域之间使用空格或者制表符分隔。格式如下：  

　　minute hour day-of-month month-of-year day-of-week commands  

　　第一项是分钟，第二项是小时，第三项是一个月的第几天，第四项是一年的第几个月，第五项是一周的星期几，第六项是要执行的命令。这些项都不能为空，必须填入。如果用户不需要指定其中的几项，那么可以使用*代替。因为*是统配符，可以代替任何字符，所以就可以认为是任何时间，也就是该项被忽略了。在表4- 1中给出了每项的合法范围。  

　表4-1　指定时间的合法范围  

时间 minute hour day-of-month month-of-year day-of-week   
合法值 00-59 00-23 01-31 01-12 0-6 (0 is sunday)   

　　这样用户就可以往crontab 文件中写入无限多的行以完成无限多的命令。命令域中可以写入所有可以在命令行写入的命令和符号，其他所有时间域都支持列举，也就是域中可以写入很多的时间值，只要满足这些时间值中的任何一个都执行命令，每两个时间值中间使用逗号分隔。  

　除了数字还有几个个特殊的符号就是"*"、"/"和"-"、","，*代表所有的取值范围内的数字，"/"代表每的意思,"/5"表示每5个单位，"-"代表从某个数字到某个数字,","分开几个离散的数字。  

几个例子：  

```sh
每天早上6点  
0 6 * * * echo "Good morning." >> /tmp/test.txt //注意单纯echo，从屏幕上看不到任何输出，因为cron把任何输出都email到root的信箱了。每两个小时  
0 */2 * * * echo "Have a break now." >> /tmp/test.txt晚上11点到早上8点之间每两个小时，早上八点  
0 23-7/2，8 * * * echo "Have a good dream：）" >> /tmp/test.txt每个月的4号和每个礼拜的礼拜一到礼拜三的早上11点  
0 11 4 * 1-3 command line1月1日早上4点  
0 4 1 1 * command line SHELL=/bin/bash PATH=/sbin:/bin:/usr/sbin:/usr/bin MAILTO=root //如果出现错误，或者有数据输出，数据作为邮件发给这个帐号 HOME=/        //使用者运行的路径,这里是根目录 # run-parts 01 * * * * root run-parts /etc/cron.hourly //每小时执行/etc/cron.hourly内的脚本 02 4 * * * root run-parts /etc/cron.daily //每天执行/etc/cron.daily内的脚本 22 4 * * 0 root run-parts /etc/cron.weekly //每星期执行/etc/cron.weekly内的脚本 42 4 1 * * root run-parts /etc/cron.monthly //每月去执行/etc/cron.monthly内的脚本 大家注意"run-parts"这个参数了，如果去掉这个参数的话，后面就可以写要运行的某个脚本名，而不是文件夹名了。 　  
这就是表示任意天任意月，其实就是每天的下午4点、5点、6点的5 min、15 min、25 min、35 min、45 min、55 min时执行命令。  
5，15，25，35，45，55 16，17，18 * * * command在每周一，三，五的下午3：00系统进入维护状态，重新启动系统。那么在crontab 文件中就应该写入如下字段：  
　　00 15 * * 1，3，5 shutdown -r +5然后将该文件存盘为foxy.cron，再键入crontab foxy.cron安装该文件。  
每小时的10分，40分执行用户目录下的innd/bbslin这个指令：  
　　10，40 * * * * innd/bbslink每小时的1分执行用户目录下的bin/account这个指令：  
　1 * * * * bin/account每天早晨三点二十分执行用户目录下如下所示的两个指令（每个指令以;分隔）：  
20 3 * * * （/bin/rm -f expire.ls logins.bad;bin/expire$#@62;expire.1st）　　  
每年的一月和四月，4号到9号的3点12分和3点55分执行/bin/rm -f expire.1st这个指令，并把结果添加在mm.txt这个文件之后（mm.txt文件位于用户自己的目录位置）。  
　　12,55 3 4-9 1,4 * /bin/rm -f expire.1st$#@62;$#@62;mm.txt 
```

crontab的正确用法(简短节省大家时间)命令： 1 man cron 2 man crontab 3 man 5 crontab ==> 中间有个5。命令"crontab -e": -------------------------------------------------------------------------------- PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/X11R6/bin #这是盲点，没想过要设，一次次的失望。［冒号分隔］ DISPLAY=:0.0 #加上吧，有冒号有句点。 # 分 钟 日 月 周 命令 1 23 1 8 * shutdown -h +3 #1月8日23点1分关机(延时3分钟) 1,4,7 23 1 8 * # 1分，4分，7分[1月8日23点] */3 23 1 8 * # 0,3,6,9...每隔3分钟（或每过3分钟，与每3分钟有点不同） [1-10]/3 23 1 8 * # 1分，4分，7分[从1分起，逐次加3分钟，直到大于10==>这是 正确解法] ＠reboot shutdown -k now #这行能把你吓坏，一开机就关机（要是把"-k"换成"-h"的话）。 "@reboot"表示启动时执行。 ---------------------------------END-------------------------------------------- 另一个脚本： ******************************************************************************* [0-59]/5 23 * * * shutdown -h now #每天晚上11点每隔5分钟关一次机，愿望很好，但是将不会执行，因为没设PATH变量，解决方法见下行。 [0-59]/5 23 * * * /sbin/shutdown -h now #保证关得很死，给出了路径。 0 6 1 8 * xmms /music/zhangchu/轻取.mp3 #明天早上6点钟放首歌叫我。但睡到7点钟还是没听到音乐，伤心失望。[DISPLAY=:0.0]。对本行的最后一点补充：现今99%主板都支持定时开机，没有闹钟的话可以叫电脑叫醒你，选项在BIOS电源里面［wake up by alarm]。 *********************************END******************************************* 可以自由修改，最初发布于Linuxsir网站。  
我们来看一个超级用户的crontab文件： 
 　　#Run the ‘atrun' program every minutes 　　#This runs anything that's due to run from ‘at'.See man ‘at' or ‘atrun'. 　　0,5,10,15,20,25,30,35,40,45,50,55 * * * * /usr/lib/atrun 　　40 7 * * * updatedb 　　8,10,22,30,39,46,54,58 * * * * /bin/sync