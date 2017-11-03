

* [Ansible(14)wait_for模块 - CSDN博客 ](http://blog.csdn.net/modoo_junko/article/details/46316295)

模块说明

当你利用service 启动tomcat，或数据库后，他们真的启来了么？这个你是否想确认下？ 
wait_for模块就是干这个的。等待一个事情发生，然后继续。它可以等待某个端口被占用，然后再做下面的事情，也可以在一定时间超时后做另外的事。

常用参数

参数名	是否必须	默认值	选项	说明
connect_timeout	no	5		在下一个事情发生前等待链接的时间，单位是秒
delay	no			延时，大家都懂，在做下一个事情前延时多少秒
host	no	127.0.0.1		执行这个模块的host
path	no			当一个文件存在于文件系统中，下一步才继续。
port	no			端口号，如8080
state	no	started	present/started/stopped/absent	对象是端口的时候start状态会确保端口是打开的，stoped状态会确认端口是关闭的;对象是文件的时候，present或者started会确认文件是存在的，而absent会确认文件是不存在的。
案例

```sh
# 10秒后在当前主机开始检查8000端口，直到端口启动后返回
- wait_for: port=8000 delay=10
# 检查path=/tmp/foo直到文件存在后继续
- wait_for: path=/tmp/foo
# 直到/var/lock/file.lock移除后继续
- wait_for: path=/var/lock/file.lock state=absent
# 直到/proc/3466/status移除后继续
- wait_for: path=/proc/3466/status state=absent
```
到此上次那个家庭作业用到的全部模块都讲解完毕。