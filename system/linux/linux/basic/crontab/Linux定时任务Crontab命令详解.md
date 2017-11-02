

* [Linux定时任务Crontab命令详解_Linux教程_Linux公社-Linux系统门户网站 ](http://www.linuxidc.com/Linux/2015-10/124478.htm)

crontab的语法

crontab [-u username] [-l
-e
-r]
选项与参数：

-u ：只有 root 才能进行这个任务，亦即帮其他使用者创建/移除 crontab 工作排程；
-e ：编辑 crontab 的工作内容
-l ：查阅 crontab 的工作内容
-r ：移除所有的 crontab 的工作内容，若仅要移除一项，请用 -e 去编辑

查询使用者目前的 crontab 内容:

crontab -l