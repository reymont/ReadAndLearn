https://segmentfault.com/a/1190000008949515

今天来跟大家分享的是奇虎360开源的 QConf 配置中心。

为什么我们需要做这么一件事情?

因为遇到了，当业务分布较广，配置分布较广的时候，就会很容易地出现一些问题，比如做了负载均衡，需要调整一下应用配置。刚好改漏了一台机，就偶尔出现一些问题，排查起来也是很吃力的。

QConf 的架构: QConf架构

除了 QConf 本身提供的工具之外，我们用到了一个有掌阅科技开发的 zkdash zookeeper 管理工具。

个人理解:

QConf 可以说是一个 zookeeper 的客户端，通过 agent 去 watch zookeeper 的变化，数据存在本机，当 zookeeper 发生变化是，自动改变本地数据，来达到同步更新的效果。



这也就是为什么 QConf 需要搭配 zookeeper 去使用的原因之一吧。

QConf 服务端
QConf使用ZooKeeper集群作为服务端提供服务。众所周知，ZooKeeper是一套分布式应用程序协调服务，根据上面提到的对配置内容的定位，我们认为可以将单条配置内容直接存储在ZooKeeper的一个ZNode上，并利用ZooKeeper的Watch监听功能实现配置变化时对客户端的及时通知。 按照ZooKeeper的设计目标，其只提供最基础的功能，包括顺序一致，原子性，单一系统镜像，可靠性和及时性。

我们选择Zookeeper还因为它有如下特点：

1、类文件系统的节点组织

2、稳定，无单点问题

3、订阅通知机制

关于Zookeeper，更多见：https://zookeeper.apache.org/

QConf 客户端
因为ZooKeeper在接口方面只提供了非常基本的操作，并且其客户端接口原始，所以我们需要在QConf的客户端部分解决如下问题：

1、降低与ZooKeeper的链接数 原生的ZooKeeper客户端中，所有需要获取配置的进程都需要与ZooKeeper保持长连接，在生产环境中每个客户端机器可能都会有上百个进程需要访问数据，这对ZooKeeper的压力非常大而且也是不必要的。

2、本地缓存 当然我们不希望客户端进程每次需要数据都走网络获取，所以需要维护一份客户端缓存，仅在配置变化时更新。

3、容错 当进程死掉，网络终端，机器重启等异常情况发生时，我们希望能尽可能的提供可靠的配置获取服务。

4、多语言版本接口 目前提供的语言版本包括：c，php，java，python，go，lua，shell。

5、配置更新及时 可以秒级同步到所有客户端机器。

6、高效的配置读取 内存级的访问速度。

安装
了解完基础的知识和原理，就开始动手实践想法和操作吧，理论要和实践结合，不然就瞎扯淡了。

环境

Linux: Ubuntu 16.04

安装 zookeeper

安装包地址: zookeeper

$ sudo wget http://apache.stu.edu.tw/zookeeper/zookeeper-3.4.9/zookeeper-3.4.9.tar.gz
$ sudo tar -zxvf zookeeper-3.4.9.tar.gz
解压完成后，是可以直接运行 zkServer 的，但是需要配置自己的基础信息。

$ cd zookeeper-3.4.9
$ sudo cp conf/zoo_sample.cfg conf/zoo.cfg
启动 zkServer

$ cd ../
$ ./bin/zkServer.sh start
默认监听: 0.0.0.0:2181

测试服务是否启动: telnet 127.0.0.1 2181 输入 stat

Zookeeper version: 3.4.9-1757313, built on 08/23/2016 06:50 GMT
Clients:
  xxx

Latency min/avg/max: 0/0/51
Received: 252717
Sent: 252716
Connections: 5
Outstanding: 0
Zxid: 0x13
Mode: standalone
Node count: 10
会输出上述信息，服务器启动成功.

然后创建一下 zookeeper 测试数据:

sh zkCli.sh

    create /demo demo
    create /demo/confs confs
    create /demo/confs/conf1 111111111111111111111
    create /demo/confs/conf2 222222222222222222222
    create /demo/confs/conf3 333333333333333333333
QConf

安装方式可以查看官方 wiki

安装 FAQ

安装完 qconf 后，进入 qconf 安装目录，调整 idc.conf

$ cd conf/
$ sudo vim idc.conf
输入自己的 zookeeper 服务器地址，多个用 , 隔开:

#[zookeeper]
############################################################################
#                             QCONF config                                 #
############################################################################
# all the zookeeper host configuration.
#[zookeeper]
zookeeper.test=zookeeper host
保存即可。

启动 QConf agent。

在 ubuntu 下使用 bash 去启动
$ sudo bash ./bin/agent-cmd.sh start
启动成功，查看 QConf 命令。

qconf get_conf /demo/confs/conf1
qconf get_batch_keys /demo/confs
如果返回对应的信息，那几说明可以正常获取数据了。如果失败，就去 logs/ 目录查询错误信息，对应修改。

安装 PHP 扩展

/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config --with-libqconf-dir=/usr/local/qconf/include --enable-static LDFLAGS=/usr/local/qconf/lib/libqconf.a
make
make install
qconf 配置在 qconf 安装的目录中，根据路径找到对应的依赖包即可。

安装完后，添加到 php.ini，使用 php --ini 查看配置文件位置。

查看扩展安装:

php -m | grep qconf
QConf 操作 API

安装完 QConf 和 zookeeper，安装我们的管理后台。

zkdash

需要 Python >= 2.7，如果是 centos65 的用户，需要升级自己的 Python 版本，升级方法请看: Python升级
地址: zkdash

安装完 zkdash，配置对应节点，进行管理即可。

zkdash Web管理服务默认是全网公开访问的，需要修改监听host和端口，修改方式
$ sudo vim init.py
修改监听的 host 地址:

 74 def main():
 75     """主程序入口
 76     """
 77     logger.init_logger(LOG_ITEMS, suffix=OPTIONS.port)
 78     application = Application()
 79     http_server = tornado.httpserver.HTTPServer(application,
 80                                                 xheaders=True)
 81     http_server.listen(OPTIONS.port, address="输入你需要监听的地址") 
 82     tornado.ioloop.IOLoop.instance().start()
 83
address 是新增的 host 参数。本身是没有的

恭喜你，你已经构建完自己的配置中心了。接下来需要做的是，提高性能，和稳定性，扩展 zookeeper。我只能帮你到这里了，接下来的路，自己走吧。

更多开源项目欢迎关注: https://github.com/janhuang