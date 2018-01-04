

30分钟zabbix入门——最简单有效的zabbix快速学习法 
http://mp.weixin.qq.com/s/B16Fb15eQl3fjMginClwHQ

2017-10-17 解牛_冯雅杰 运维派
在公司搭建系统级别的监控，由于ELK对流量监控存在局限——现有的工具只记录了累计的流量，而无法计算每时每刻的流量。所以决定最后用zabbix来对网络做监控和报警，下面会从零开始记录zabbix搭建过程中的所有步骤，希望可以给你带来帮助。


安装前准备工作


安装必要的软件，禁用SELINUX，安装必备软件




LAMP环境搭建


安装



启动mysql，设置开机启动，修改mysql密码，注意下面的yourpassword要替换为你自己的密码




安装zabbix服务





创建zabbix数据库




导入数据




修改zabbix配置


注意：下面的yourpasswd请替换为你自己的数据库密码



修改时区




修改zabbix登录密码（可选）





启动




设置开机启动



通过http://hostname/zabbix访问zabbix的安装页面，填写安装信息，完成安装。完成安装后，初始登录账户密码为Admin/zabbix。




安装zabbix-agent


zabbix-server安装好了，下面需要“接入”其他机器，将它们纳入到zabbix-server的管理，下面是安装步骤



配置zabbix-agent



启动zabbix-agent



下面在zabbix-server页面上添加这个机器



按下图填写即可



接着绑定模板



最后点击Update，你就可以在Host目录中看到所有被监控的机器列表



注意：如果zabbix-agent需要被其他机器调用，例如通过zabbix_get获得监控信息，需要在防火墙设置“放开10050端口”


监控网络流量


假设我们要监控机器192.168.8.5网卡em1上的出入口流量，我们可以先在zabbix服务器上用zabbix_get命令来测试一下，下面代码测试的是输入流量，注意这里的输出是一个累积的流量



监控网络流量的流程为：

创建模板



创建监控项
创建应用：Configuration->Templates->Create application





创建监控项：Configuration->Templates->network traffic on em1->Items->Create Item




上图是入口流量的监控项设置，出口流量监控项network traffic out em1可以一样设置，成功后你看到的是



创建Triggers
Triggers是触发报警的设置，同样我们点击Configuration->Templates->network traffic on em1->Triggers->Create trigger来创建Triggers



注意在设置Expression时，我们可以利用zabbix提供给我们的模板







于是，入口流量的触发值就设置好了，每秒流量超过1048576时就会触发报警，同理我们可以设置出口流量的触发值，成功后，我们看到的是



创建Graphs
接着，我们再来创建Graphs，Graphs可以以图形化的方式展示流量信息，点击Configuration->Templates->network traffic on em1->Graphs->Create graph，创建Graphs的最大好处是我们可以把这些Graphs组合起来形成Screens监控面板，例如下面这样



下面是创建Graphs的表单



绑定Template
至此，我们模板就创建完毕了，最后一步需要把主机和模板关联起来，点击Configuration->Hosts->Templates->Select创建关联，然后点击Add



此时，通过Monitoring->Latest data可以看到网卡上的最新数据，同时可以通过Monitoring->Graphs来查看图形化的数据







自定义script报警


当系统出现异常时，我们需要立即发现，并通过邮件或App的方式通知给维护的同学，这样整个系统才会掌控在我们手中，Zabbix要做到这一点，需要配置以下3个选项（zabbix虽然很强大，但配置和UI有点繁琐，这是我不喜欢它的地方）：

Media types

Events

User Media


Media types


Media types是当产生事件时，以什么方式进行通知，这里采用的是Script方式，这种方式的灵活性最大，通过这种方式，我们可以把报警发送到任何支持Webhook的App上，例如钉钉

Script这种方式的原理是：我们把可执行的脚本放在zabbix的指定目录下，当事件发生时，zabbix会自动调用该脚本，可以在/etc/zabbix/zabbix_server.conf中找到指定目录的路径



Media types设置如下，意思是在/usr/lib/zabbix/alertscripts下存在一个脚本dingding.py，当事件发生时，zabbix会调用该脚本，同时会传入该脚本3个参数，这3个参数分别是事件的接收人、事件的主题、事件的内容



dingding.py这个脚本如下，我们先实现一个简单的版本，也就是把这3个参数输出到日志中



设置脚本的权限




Events



事件是当某个条件发生时，zabbix所创建的报警对象。在zabbix中，事件发生时和事件恢复时都可以触发事件，下面我们来创建一个事件，




可以看到，这里的事件主题和事件消息都是系统默认生成的，其中包括时间产生时的必要信息，同时我把允许事件恢复时通知（Recovery message）打了勾，Conditions标签页的内容保持不变，然后我们再来修改Operations标签里的内容




这里的意思是：事件的持续时间是1个小时（3600s），每隔2分钟（120s）产生一个事件，一共产生10个事件，产生事件时，发送给Zabbix administrators用户组中的Admin用户，最后事件会使用我们刚刚创建的dingding这种Media type


User Meida


事件和Media type创建好后，下面还需要把它们和指定用户关联起来，点击Administration->Users->Media->Add，修改后，点击Update




通过以上步骤，我们已经把zabbix的监控和报警建立起来了，并实操创建了网卡的流量监控，现在我们把网络流量的阈值调到小，故意制造一个超出流量的事故，看一下报警是否生效，我们预期是发送10个报警，发送完毕后，我们再把阈值调到正常，看下是否会收到恢复消息。还记得之前写的那个脚本吗，它会把报警内容输出到日志文件中，现在我们检查下日志文件



很显然，结果符合我们的预期。

以上便是入门zabbix的全部内容，后面的文章我们会具体实现dingding.py报警脚本，让你真正的可以在手机上收到报警信息。

作者：解牛_冯雅杰
链接：http://www.jianshu.com/p/4d3af373e682