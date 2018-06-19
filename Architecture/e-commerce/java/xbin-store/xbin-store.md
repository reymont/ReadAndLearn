
xubinux/xbin-store: 模仿国内知名B2C网站,实现的一个分布式B2C商城 使用Spring Boot 自动配置 Dubbox / MVC / MyBatis / Druid / Solr / Redis 等。使用Spring Cloud版本请查看 https://github.com/xubinux/xbin-store

https://gitee.com/liuyuantao/xbin-store/

模仿国内知名B2C网站,实现的一个分布式B2C商城

进群讨论 群 626068936

Dubbox 版本:

GitHub 地址 : https://github.com/xubinux/xbin-store
OSChina 地址 : http://git.oschina.net/binu/xbin-store
Spring Cloud 版本:

GitHub 地址 : https://github.com/xubinux/xbin-store-cloud
OSChina 地址 : http://git.oschina.net/binu/xbin-store-cloud
使用技术:

后台
使用Spring Boot 构建整个项目 去除 XML 配置
Maven构建项目
Jenkins作为持续集成
采用Dubbox作为RPC框架
kryo序列化
使用 Apollo 配置中心
使用Spring+Spring MVC+MyBatisSSM框架
数据库连接池使用druid
数据库使用MySQL和Redis
页面引擎采用 Beetl
网页采用freemarker生成静态化页面
存储采用FastDFS存储图片等文件
采用Solr实现搜索服务
Swagger2 生成 RESTful Apis文档
负载均衡使用Nginx、keepalived实现高可用
采用Spring Scheduled做任务调度
消息中间件采用RabbitMQ
在分布式事务上则采用了TCC解决订单支付方面时效性要求性高的分布式事务,可靠的消息服务则来解决如会计记录等时效性要求低的分布式事务.
前台
采用基于AdminLTE的roncoo-adminLTE(主要增加了Ajax的布局模式)
AdminLTE集成太多Js这里就不一一列举了
xbin-mobile 移动端

http://git.oschina.net/orangehs/xbin-mobile

目前由 orange 开发,有兴趣可以联系
Pull Request

内容可以是优化、新功能、Bug修复等。

期待您的 Pull Request

运行教程 <----我是教程

点我查看运行教程(不使用Docker)

点我查看运行教程(使用Docker 暂无!)

Tomcat地址(本机)

名称	IP	完成情况
Portal	192.168.125.1:8101	完成情况
Search	192.168.125.1:8102	完成情况
Item	192.168.125.1:8103	完成情况
SSO	192.168.125.1:8104	完成情况
Admin	192.168.125.1:8105	完成情况
Cart	192.168.125.1:8106	完成情况
Order	192.168.125.1:8107	完成情况
Recommended	192.168.125.1:8109	|
AD	192.168.125.1:8110	|
Ranking	192.168.125.1:8111	|
Mymoney	192.168.125.1:8112	|
Pay	192.168.125.1:8113	|
Baitiao	192.168.125.1:8114	|
Coupons	192.168.125.1:8115	|
Seckill	192.168.125.1:8116	|
CS	192.168.125.1:8117	|
API	192.168.125.1:8118	|
Dubbox服务地址

服务名称	Dubbox服务端口	rest服务端口
Admin-Service	192.168.125.1:20880	rest:8510
Redis-Service	192.168.125.1:20881	rest:8511
Search-Service	192.168.125.1:20882	rest:8512
Portal-Service	192.168.125.1:20883	rest:8513
Item-Service	192.168.125.1:20884	rest:8514
SSO-Service	192.168.125.1:20885	rest:8515
Notify-Service	192.168.125.1:20886	rest:8516
Cart-Service	192.168.125.1:20887	rest:8517
Order-Service	192.168.125.1:20888	rest:8518
Home	-Service	192.168.125.1:20889	rest:8519
Recommended-Service	192.168.125.1:20890	rest:8520
AD-Service	192.168.125.1:20891	rest:8521
Ranking-Service	192.168.125.1:20892	rest:8522
Mymoney-Service	192.168.125.1:20893	rest:8523
Pay-Service	192.168.125.1:20894	rest:8524
Baitiao-Service	192.168.125.1:20895	rest:8525
Coupons-Service	192.168.125.1:20896	rest:8526
Seckill-Service	192.168.125.1:20897	rest:8527
CS-Service	192.168.125.1:20898	rest:8528
项目依赖(暂时)

20170413149208646298768.png

结构图(暂时)

20170407149155166510416.png

项目开发进度(暂时)

20170413149208582280568.jpg

实现目标

本项目最终实现的目标 点我查看最后完成效果

运行截图

20170320148998263242121.png 20170320148998264384011.png 201703201489982653612.png 20170320148998266267017.png 20170320148998269698649.png 20170320148998270641283.png 20170320148998271738052.png 20170320148998272353143.png 20170320148998273050196.png 20170320148998275560672.png 20170320148998297295027.png

Zookeeper1 提供服务:Zookeeper
FastDFS1 提供服务:FastDFS Tracker
FastDFS2 提供服务:FastDFS Storage
Redis 提供服务:Redis
Solr 提供服务:Solr
Dubbox Admin 服务使用情况

20170320148998294075274.png

任务管理器

20170320148998292034786.png

启动了 5 台虚拟机＋ 7 台 Tomcat ＋ 9 个 Dubbox 服务 内存使用情况
常见问题

编译失败

编译不成功的都是缺少jar包 麻烦配置Nexus 然后更新整个项目去下载jar包 在继续编译 如还失败 请查看本地maven仓库jar是否真正下载下来

编译成功启动失败

请确保你先启动了zookeeper 并且配置对了zookeeper地址 需要连接数据的请配置好数据密码 service服务有启动顺序 请查看项目依赖图 看看你需要启动的服务依赖那些服务

启动不了

90%是你的jar问题