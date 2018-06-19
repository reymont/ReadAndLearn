

1、在CAT目录下，用maven构建项目

    mvn clean install -DskipTests
    
    如果下载有问题，可以尝试翻墙后下载，可以 git clone git@github.com:dianping/cat.git mvn-repo 下载到本地，这个分支是cat编译需要的依赖的一些jar ，将这些jar放入本地的maven仓库文件夹中。
2、配置CAT的环境

mvn cat:install
Note：

Linux\Mac 需要对/data/appdatas/cat和/data/applogs/cat有读写权限
Windows 则是对系统运行盘下的/data/appdatas/cat和/data/applogs/cat有读写权限,如果cat服务运行在e盘的tomcat中，则需要对e:/data/appdatas/cat和e:/data/applogs/cat有读写权限
  此步骤是配置一些cat启动需要的基本数据库配置
3、(Optional)如果安装了hadoop集群，需到/data/appdatas/cat/server.xml中配置对应hadoop信息。将localmode设置为false，默认情况下，CAT在开发模式（localmode=true）下工作。

4、启动的cat单机版本基本步骤

检查下/data/appdatas/cat/ 下面需要的几个配置文件，配置文件在源码script 。
在cat目录下执行 mvn install -DskipTests 。
cat-home打包出来的war包，重新命名为cat.war, 并放入tomcat的webapps 。
启动tomcat
访问 http://localhost:8080/cat/r
具体详细的还可以参考 http://unidal.org/cat/r/home?op=view&docName=deploy
5、遇到jar不能下载的情况

cat jar在cat的mvn-repo分支下，可以download到本地，再copy至本地的仓库目录
git clone https://github.com/dianping/cat.git
cd cat
git checkout mvn-repo
cp -R * ~/.m2/repository
6、导入eclipse发现找不到类

请先执行mvn eclipse:eclipse 会自动生成相关的类文件
作为普通项目导入eclipse，不要用作为maven项目导入eclipse
7、可以参考script目录下详细资料