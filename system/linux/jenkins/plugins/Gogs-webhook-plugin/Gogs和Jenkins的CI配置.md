

DevOps系列——Gogs和Jenkins的CI配置--docker,.NET,脚本,jenkins,邮件,http,设置,blog http://www.bijishequ.com/detail/410181?p=

jenkins学习笔记

1. jenkins简单介绍
1.1. jenkins是什么
Jenkins是一个开源软件项目，旨在提供一个开放易用的软件平台，使软件的持续集成变成可能
1.2. 大牛系统博客地址
http://blog.csdn.net/GW569453350game/article/category/6311323
http://blog.csdn.net/wangmuming/article/category/2167947
2. 知识点
2.1. 用户和权限配置
http://blog.csdn.net/wangmuming/article/details/22926025
2.2. jenkins的ssh认证
http://blog.csdn.net/gw569453350game/article/details/51911179
2.3. gogs提交代码触发jenkins构建
输入gogs可以下载这个插件，不要输入gogs-webhook-plugins找不到
在gogs项目的钩子中添加hook地址


2.4. pipeline的使用
首先在系统管理-系统设置中增大jenkins的构建进程数，因为jenkins中可能同时启动好几个构建任务


创建的时候使用Pipeline(流水线),pipeline可以执行一系列的操作


然后编写脚本,Pipeline Syntax中有脚本生成器
注意stage之间一定要加空行，否则会报错


运行效果


语法：https://jenkins.io/doc/book/pipeline/
2.5. 发送邮件通知
本文讲的是gogs和jenkins结合
2.5.1. 申请邮箱
首先注册一个163的邮箱
推荐大家使用163的，腾讯企业邮很坑爹，因为需要开启授权码，在开启授权码之后，腾讯企业邮箱之前的密码就不能用了
腾讯企业邮如果想要授权码还一定要和微信绑定http://jingyan.baidu.com/article/6181c3e0b12548152ef153db.html
开启授权认证，输入授权密码，这个授权码代替登录密码，查看smtp服务器地址




2.5.2. 基本配置
然后在jenkins中下载邮件插件
jenkins自带的邮件只能是固定的人太简单，所以可以下载插件Jenkins Email Extension Plugin
这个好像可以设置邮件格式Examil-ext Plugin
https://wiki.jenkins-ci.org/display/JENKINS/Email-ext+plugin#Email-extplugin-TemplateExamples
一个邮件模板:http://blog.163.com/l1_jun/blog/static/143863882016116111321760/
来到jenkins的系统管理->系统设置进行配置
首先设置管理员邮箱，这个邮箱和一会发邮件的邮箱必须是同一个，否则发布出去邮件


设置发送邮件服务器信息






来一个可以复制的
(本邮件是程序自动下发的，请勿回复！)<br/>

项目名称：$PROJECT_NAME<br/>

项目描述：${JOB_DESCRIPTION}<br/>

构建编号：$BUILD_NUMBER<br/>

构建状态：$BUILD_STATUS<br/>

触发原因：${CAUSE}<br/>

构建日志地址：<a href="${BUILD_URL}console">${BUILD_URL}console</a><br/>

构建地址：<a href="$BUILD_URL">$BUILD_URL</a><br/><hr/>

变更集:${JELLY_SCRIPT,template="html"}<br/>
邮件配置的详细语法可以在下面的位置查看

语法：http://blog.csdn.net/chengtong_java/article/details/49815311


2.5.3. jenkins脚本的改变
在jenkins的配置文件中删除--restart always这样的自动重启命令,否则即使代码报错，任务也会算做构建成功,因为只是执行启动命令。
在jenkins的配置文件中加-d有个重大问题
不加上-d那么如果程序没有问题，jenkins的任务就退不出来了
加上-d那么如果程序有问题，jenkins的任务也会算作成功
解决办法就是改变脚本为以下方式
中间需要暂停几秒，否则不能准确读取到容器的状态
当然还有测试的时候才这样写，打版和发布都不用，这涉及到一整套docker策略
echo "正在构建" \
  && cd web-server \
  && docker build -t pomelo-dev-client  . \

  if [ "`docker ps -f name=pomelo-dev-client -q`" ]; then
   echo "stop and rm pomelo-dev-client"
   docker stop pomelo-dev-client
   docker rm pomelo-dev-client
  elif [ "`docker ps -a -f name=pomelo-dev-client -q`" ]; then
   echo "rm pomelo-dev-client"
   docker rm pomelo-dev-client
  else
   echo "pomelo-dev-client不存在"
  fi \
  && docker run -d --name pomelo-dev-client -p 3001:3001 pomelo-dev-client \
  && sleep 4 \

  if [ "`docker ps -f name=pomelo-dev-client -q`" ]; then
   echo "pomelo-dev-client 启动成功"
  elif [ "`docker ps -a -f name=pomelo-dev-client -q`" ]; then
   echo "rm pomelo-dev-client"
   docker rm pomelo-dev-client
   docker run --name pomelo-dev-client -p 3001:3001 pomelo-dev-client
  else
   echo "pomelo-dev-client不存在"
  fi \
2.5.4. 配置邮件触发器
首先jenkins用户都要设置企业邮箱


jenkins项目中设置触发器




高级设置中可以设置触发时机，以下高级设置中的内容可以覆盖系统设置中的基本内容


本来想实现失败10次要给项目经理发邮件，可是Failure-x好像不起作用
2.5.5. 邮件效果


2.5.6. 扩展阅读
gitlab自动发送邮件：http://www.cnblogs.com/shansongxian/p/6605623.html
443错误：http://blog.csdn.net/twc829/article/details/52137794
jenkins邮件配置：http://blog.csdn.net/littlechang/article/details/8706322
2.6. jenkins定时自动构建
http://blog.csdn.net/wangjun5159/article/details/50635481
2.7. 扩展阅读
jenkins国外大牛的ci策略：https://mp.weixin.qq.com/s/0GCvqBIcNgKiGPDR4iNNWA
 免责说明
本文档中的部分内容摘自网上的众多博客，仅作为自己知识的补充和整理，并分享给其他需要的coder，不会用于商用。
因为很多博客的地址看完没有及时做保存，所以很多不会在这里标明出处，非常感谢各位大牛的分享，也希望大家理解。
如果原文作者感觉不适，可以及时联系我shiguoqing999@163.com,我将及时删除争议部分内容
 追责声明
如有大段引用超过全文50%的内容，请在文档结尾标明原文出处：龙马行空-石国庆-https://my.oschina.net/u/1416844/blog，否则将视为抄袭，予以法律追究，请各位尊重个人知识产权。
个人公众号
大家可以关注我的公众号，我会举办线下代码操练活动
   