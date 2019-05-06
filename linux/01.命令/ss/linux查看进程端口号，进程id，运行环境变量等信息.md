

* [linux查看进程端口号，进程id，运行环境变量等信息 - 博学无忧 ](http://www.bo56.com/linux%E6%9F%A5%E7%9C%8B%E8%BF%9B%E7%A8%8B%E7%AB%AF%E5%8F%A3%E5%8F%B7%EF%BC%8C%E5%8D%A0%E7%94%A8%E5%86%85%E5%AD%98%EF%BC%8C%E8%BF%90%E8%A1%8C%E7%8E%AF%E5%A2%83%E5%8F%98%E9%87%8F%E7%AD%89%E4%BF%A1/)


```sh
# 如何查看进程的端口号？
netstat -lnp | grep exf
#如果进程没有像exfilter一样监控一个端口，如何查看进程的id？
ps aux | grep exfilter
# 我怎么知道这个命令的完整路径？命令是谁启动的？在那里目录启动的？
$strings /proc/5791/environ
```