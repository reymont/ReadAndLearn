https://github.com/thx/RAP/wiki/deploy_manual_cn

构建项目 (war包部署不需要)
获取源代码
导入到IDE
配置环境
安装基本工具
初始化数据库
配置文件
配置context-root （war包部署不需要）
启动项目
常见问题
如何管理团队
如何增加管理员
如何获取更新？
Admin初始密码是什么？
写在最前

部署RAP需要亲具有J2EE+Linux+MySQL的运维知识，如果亲对此不是很了解，建议用http://rap.taobao.org线上版本就可以了。

自己部署RAP服务的同学，为了在有新Release、发现重大安全漏洞时能够及时的通知到各位管理员，请订阅重要信息推送帖

部署方式有两种。

使用编译好的war包部署
适合仅想部署RAP服务，不需开发定制功能的同学
使用源码自行编译、开发后部署
需配置J2EE开发环境， 适合想要研究RAP源代码，开发定制功能的同学
war包部署方法

在Release页面中下载war包（建议用最新）， 将war包修改为ROOT.war后放入tomcat webapps文件夹中。 startup.sh(.bat)启动tomcat，该war包自动部署到文件夹ROOT 停掉服务器，打开ROOT中得WEB-INF/classes/config.properties 来修改数据库配置 启动tomcat，完成部署。

注意，一定要用ROOT部署，历史原因暂时只支持ROOT部署
构建项目 (war包部署不需要)

获取源代码

git clone git@github.com:thx/RAP.git
git checkout release
确保您正确的切换到release分支，否则会出现少包，因为master分支引用一些不对外公开的内部组件，不提供给外部用户使用。

导入到IDE

以MyEclipse为例，在Package Explorer中右键 -> Import -> Existing Projects into Workspace, 将RAP项目导入进来。

根据您IDE的不同，导入项目的方式也有所差异。建议自行检索，如果您根本不懂Java开发，建议跳过这里用编译好的war包部署吧。 d- .-b|||

配置环境

安装基本工具

仅使用源码自行编译才需要安装的(即，使用war包部署不需要安装)
Eclipse/MyEclipse/IDEA
Git
都需要安装的
JDK 1.8+ 若报错，请尽量使用较新版本
MySQL 5.6.12+ 太老的MySQL运行initialize.sql会报多timestamp错误
Tomcat 8.*+ 不要用9alpha，alpha和beta出任何诡异问题我肯定不知道，亲愿意折腾倒也无妨，个人不建议
Redis 3.0+ 部署在本机，默认端口即可
以上工具如何安装自行检索。

安装Redis

RAPA需要部署Redis Server，端口默认即可。建议使用3.0稳定版 下载地址
下载后，解压缩，进入redis文件夹，使用make命令完成编译
执行./src/redis-server 来启动Redis Server，若Redis未启动，RAP会报Redis未启动的异常。建议使用nohup ./src/redis-server & 来启动Redis Server，更多用法见官网文档。
初始化数据库

执行release分支下的SQL脚本： /src/main/resources/database/initialize.sql，该脚本中包含数据库创建、表&结构创建、必要的初始数据创建的全部内容。

注意，因最新的mysql的sql_mode设置的比较严格，需要手动配置下SQL_MODE来禁止full_group检查，可以改MySQL配置文件，或者运行如下SQL语句来修改SQL_MODE：

SET @@global.sql_mode = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
配置文件

请正确配置src/config.properties中的数据库连接地址、用户名和密码。

配置context-root （war包部署不需要）

将context-root设置为/，即访问RAP时，必须是http://domain.com/ 而不能是 http://domain.com/rap/。

设置context-root不同的IDE设置方法不一样，以MyEclipse/Eclipse举例：

MyEclipse中，打开项目属性(Properties), 在Properties -> MyEclipse -> Web -> Web Context-root中，将其修改为/ROOT，以确保RAP部署在tomcat/webapps/ROOT中。
如果是Eclipse, Properties -> Web Project Settings -> Context Root 中修改，确保其为ROOT
启动项目

完成上述步骤，将RAP配置到Tomcat中启动即可。

注意!RAP暂时仅支持在根目录部署，若使用编译好的war包部署，需将war包改名为ROOT.war，以确保RAP部署在webapps/ROOT中！

剩下的就是跟着RAP文档中心首页的教程一步一步开启RAP之旅啦！

常见问题

如何管理团队

在tb_corporation中自行管理，默认在初始化后只有一个默认团队。

如何增加管理员

在tb_role_and_user中添加一条记录，user_id是管理员的id，role_id是1(超级管理员)或2(管理员)。

如何获取更新？

我们会确保release的分支上是可用的版本。在开发环境中git pull来获取最新的源码更新，每一期更新都会有对应的update.md请关注并按照上面的指示进行升级工作。

Admin初始密码是什么？

由于密码进行了加密，所以无法直接登录。

使用管理员账号登陆的方法有很多：

建议自行注册账号，并按照上面的方式添加管理员权限即可。
随便注册个小号，设置密码例如123456，然后将该账户的密码，拷贝的admin的密码列当中。
如果亲使用源代码自行编译，可以通过设置PRIVATE_CONFIG.java中的adminPassword字段（万用密码）来进行登录。