

35.1.1. Configuring Cron Tasks
 https://www.centos.org/docs/5/html/5.2/Deployment_Guide/s2-autotasks-cron-configuring.html

 The main configuration file for cron, /etc/crontab, contains the following lines:

```conf
SHELL=/bin/bash 
PATH=/sbin:/bin:/usr/sbin:/usr/bin 
MAILTO=root HOME=/  
# run-parts 
01 * * * * root run-parts /etc/cron.hourly 
02 4 * * * root run-parts /etc/cron.daily 
22 4 * * 0 root run-parts /etc/cron.weekly 
42 4 1 * * root run-parts /etc/cron.monthly
```
The first four lines are variables used to configure the environment in which the cron tasks are run. The SHELL variable tells the system which shell environment to use (in this example the bash shell), while the PATH variable defines the path used to execute commands. The output of the cron tasks are emailed to the username defined with the MAILTO variable. If the MAILTO variable is defined as an empty string (MAILTO=""), email is not sent. The HOME variable can be used to set the home directory to use when executing commands or scripts.
前四行是变量用于配置的cron任务的环境中运行。shell变量告诉系统要使用哪个shell环境（在这个例子中是shell），而PATH变量定义了用于执行命令的路径。这个cron任务的输出是通过电子邮件与邮件变量定义的用户名。如果邮寄地址的变量定义为空字符串（mailto =”），电子邮件是不是发。可以使用home变量设置主目录，以便在执行命令或脚本时使用该目录。

Each line in the /etc/crontab file represents a task and has the following format:

minute   hour   day   month   dayofweek   command

* minute — any integer from 0 to 59
* hour — any integer from 0 to 23
* day — any integer from 1 to 31 (must be a valid day if a month is specified)
* month — any integer from 1 to 12 (or the short name of the month such as jan or feb)
* dayofweek — any integer from 0 to 7, where 0 or 7 represents Sunday (or the short name of the week such as sun or mon)
* command — the command to execute (the command can either be a command such as ls /proc >> /tmp/proc or the command to execute a custom script)

As shown in the /etc/crontab file, the run-parts script executes the scripts in the /etc/cron.hourly/, /etc/cron.daily/, /etc/cron.weekly/, and /etc/cron.monthly/ directories on an hourly, daily, weekly, or monthly basis respectively. The files in these directories should be shell scripts.

If a cron task is required to be executed on a schedule other than hourly, daily, weekly, or monthly, it can be added to the /etc/cron.d/ directory. All files in this directory use the same syntax as /etc/crontab. Refer to Example 35.1, “Crontab Examples” for examples.

```conf
 # record the memory usage of the system every monday  
# at 3:30AM in the file /tmp/meminfo 
30 3 * * mon cat /proc/meminfo >> /tmp/meminfo 
# run custom script the first day of every month at 4:10AM 
10 4 1 * * /root/scripts/backup.sh
Example 35.1. Crontab Examples
```