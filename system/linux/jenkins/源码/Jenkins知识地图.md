

* [Jenkins知识地图 - CSDN博客 ](http://blog.csdn.net/feiniao1221/article/details/10259449)

这篇文章大概写于三个月前，当时写了个大纲列表，但是在CSDN上传资源实在不方便，有时上传了莫名审核不通过，如果以前有人上传过，也会导致上传失败。现在把之前工作中找到的好东西和各位分享。现在不搞这些了，也算是个归档吧。内容主要涉及Hudson/Jenkins的使用，维护，以及插件开发，开发的东西更多些吧。
首先说下Jenkins能干什么？说下两个典型的应用场景。
1. Git/Repo + Gerrit + Jenkins 打造强大的Android持续集成环境。用户上传代码到Gerrit进行code review和入库，用户上传代码操作和入库都可以触发Jenkins获取代码进行自动构建。Jenkins也可以定时构建，构建结果可以通过邮件自动发送给相关人员。当然用户提交代码到Gerrit时，Gerrit也会自动发邮件给具有代码检视权限的人员。
2. SVN/Git + Jenkins 以apk代码为例，Jenkins可以监测SVN/Git等代码配置库，一旦有人提交代码，就会自动获取代码进行构建，构建结果可以通过邮件在内的多种方式通知人员。
以下是之前文章的内容，稍作补充。
===================================
Jenkins知识地图
Jenkins是一款优秀的持续集成工具，源于Hudson，后来由不同的团队维护，两者的使用方法，插件大部分通用，开发方法也大同小异。
在此罗列一些自己积累的一些资料，供有需要的人参考。
1 Jenkins官方网站

首先推荐Jenkins的官方网站。里面不但有Jenkins详细的使用说明，而且有针对于开发者的教程，墙裂推荐！
http://jenkins-ci.org/
Meet Jenkins 介绍Jenkins是什么
Use Jenkins 介绍Jenkins的安装和使用
Extend Jenkins 介绍Jenkins插件和Jenkins本身的开发
Plugins 介绍Jenkins社区上已有的插件列表和使用Wiki，Wiki中介绍了插件的功能，使用方法，源码链接，应用情况。注意这里并没有插件hpi文件下载
Plugin下载 hpi文件下载可以访问这里：http://mirrors.jenkins-ci.org/plugins/ 。当然也可以自己将插件源码下载到本地编译即可。
2. Jenkins书籍

两本Jenkins书籍，网上都可以下载到。至于内容我看的也比较少。就不评论了。
下载链接不保证长期有效，需要的就尽快下载或转存到自己的网盘吧。
Jenkins: The Definitive Guide
http://pan.baidu.com/share/link?shareid=1021560144&uk=1979754919
Jenkins Continuous Integration Cookbook
http://pan.baidu.com/share/link?shareid=1025587179&uk=1979754919
JAVA开发超级工具集_第八章用Hudson持续集成
第一部分 http://download.csdn.net/detail/marking122/4890033
第二部分 http://download.csdn.net/detail/marking122/4890047
3. Jenkins学习资料

Continuous Deployment with Gerrit and Jenkins
http://pan.baidu.com/share/link?shareid=1029989664&uk=1979754919
这是Jenkins官方的一个PPT，建议先看看这个。复习一下基本知识。
4. 一篇经典的Jenkins插件开发入门文档

虽然出自Hudson，但是同样适用于Jenkins
http://www.eclipse.org/hudson/documents/Writing-first-hudson-plugin.pdf
附上一个百度网盘下载链接 
http://pan.baidu.com/share/link?shareid=1032509575&uk=1979754919
5. Hudson Architecture Documents

Hudson官方网站上介绍Jenkins/Hudson架构很好的一个系列PPT
Hudson Architecture Documents
http://pan.baidu.com/share/link?shareid=1034319818&uk=1979754919
Hudson Web/REST Architecture
Hudson View Architecture
Hudson Execution Architecture
Hudson Remote Execution Architecture
Hudson Security Architecture
Hudson Plugin Architecture
6. 国内某博主写的系列文章

很实用，值得推荐。
http://www.cnblogs.com/itech/archive/2011/11/23/2260009.html
7. 淘宝Jenkins开发的系列文档

网上找到的
http://pan.baidu.com/share/link?shareid=1036559705&uk=1979754919
1.使用软件包管理大规模应用.pdf
2.ABS总体介绍.pdf
3.ABS配置案例.pdf
4.DailyBuild简介.pdf
5.ABS与TOAST自动化测试对接介绍.pdf
6.Hudson插件开发-技术文档.pdf
8.Hudson后台管理.pdf
9.ABS常用插件介绍.pdf
abs使用手册.pdf
8. 其他一些不错的中文博客

涉及Jenkins/Hudson使用和开发的很多东西
jenkins 使用文档
http://blog.csdn.net/zhaoxu0312/article/details/7567361#
Hudson插件之按主题分类。这个人的博客里还有很多的关于Hudson的资料。
http://jdonee.iteye.com/blog/515424
Hudson插件开发简介
http://blog.csdn.net/littleatp2008/article/details/7001793
还有这个人的博客
http://scmbob.org/category/cat_jenkins
还有这里
http://blog.csdn.net/OnlyQi/article/category/921911
9. 关于Jelly的教程

Jenkins和插件的UI基本都是用jelly写的，对于jenkins开发非常重要。
jelly 借鉴jsp和jstl，tag library 有34个
http://commons.apache.org/proper/commons-jelly/
常用的tag
https://jenkins-ci.org/maven-site/jenkins-core/jelly-taglib-ref.html
Basic guide to Jelly usage in Jenkins
https://wiki.jenkins-ci.org/display/JENKINS/Basic+guide+to+Jelly+usage+in+Jenkins
jelly:stapler
http://stapler.kohsuke.org/jelly-taglib-ref.html

10. 总结

如果你能把上面的这样都大致看一遍，Jenkins的部署，维护和插件开发都没多大问题了。
总之，从开发的角度看，Jenkins涉及的东西非常多。
代码配置管理可能会涉及到 Git/Reop, SVN
简单的构建步骤是用shell或者batch脚本，有些也会是ant
Jenkins及插件开发会涉及maven
UI开发主要是Jelly，也会涉及到HTML/CSS, JavaScript，YahooUI，AJAX
逻辑开发主要是Java，分布式，JavaBean，JsonObject
Jenkins系统开发接触的比较少，最起码要了解REST API吧。

如果你是某司某持续集成项目组的成员，正好看到这篇文章，先去翻翻你们内部的博客或者服务器，也许能找到更多干货，那些总结的英文或中文的文档还是非常好的，哈哈。