dubbo-monitor安装、 监控中心 配置过程

http://blog.csdn.net/hxpjava1/article/details/78083649

摸索了好久 .....分享请注明地址！
使用dubbo的话，两个工具是不可少的：
1：dubbo的管理控制台，在之前的笔记中介绍过
2：简易控制中心monitor 

简单介绍下monitor：
Simple Monitor挂掉不会影响到Consumer和Provider之间的调用，所以用于生产环境不会有风险。
 
配置好了之后可以结合admin管理后台使用，可以清晰的看到服务的访问记录、成功次数、失败次数等.....
Simple Monitor采用磁盘存储统计信息，请注意安装机器的磁盘限制，如果要集群，建议用mount共享磁盘。
   charts目录必须放在jetty.directory下，否则页面上访问不了。
  官网的地址：http://alibaba.github.io/dubbo-doc-static/Administrator+Guide-zh.htm#AdministratorGuide-zh-%E7%AE%80%E6%98%93%E7%9B%91%E6%8E%A7%E4%B8%AD%E5%BF%83%E5%AE%89%E8%A3%85

下面就介绍下monitor的配置使用过程：
安装:
[html] view plain copy
<span style="font-size:14px;">wget http://code.alibabatech.com/mvn/releases/com/alibaba/dubbo-monitor-simple/2.4.1/dubbo-monitor-simple-2.4.1-assembly.tar.gz  
tar zxvf dubbo-monitor-simple-2.4.1-assembly.tar.gz  
cd dubbo-monitor-simple-2.4.1</span>  
但是官网的地址好像关闭了，使用不了 ，下面附上csdn的上传地址：http://download.csdn.net/detail/liweifengwf/7864009

配置:
[html] view plain copy
<span style="font-size:14px;">vi conf/dubbo.properties</span>  
编辑包中的这个文件，主要修改一下地方：

最主要的就是广播地址：dubbo.registry,address  改成自己的就行了。
还有charts目录就是生成监控图片的额目录，启动后会自动生成这个目录，有点慢可能要稍等一段时间。

集群环境注册中心配置： dubbo.registry.address=zookeeper://10.135.108.152:2181?backup=10.135.108.153:2181,10.135.108.154:2181

启动:
./bin/start.sh
停止:
./bin/stop.sh
重启:
./bin/restart.sh
调试:
./bin/start.sh debug
系统状态:
./bin/dump.sh
总控入口:
./bin/server.sh start
./bin/server.sh stop
./bin/server.sh restart
./bin/server.sh debug
./bin/server.sh dump

以上都是官方给的启动步骤，按上面的来就行。
启动之后 过一段时候，你在配置文件中指定的目录：dubbo.charts.directory=${dubbo.jetty.directory}/charts  下面就会出来对应的文件，图表目录
然后访问你的界面路径：http://10.0.65.3:8080/   就出现如下的界面了，其他的就看官网的功能介绍吧








最近有人遇到问题说配置了后还是出不来图片，大致有两种情况：
1、在配置dubbo.jetty.directory=/aa/bb/monitor 时候 monitor这个目录不存在，dubbo是不会自动给创建这个目录的，他下面的charts和统计的会自动创建；
2、在服务端需要配置监控的配置文件：<dubbo:monitor protocol="registry" />