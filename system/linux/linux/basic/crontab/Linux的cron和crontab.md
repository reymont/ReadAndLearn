

Linux的cron和crontab - iTech - 博客园
 http://www.cnblogs.com/itech/archive/2011/02/09/1950226.html

 转自：http://blogold.chinaunix.net/u/31547/showart_438018.html

 

一 cron

crond位于/etc/rc.d/init.d/crond 或 /etc/init.d 或 /etc/rc.d /rc5.d/S90crond,最总引用/var/lock/subsys/crond。

 

cron是一个linux下的定时执行工具（相当于windows下的scheduled task），可以在无需人工干预的情况下定时地运行任务task。由于cron 是Linux的service（deamon），可以用以下的方法启动、关闭这个服务： 
/sbin/service crond start //启动服务 
/sbin/service crond stop //关闭服务 
/sbin/service crond restart //重启服务 
/sbin/service crond reload //重新载入配置 

你也可以将这个服务在系统启动的时候自动启动： 
在/etc/rc.d/rc.local这个脚本的末尾加上： 
/sbin/service crond start 

现在cron这个服务已经在进程里面了，我们就可以用这个服务了。

 

二 crontab

crontab位于/usr/bin/crontab。

 

cron服务提供crontab命令来设定cron服务的，以下是这个命令的一些参数与说明： 
crontab -u //设定某个用户的cron服务，一般root用户在执行这个命令的时候需要此参数 
crontab -l //列出某个用户cron服务的详细内容 
crontab -r //删除某个用户的cron服务 
crontab -e //编辑某个用户的cron服务  


比如说root查看自己的cron设置：crontab -u root -l 
再例如，root想删除fred的cron设置：crontab -u fred -r 
在编辑cron服务时，编辑的内容有一些格式和约定，输入：crontab -u root -e 进入vi编辑模式，编辑的内容一定要符合下面的格式：

*/1 * * * * ls >> /tmp/ls.txt 
这个格式的前一部分是对时间的设定，后面一部分是要执行的命令，如果要执行的命令太多，可以把这些命令写到一个脚本里面，然后在这里直接调用这个脚本就可以了，调用的时候记得写出命令的完整路径。时间的设定我们有一定的约定，前面五个*号代表五个数字，数字的取值范围和含义如下： 

分钟　（0-59） 
小時　（0-23） 
日期　（1-31） 
月份　（1-12） 
星期　（0-6）//0代表星期天 

除了数字还有几个个特殊的符号就是"*"、"/"和"-"、","，*代表所有的取值范围内的数字，"/"代表每的意思,"*/5"表示每5个单位，"-"代表从某个数字到某个数字,","分开几个离散的数字。以下举几个例子说明问题： 

每天早上6点 
0 6 * * * echo "Good morning." >> /tmp/test.txt //注意单纯echo，从屏幕上看不到任何输出，因为cron把任何输出都email到root的信箱了。 

每两个小时 
0 */2 * * * echo "Have a break now." >> /tmp/test.txt 

晚上11点到早上8点之间每两个小时，早上八点 
0 23-7/2，8 * * * echo "Have a good dream：）" >> /tmp/test.txt 

每个月的4号和每个礼拜的礼拜一到礼拜三的早上11点
0 11 4 * 1-3 command line 

1月1日早上4点
0 4 1 1 * command line 

每次编辑完某个用户的cron设置后，cron自动在/var/spool/cron下生成一个与此用户同名的文件，此用户的cron信息都记录在这个文件中，这个文件是不可以直接编辑的，只可以用crontab -e 来编辑。cron启动后每过一份钟读一次这个文件，检查是否要执行里面的命令。因此此文件修改后不需要重新启动cron服务。 

 

三 编辑/etc/crontab配置文件 
cron的系统级配置文件位于/etc/crontab。


cron服务每分钟不仅要读一次/var/spool/cron内的所有文件，还需要读一次/etc/crontab配置文件,因此我们配置这个文件也能运用 cron服务做一些事情。用crontab -e进行的配置是针对某个用户的，而编辑/etc/crontab是针对系统的任务。此文件的文件格式是：

SHELL=/bin/bash 
PATH=/sbin:/bin:/usr/sbin:/usr/bin 
MAILTO=root      //如果出现错误，或者有数据输出，数据作为邮件发给这个帐号 
HOME=/    //使用者运行的路径,这里是根目录 

# run-parts 

01 * * * * root run-parts /etc/cron.hourly //每小时执行/etc/cron.hourly内的脚本 
02 4 * * * root run-parts /etc/cron.daily //每天执行/etc/cron.daily内的脚本
22 4 * * 0 root run-parts /etc/cron.weekly //每星期执行/etc/cron.weekly内的脚本 
42 4 1 * * root run-parts /etc/cron.monthly //每月去执行/etc/cron.monthly内的脚本 

大家注意"run-parts"这个参数了，如果去掉这个参数的话，后面就可以写要运行的某个脚本名，而不是文件夹名了。

 

四 实例

--------------------------------------

基本格式 : [参数间必须使用空格隔开]
*　　*　　*　　*　　*　　command
分　时　日　月　周　命令

第1列表示分钟1～59 每分钟用*或者 */1表示
第2列表示小时1～23（0表示0点）
第3列表示日期1～31
第4列表示月份1～12
第5列标识号星期0～6（0表示星期天）
第6列要运行的命令

crontab文件的一些例子：

30 21 * * * /usr/local/etc/rc.d/lighttpd restart
上面的例子表示每晚的21:30重启lighttpd 。

45 4 1,10,22 * * /usr/local/etc/rc.d/lighttpd restart
上面的例子表示每月1、10、22日的4 : 45重启lighttpd 。

10 1 * * 6,0 /usr/local/etc/rc.d/lighttpd restart
上面的例子表示每周六、周日的1 : 10重启lighttpd 。

0,30 18-23 * * * /usr/local/etc/rc.d/lighttpd restart
上面的例子表示在每天18 : 00至23 : 00之间每隔30分钟重启lighttpd 。

0 23 * * 6 /usr/local/etc/rc.d/lighttpd restart
上面的例子表示每星期六的11 : 00 pm重启lighttpd 。

* */1 * * * /usr/local/etc/rc.d/lighttpd restart
每一小时重启lighttpd

* 23-7/1 * * * /usr/local/etc/rc.d/lighttpd restart
晚上11点到早上7点之间，每隔一小时重启lighttpd

0 11 4 * mon-wed /usr/local/etc/rc.d/lighttpd restart
每月的4号与每周一到周三的11点重启lighttpd

0 4 1 jan * /usr/local/etc/rc.d/lighttpd restart
一月一号的4点重启lighttpd

 

五 特殊用法

@hourly /usr/local/www/awstats/cgi-bin/awstats.sh
使用 @hourly 對應的是 0 * * * *, 還有下述可以使用:
string            meaning
------           -------
@reboot        Run once, at startup.
@yearly         Run once a year, "0 0 1 1 *".
@annually      (same as @yearly)
@monthly       Run once a month, "0 0 1 * *".
@weekly        Run once a week, "0 0 * * 0".
@daily           Run once a day, "0 0 * * *".
@midnight      (same as @daily)
@hourly         Run once an hour, "0 * * * *". 
 

完！