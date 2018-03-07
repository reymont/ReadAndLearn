SonarQube代码质量管理平台安装与使用 - CSDN博客 http://blog.csdn.net/hunterno4/article/details/11687269

Sonar简介

Sonar是一个用于代码质量管理的开源平台，用于管理源代码的质量，可以从七个维度检测代码质量

通过插件形式，可以支持包括java,C#,C/C++,PL/SQL,Cobol,JavaScrip,Groovy等等二十几种编程语言的代码质量管理与检测

sonarQube能带来什么？

Developers' Seven Deadly Sins
1.糟糕的复杂度分布
  文件、类、方法等，如果复杂度过高将难以改变，这会使得开发人员难以理解它们，
  且如果没有自动化的单元测试，对于程序中的任何组件的改变都将可能导致需要全面的回归测试



2.重复
  显然程序中包含大量复制粘贴的代码是质量低下的
  sonar可以展示源码中重复严重的地方



3.缺乏单元测试
  sonar可以很方便地统计并展示单元测试覆盖率



4.没有代码标准
  sonar可以通过PMD,CheckStyle,Findbugs等等代码规则检测工具规范代码编写
5.没有足够的或者过多的注释
  没有注释将使代码可读性变差，特别是当不可避免地出现人员变动时，程序的可读性将大幅下降
  而过多的注释又会使得开发人员将精力过多地花费在阅读注释上，亦违背初衷
6.潜在的bug
  sonar可以通过PMD,CheckStyle,Findbugs等等代码规则检测工具检测出潜在的bug



7.糟糕的设计（原文Spaghetti Design，意大利面式设计）
  通过sonar可以找出循环，展示包与包、类与类之间的相互依赖关系
  可以检测自定义的架构规则
  通过sonar可以管理第三方的jar包
  可以利用LCOM4检测单个任务规则的应用情况
  检测耦合

关于Spaghetti Design：http://docs.codehaus.org/display/SONAR/Spaghetti+Design

通过sonar可以有效检测以上在程序开发过程中的七大问题



SonarQube安装

预置条件
1.已安装JAVA环境
2.已安装有MySQL数据库

软件下载地址：http://www.sonarqube.org/downloads/
下载SonarQube与SonarQube Runner
中文补丁包下载：http://docs.codehaus.org/display/SONAR/Chinese+Pack

1.数据库配置
进入数据库命令
#mysql -u root -p

mysql> CREATE DATABASE sonar CHARACTER SET utf8 COLLATE utf8_general_ci; 
mysql> CREATE USER 'sonar' IDENTIFIED BY 'sonar';
mysql> GRANT ALL ON sonar.* TO 'sonar'@'%' IDENTIFIED BY 'sonar';
mysql> GRANT ALL ON sonar.* TO 'sonar'@'localhost' IDENTIFIED BY 'sonar';
mysql> FLUSH PRIVILEGES;

2.安装sonar与sonar-runner
将下载的sonar-3.7.zip包解压至Linux某路径如/usr/local
将下载的sonar-runner-dist-2.3.zip包解压某路径/usr/local
添加SONAR_HOME、SONAR_RUNNER_HOME环境变量，并将SONAR_RUNNER_HOME加入PATH

修改sonar配置文件
编辑<install_directory>/conf/sonar.properties文件，配置数据库设置，默认已经提供了各类数据库的支持
这里使用mysql，因此取消mysql模块的注释
#vi sonar.properties

[java] view plain copy
sonar.jdbc.username:                       sonar  
sonar.jdbc.password:                       sonar  
sonar.jdbc.url:                            jdbc:mysql://localhost:3306/sonar?useUnicode=true&characterEncoding=utf8&rewriteBatchedStatements=true  
  
# Optional properties  
sonar.jdbc.driverClassName:                com.mysql.jdbc.Driver  


修改sonar-runner的配置文件
切换至sonar-runner的安装目录下，修改sonar-runner.properties
根据实际使用数据库情况取消相应注释

[java] view plain copy
#Configure here general information about the environment, such as SonarQube DB details for example  
#No information about specific project should appear here  
#----- Default SonarQube server  
sonar.host.url=http://localhost:9000  
#----- PostgreSQL  
#sonar.jdbc.url=jdbc:postgresql://localhost/sonar  
#----- MySQL  
sonar.jdbc.url=jdbc:mysql://localhost:3306/sonar?useUnicode=true&characterEncoding=utf8  
#----- Oracle  
#sonar.jdbc.url=jdbc:oracle:thin:@localhost/XE  
#----- Microsoft SQLServer  
#sonar.jdbc.url=jdbc:jtds:sqlserver://localhost/sonar;SelectMethod=Cursor  
#----- Global database settings  
sonar.jdbc.username=sonar  
sonar.jdbc.password=sonar  
#----- Default source code encoding  
sonar.sourceEncoding=UTF-8  
#----- Security (when 'sonar.forceAuthentication' is set to 'true')  
sonar.login=admin  
sonar.password=admin  


3.添加数据库驱动
除了Oracle数据库外，其它数据库驱动都默认已经提供了，且这些已添加的驱动是sonar唯一支持的，因此不需要修改
如果是Oracle数据库，需要复制JDBC驱动至<install_directory>/extensions/jdbc-driver/oracle目录


4.启动服务
目录切换至sonar的<install_directory>/bin/linux-x86-64/目录，启动服务
#./sonar.sh start   启动服务
#./sonar.sh stop    停止服务
#./sonar.sh restart 重启服务

至此，sonar就安装好了
访问http:\\localhost:9000即可

5.sonar中文补丁包安装
中文包安装
安装中文补丁包可以通过访问http:\\localhost:9000，打开sonar后，进入更新中心安装
或者下载中文补丁包后，放到SONARQUBE_HOME/extensions/plugins目录，然后重启SonarQube服务



sonar作为Linux服务并开机自启动
新建文件/etc/init.d/sonar，输入如下内容：

[java] view plain copy
#!/bin/sh  
#  
# rc file for SonarQube  
#  
# chkconfig: 345 96 10  
# description: SonarQube system (www.sonarsource.org)  
#  
### BEGIN INIT INFO  
# Provides: sonar  
# Required-Start: $network  
# Required-Stop: $network  
# Default-Start: 3 4 5  
# Default-Stop: 0 1 2 6  
# Short-Description: SonarQube system (www.sonarsource.org)  
# Description: SonarQube system (www.sonarsource.org)  
### END INIT INFO  
   
/usr/bin/sonar $*  


SonarQube开机自启动（Ubuntu, 32位）：

sudo ln -s $SONAR_HOME/bin/linux-x86-32/sonar.sh /usr/bin/sonar
sudo chmod 755 /etc/init.d/sonar
sudo update-rc.d sonar defaults

SonarQube开机自启动（RedHat, CentOS, 64位）：

sudo ln -s $SONAR_HOME/bin/linux-x86-64/sonar.sh /usr/bin/sonar
sudo chmod 755 /etc/init.d/sonar
sudo chkconfig --add sonar



使用SonarQube Runner分析源码

预置条件
已安装SonarQube Runner且环境变量已配置，即sonar-runner命令可在任意目录下执行

1.在项目源码的根目录下创建sonar-project.properties配置文件
以android项目为例：

[java] view plain copy
sonar.projectKey=android-sonarqube-runner  
sonar.projectName=Simple Android project analyzed with the SonarQube Runner  
sonar.projectVersion=1.0  
sonar.sources=src  
sonar.binaries=bin/classes  
sonar.language=java  
sonar.sourceEncoding=UTF-8  
sonar.profile=Android Lint  


注：要使用Android Lint
规则分析需要先访问http:\\localhost:9000更新中心添加Android Lint插件，使其可以分析Android Lint规则

2.执行分析
切换到项目源码根目录，执行命令
# sonar-runner
分析成功后访问http:\\localhost:9000即可查看分析结果

不同参数的意思：
http://docs.codehaus.org/display/SONAR/Analysis+Parameters
不同项目的源码分析示例下载：
https://github.com/SonarSource/sonar-examples/zipball/master



与IDE关联

最后，当然了，得与IDE相关联，才能更方便地实时查看

以Eclipse为例，请见：http://docs.sonarqube.org/display/SONAR/SonarQube+in+Eclipse

附：

sonarQube官网地址：http://www.sonarqube.org/
sonarQube官方文档地址：http://docs.codehaus.org/display/SONAR/Documentation
sonarQube示例地址：http://nemo.sonarqube.org/

网上另两篇相关的文章：http://www.cnblogs.com/gao241/p/3190701.html
                                       http://www.myexception.cn/open-source/1307345.html