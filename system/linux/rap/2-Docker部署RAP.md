https://github.com/thx/RAP/wiki/docker%E9%83%A8%E7%BD%B2rap

Docker部署方式

Docker部署操作

下载docker部署所需的全部文件
https://github.com/thx/RAP/tree/master_internet/lab/docker-rap
安装Docker，网络文档非常多这里不再赘述。
编译compose组件
docker-compose up
启动RAP服务器
docker-compose run --publish 80:8080 app
其中80端口表示暴露在host的对应端口，如果想映射到其它端口，自行修改即可。

介绍

根目录下的ROOT.war是docker部署用的war包，区别就是config.properties配置文件中host的名称为container之间映射的名称，其它无差异。开源爱好者也可以在调整config后使用docker方式部署。swarm模式的还在开发，后续也会加入，实现分布式部署。
compose分三个组件，app: tomcat服务器, redis: 缓存服务器, mysql: 数据库服务器。相应的操作管理，可以通过docker-compose run -p参数来把mysql/redis的端口也映射到host来进行管理。
配置文件会拉取一些镜像，建议使用国内的加速器。我用的阿里云的私有加速器，具体配置请大家自行解决，有问题也可以回帖或群中讨论。
对于docker我也是近期刚刚学习，目的是快速解决大家部署困难的问题。对于Dockfile/compose文件的优化，大家有好的提议或意见欢迎大家提出。