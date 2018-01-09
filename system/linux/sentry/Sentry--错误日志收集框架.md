

Sentry--错误日志收集框架-xujpxm-51CTO博客
 http://blog.51cto.com/xujpxm/1868597


 简介
  Sentry’s real-time error tracking gives you insight into production deployments and information to reproduce and fix crashes.---官网介绍
  `Sentry是一个实时事件日志记录和汇集的日志平台，其专注于错误监控，以及提取一切事后处理所需的信息`。他基于Django开发，目的在于帮助开发人员从散落在多个不同服务器上的日志文件里提取发掘异常，方便debug。Sentry由python编写，源码开放，性能卓越，易于扩展，目前著名的用户有Disqus, Path, mozilla, Pinterest等。它分为客户端和服务端，客户端就嵌入在你的应用程序中间，程序出现异常就向服务端发送消息，服务端将消息记录到数据库中并提供一个web节目方便查看。
  DSN（Data Source Name）
  当你完成sentry配置的时候，你会得到一个称为“DSN”的值，看起来像一个标准的URL。Sentry 服务支持多用户、多团队、多应用管理，每个应用都对应一个 PROJECT_ID，以及用于身份认证的 PUBLIC_KEY 和 SECRET_KEY。由此组成一个这样的 DSN：
'{PROTOCOL}://{PUBLIC_KEY}:{SECRET_KEY}@{HOST}/{PATH}{PROJECT_ID}'
PROTOCOL 通常会是 http 或者 https，HOST 为 Sentry 服务的主机名和端口，PATH 通常为空。
  Sentry支持的语言：
wKiom1gZkXnDOaIBAADqfDmPkEI701.png-wh_50
  安装
 这里有两种方式安装sentry，我这里介绍用docker的安装方式(官网推荐用docker)。
sentry运行需要的服务：
PostgreSQL
Redis
Memcached
Outbound Email
启动sentry需要依赖的服务：
Web Service
Background Workers
Cron Process
容器安装sentry需要的环境：
Docker 1.10.0+
Compose 1.6.0+ (optional)
另外redis、数据库等也可以配置cluster，并结合HAProxy使用。我这里docker容器全部只安装在了一台机器(Ubuntu1404)上。
安装docker
增加GPG key:
1
2
3
4
$ sudo apt-get update
$ sudo apt-get install apt-transport-https ca-certificates
$ sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 \
--recv-keys 58118E89F3A912897C070ADBF76221572C52609D
配置apt仓库：
在/etc/apt/sources.list文件最好追加一行：
1
deb https://apt.dockerproject.org/repo ubuntu-trusty main
安装 docker-engine：
1
2
3
$ sudo apt-get update
$ sudo apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual
$ sudo apt-get install docker-engine
2、安装docker-compose
使用pip安装，如果没有pip需要先安装：
1
2
$ sudo apt-get install python-pip
$ sudo pip install docker-compose
3、构建容器并创建数据库和sentry安装目录
1
2
3
$ sudo apt-get install git
$ sudo git clone 
$ sudo mkdir -p data/{sentry,postgres}
4、生成secret key并添加到docker-compose文件里：
1
2
3
4
$ sudo docker-compose run --rm web config generate-secret-key
# 这里复制生成的字符串
$ sudo vim docker-compose.yml
# 取消SENTRY_SECRET_KEY的注释，并把刚刚复制的字符串插入其中，类似如下：
wKiom1gZm-KSduiSAABJVjeSzNA427.png-wh_50
5、重建数据库，并创建sentry超级管理员用户
1
$ sudo docker-compose run --rm web upgrade
这里采用交互方式创建用户：
upgrade过程：
wKiom1gZpNjxxOMyAAaudUXbTXk112.png-wh_50
创建用户，sentry新建的时候需要一个超级管理员用户：
wKioL1gZpW6ArVEKAANd0oJ7E6g535.png-wh_50
6、启动所有的服务：
1
$ sudo docker-compose up -d
wKiom1gZqJ3CSa4HAANG1lNzXj0703.png-wh_50
7、访问sentry
打开浏览器，输入url:http://ipaddress:9000
访问之前可以检查下容器和端口情况：
docker ps看下当前运行的容器：
wKioL1gZqaKiPlY7AAJc5MOnRi0369.png-wh_50
netstat查看端口打开情况：
wKioL1gZqhqAw9TEAAE2XDH4f8g685.png-wh_50
登陆界面，这里会提示你的Root URL，如果不想更改继续下一步即可完成：
wKiom1gZqpGx9hd5AAIpp1e6U8g213.png-wh_50
页面展示：
wKiom1gZqw-zJZg8AADqkoNCxKI808.png-wh_50
至此sentry搭建完成！
补充：
  Sentry目前用户类型有四种： 超级管理员， 管理员，普通用户和System agents. 超级用户只能通过命令行来创建，其他用户可以自己注册或由其他用户邀请注册加入，然后由超级管理员或管理员分配项目和权限。为了更好支持团队协助以及信息安全，新版本Sentry(5.4.2)经过了重新设计，重新设计后的Sentry以Team为中心组织权限。所谓Team就是一个团队，一些用户组织在一起对某些项目有操作权限的组织。一个项目只能属于一个Team, 一个用户却可以属于多个Team, 并可在不同Team中扮演不同角色， 如用户A在Team X是管理员而在Team Y中是System agents. Sentry对用户角色的指定只能到Team级别，不能到Project级别， 所以将某个用户加入到某个Team之后，这个用户就对所有所有属于这个Team下所有project有了相同的权限。
超级管理员： 能创建各种用户， team和project只能由超级管理员创建。项目的一些设置比如改变Owner, 数据公开可见与否（设为public的数据可以通过url不登陆也能查看）以及客户端domain限制的设定。另外还有管理项目的api key(客户端只有得到此api key才能向Sentry发送消息)的权限等等。
管理员： 能创建用户， team和项目设定中除改变owner之外的权限， 可以对项目中具体数据做resolve, bookmark, public/public和remove操作。
普通用户： 无Team界面，只能对项目中具体数据做resolve, bookmark, public/unpublic和remove操作。
System agents: 无Team界面，只能对项目中具体数据做bookmark, unpublic和remove操作。
参考链接：
docker安装：https://docs.docker.com/engine/installation/linux/ubuntulinux/
sentry安装：https://docs.sentry.io/server/installation/