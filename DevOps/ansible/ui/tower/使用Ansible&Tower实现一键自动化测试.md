

使用Ansible&Tower实现一键自动化测试

原创 2017-09-24 Conan 搜狗测试

新旧操作过程对比
无线网页搜索前端nginx 、resin代码上线前需时长为30min的压力测试，原来的操作过程繁琐、重复，经过一段时间的研究、调试，目前使用通过ansible 和 tower来实现压力步骤。我们先看一下之前的压力过程以及现在通过ansible和tower实现压力过程的操作步骤及时间成本对比：

之前压力过程
Ansible&tower实现压力过程
操作步骤：
1、通过xshell登录测试虚机；
2、修改nginx配置连接线下resin环境；
3、分别到nginx、resin代码路径下check nginx、resin代码；
4、到压力脚本路径启动压力脚本；
5、登录监控平台启动监控；
6、压力结束后到resin log路径执行异常统计脚本；
7、将监控结果截图粘贴至邮件，附上异常统计发送开发确认。
1、浏览器登录tower页面
2、选择创建的job template，复制上线tag
3、点击运行，坐等邮件
耗时：
手动操作耗时：3min
人工跟踪耗时：45min~50min
手动操作耗时：10s
人工跟踪耗时：无需人工跟踪

无线网页搜索上线过程中op同学进行完nginx代码上线操作之后，上线一台resin机器，由测试同学用线下nginx机器连接这一台resin进行验证，线下的nginx在压力过程中连接的是测试环境resin模块，因此需要修改线下环境的nginx配置，同样地，我们对比一下之前的操作以及目前操作的步骤:

之前操作
目前操作
步骤：
1、登录虚机；
2、到nginx配置路径修改配置文件并reload；
3、验证reload后是否生效。
1、登录tower页面
2、选择对应job template并点击运行
依赖：
Xshell或者是SecureCRT、浏览器
浏览器
实现方案


Ansible简介
ansible是一款自动化运维工具，基于Python开发，实现了批量系统配置、批量程序部署、批量运行命令等功能。ansible是基于模块工作的，本身没有批量部署的能力。
1、ansible的各模块：
真正具有批量部署能力的是ansible所运行的模块，ansible只是提供一种框架。
主要包括：

2、Playbook
像很多其它配置文件管理方法一样，Ansible使用一种比较直白的方法来描述自己的任务配置文件。Ansible 的任务配置文件被称之为“playbook”，业界人士称之为“剧本”。
介绍几个比较常见的playbook语法：
A)hosts: 代表选择的主机，我们的playbook中设置为all，是因为在tower的inventory中指定了host，后续会有介绍；
B)vars：playbook中使用到的变量，比如我们playbook中用到的username和password分别是在check nginx和resin代码的时候需要的svn用户名和密码，playbook中使用的变量同样也可以在tower中设置，但是为了私密性，在playbook中设置；
C)shell：在hosts指定的主机中执行shell命令；
D)service：启动或停止模块运行；
E)pause：等待特定时间；
F)Register：将上一步的结果注册变量；
G)ignre_errors：有异常时，是否继续执行。

Tower简介
Tower的官方解释是：Ansible Tower (formerly ‘AWX’) is a web-basedsolution that makes Ansible even more easy to use for IT teams of all kinds. It’s designed to be thehub for all of your automation tasks.
个人理解tower是为了方便操作ansible的页面，包括管理远程主机ip、用户名、登录密码的web页面，安装ansible 和tower 后，访问安装机器的ip，Tower登录页面如下图，支持LADP验证。


登录后如下图，可看到最近的执行的任务、管理的inventory(远程主机host)、credentials（远程主机的用户名、密码）、projects、每天执行任务成功和失败的次数。

任务执行的时候可以看到任务的详细信息（如下图中的1位置），以及执行playbook每个步骤的结果（如下图中的2位置）。

怎么在Tower中创建一个任务并执行？
1、创建project，在ansible默认目录/var/lib/awx/projects下选择写好的playbook具体路径

2、创建inventory，添加远程ip:

3、创建credentials，添加username和password：

4、创建job template，并添加需要的外部变量，playbook中的{{resin_code}}、{{nginx_code}}、{{nginx_path}}、{{resin_path}}、{{getcode}}变量就是从这里来的，选择之前步骤创建的inventory、project、credentials、playbook。


5、执行以上创建步骤后，点击火箭标志就可以运行了，在步骤4中创建job template，以后就可以复用了。

六、原有操作的痛点以及目前操作的优势：

原有操作痛点
目前操作优势
1、步骤重复、繁琐：
无线前端每周有例行上线两次，加其他紧急上线、重大上线，压力操作每周平均需要3~4次；
2、修改配置人工误操作风险较高：
曾发生修改配置文件不正确，压力打到线上服务的情况；
3、过度依赖人工：
  压力启停后需及时操作监控平台；
4、无法在手机上操作，有时测试同学无法响应：
紧急上线时，有可能测试同学已经在下班的路上，由于部署环境需要通过xshell连接线下测试环境，会造成测试人员无法操作的情况，影响上线进度。
1、自动化
实现一键压力，到最后收到邮件；
2、降低打压力门槛
良好的交互，从此压力，人人可打；
3、降低人工误操作带来的风险
很大程度上避免人工的干预；
4、压力过程更清晰
tower 显示各个流程的执行时间和执行结果；
5、随时随地打压力
手机连上vpn，通过移动端浏览器随时可以打压力，即使下班路上都可随时响应。
 
七、通过ansible & tower 我们还能做什么？
Ansible的优势在于对多台远程主机进行批量操作部署，组内对ansible & tower另外一个简单的应用是，对组内的测试机进行磁盘监控，如下图，front_test1这个inventory中包含组内的所有测试机器，磁盘空间的使用率阈值以及收件人作为外部变量传递给playbook。


另外，tower中可以设置定时运行任务，如下图所示，设置起始时间、运行频率，这样组内的机器磁盘空间使用率大于阈值的时候，就可以收到邮件了。

