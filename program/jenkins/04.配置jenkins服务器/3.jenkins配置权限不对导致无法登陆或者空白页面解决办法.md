jenkins配置权限不对导致无法登陆或者空白页面解决办法-tenjhon-51CTO博客 http://blog.51cto.com/tengzhaoyong/1398089

找到.jenkins/config.xml文件：
替换为：
1、<authorizationStrategy class="hudson.security.AuthorizationStrategy$Unsecured"/>
这个权限对应“任何用户可以做任何事(没有任何限制)”

2、<authorizationStrategy class="hudson.security.FullControlOnceLoggedInAuthorizationStrategy"/>
这个权限对应“登录用户可以做任何事”

3、<authorizationStrategy class="hudson.security.GlobalMatrixAuthorizationStrategy">
   <permission>hudson.model.Hudson.Administer:test</permission>
   <permission>hudson.scm.SCM.Tag:test</permission>
 </authorizationStrategy>
这个权限对应 test用户可以是管理员、打标签权限。

2、如果要配置连接微软ldap，需要安装Active Directory plugin。
比如配置：
Domain Name: XXXX.net
Domain controller:192.168.0.112:3268

LDAP 全局目录：TCP端口3268 (如果DC保持着全局目录的操纵权)

3、默认匿名用户是可以查看所有项目的，就算配置了“登陆用户可以做任何事情”
如果想禁止匿名使用，可以使用“安全矩阵”，
选择安全矩阵后，就会出现“匿名用户”用户，全部去掉勾选，则无任何权限了。
其中overall中的Administer代表全部权限，可以设置为管理员.
权限配置：http://hi.baidu.com/nesaynever/blog/item/9f34a1c80a6454377d3e6f65.html

其中：Overall是全局权限，slave是集群权限，job,run,view,scm是业务权限。
其中overall中的read要勾选，否则用户登陆后什么也看不到。
overall:
 Administer：系统管理员权限
 read:浏览框架

job:
 read:查看job
 build:执行构建
 cancel:取消构建

run:
 Delete:删除某次构建
 Update:编辑某次构建信息

SCM:
 Tag:为某次构建在svm上打标签。