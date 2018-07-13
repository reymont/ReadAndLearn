Jenkins+Gitlab+Sonar代码检查平台搭建-Jenkins - CSDN博客 http://blog.csdn.net/Dream_Flying_BJ/article/details/54694605

安装JDK

从官网安装，这里选择yum安装，我已经摆脱tar包综合征。怎么快怎么来，后期我将发布docker环境。敬请期待ing…

http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html 
这里写图片描述
安装命令

yum -y install jdk-8u111-linux-x64.rpm

这里写图片描述

安装Jenkins

安装
    wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
    rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
    yum install jenkins
启动jenkins
    service jenkins start
获取初始密码
    tail -f /var/log/jenkins/jenkins.log
1
2
3
4
5
6
7
8
9
这里写图片描述

输入密码 
这里写图片描述
初始化要等一段时间，默认安装插件就行，后续的插件到tools里面选

这里写图片描述
后续自己创建个账号密码。

安装jenkins插件

Jenkins安装配置各种插件:
Git  ---- GitLab ---- Gitlab Authentication plugin  (Git授权插件)
Gitlab Authentication plugin (环境变量注入,目前用于获取gitLog,并传递给Fir.im上传信息)
Email Extension  (邮件扩展插件,打包完成后邮件通知各人员)
Fir Plugin  (Fir.im上传插件,apk/ipa 分发渠道)
Bearychat Plugin (上传到Bearychat插件,同于通知)
Gradle Plugin   (Android 构建插件)
Xcode integration  (iOS构建插件)
Keychains and Provisioning Profiles Management  (iOS证书配置插件)
Sonar:代码质量管理平台,也是通过安装各种插件来扩展代码检测功
SonarQube Plugin(代码审查插件)
1
2
3
4
5
6
7
8
9
10
11
系统管理–>插件管理–>选择你需要的

配置Jenkins环境

需要配置sonar环境，同时要在sonar里面生成Token。请看sonar搭建篇。 
这里是jenkins的系统配置

这里写图片描述
sonar的token配置 
这里写图片描述
这里写图片描述 
配置Sonar_Runner 
这里写图片描述

Jenkins和Gitlab免秘钥，同时可以拉取代码

我理解admin用户下的ssh免秘钥，可以拉取其他用户代码。我拉智标项目可以。（通过这个方法可以快速建立jenkins和gitlab免秘钥认证。同时实现拉起代码） 
这里写图片描述
这里写图片描述
JENKINS里面的配置，注意路径 
这里写图片描述
这里写图片描述
这里写图片描述

拉取代码、配置sonar配置文件

这里写图片描述
构建触发5分钟执行一次 
这里写图片描述
还有一种只有开发提交到gitlab以后才会触发构建，没错呢就是gitlab钩子。jenkins配置只需点一点。 
这里写图片描述
jenkins失败构建重试 
这里写图片描述
删除旧的构建，不然增量就把目录搞爆了，我之前默认在var下，就呵呵了，周末收了70多封告警邮件提示构建失败。 
这里写图片描述
构建时选择Sonar插件 
这里写图片描述
好了这会可以构建完成了。当然领导说要发邮件给开发，这个需求我觉得蛮合理的。 
这里写图片描述
这里写图片描述
这里写图片描述
这里写图片描述
这个是扩容邮件的插件，里面可以配置成功后发邮件给开发，当然我写了个html页面，发个网页过去高大上多了。 
这里写图片描述
哈哈哈哈哈哈 
这里写图片描述 
这里写图片描述
同事的代码结果不方便拿出来晒，怕被打~~~#_# 
这个是jenkins和jdk的安装，其实应该先装jdk和sonar。请看第二篇soanr