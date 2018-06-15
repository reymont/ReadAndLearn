https://blog.csdn.net/mydriverc2/article/details/53813321

ps -ax >  tmp.txt
ps -ef > tmp.txt

重定向就可以了。

ps -ef|grep -i root也可以，不知道什么原理