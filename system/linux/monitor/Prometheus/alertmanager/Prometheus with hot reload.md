Prometheus with hot reload 
http://www.songjiayang.com/technical/prometheuswith-hot-reload/



当 Prometheus 有配置文件修改，我们想加载新的配置信息而不停掉服务的时候，可以采用 Prometheus 提供的热更新的方法。
热更新的加载方法有两种：
1.	kill -HUP pid
2.	curl -X POST http://localhost:9090/-/reload
当你采用以上任一方式执行 reload 成功的时候，将在 promtheus log 中看到如下信息：
 
如果有配置信息填写错误，将导致 reload 失败，你将看到类型如下信息：
ERRO[0161] Error reloading config: couldn't load configuration (-config.file=prometheus.yml): unknown fields in scrape_config: job_nae  source=main.go:146
提示： 我个人更倾向于采用 curl -X POST 的方式，因为每次 reload 过后， pid 会改变，使用 kill 方式需要找到当前进程号。
再分别说下这两种方式 Prometheus 内部实现：
第一种：通过 kill 命令的 HUP (hang up) 参数实现
首先 Prometheus 在 cmd/promethteus/main.go 中实现了对进程系统调用监听， 如果发现是syscall.SIGHUP 的信号，那么就会执行 reloadConfig 函数。
代码类似:
hup := make(chan os.Signal)
signal.Notify(hup, syscall.SIGHUP)
go func() {
  for {
    select {
    case <-hup:
      if err := reloadConfig(cfg.configFile, reloadables...); err != nil {
        log.Errorf("Error reloading config: %s", err)
      }
    }
  }
}()
第二种：通过 web 模块的 /-/reload action 实现。
1.	首先 Prometheus 在 web(web/web.go) 模块中注册了一个 POST 的 action /-/reload, 它的 handler 是 web.reload 函数，该函数主要向 web.reloadCh chan 里面发送一个 chan error。
2.	在 Prometheus 的 cmd/promethteus/main.go 中有个 goroutine 来监听 web 的 reloadCh, 如果有值，那么执行 reloadConfig 函数.
代码类似：
hupReady := make(chan bool)
go func() {
	<-hupReady
	for {
		select {
		case rc := <-webHandler.Reload():
			if err := reloadConfig(cfg.configFile, reloadables...); err != nil {
				log.Errorf("Error reloading config: %s", err)
				rc <- err
			} else {
				rc <- nil
			}
		}
	}
}()
总结：Prometheus 内部提供了成熟的 hot reload 方案，这大大方便配置文件的修改和重新加载。

 Tagged with prometheus 101



JiaYang Song
 http://www.songjiayang.com/me/


基本档案
•	姓名: 宋佳洋
•	年龄: 26
•	学历: 大学本科(西南石油大学2013届)
•	英语: 四级
•	邮件: songjiayang1@gmail.com
•	博客：http://songjiayang.github.io
•	github: https://github.com/songjiayang
职业技能
•	3年互联网行业工作经验，1年带团队经验（4人）；
•	熟悉 *nux 环境开发和部署;
•	熟悉 Ruby/Rails 开发,有3年使用经验,熟悉常见的gems,有源码阅读习惯。
•	熟悉 MySQL, PostgreSQL, Redis;
•	了解 Python, NodeJs, Java, elixir等其他语言;
•	了解和使用一些前端框架，例如 css (bootstrap,pure)， js (ember, react, backbone) 等。
工作履历
•	2009入学西南石油大学,就读计算机科学与技术专业,从此开始了我的程序员之路.
•	2012.10~2013.03 到 团 800 公司做 Ruby 实习.
•	2013.04.25 来上海，工作于现在的公司( GIGA循旅生态科技有限公司)，目前任职技术主管。主要负责 gigabase 和 matter 的研发工作。
岗位职责：
•	负责公司日常系统功能开发。
•	负责系统发布工作。
•	负责同事代码 Review 和合并工作。
项目作品：
•	2011开始接触 Web 开发,自学 JavaEE, 做了一个二手交易平台(inside) ,但是由于种种原因，项目上线不久就停止了.
•	2012 开始接触 Rails,期间开发了个人大学创业项目微大学,一个在线点餐平台。
•	2013 帮助朋友开发了雪球比特币交易系统，此系统最终被比特大陆收购。
•	2014 帮助朋友开发了 Tiny 换汇交易系统 。
•	2015 开发了百善缘绿色有机在线电商平台 。


其他


IT运维利用Slack 传送手机报警讯息-搜狐 
http://mt.sohu.com/20161111/n472932125.shtml


【IT168 技术】由于随着个人及企业对信息科技的需求大幅增加，包含移动设备的兴起，社交网站的活跃，以及许多新技术的快速发展，因此在监测设备的使用状况及可以主动发现设备问题并提前预防和故障排除的能力日渐重要，另外，云端服务的兴起，在IT设备资源大量集中化的需求下，管理人员要有足够的能力去分析网络状态及能缩短排除服务异常问题的时间，此仍为当前IT管理人员的一大挑战。 除前述的功能之外，能够快速部署，以及容易操作也会是考虑的要点之一。
　　Slack 是一款团队通讯平台服务，丰富且高度自定义的功能，提供管理团队一个方便、跨平台且多元整合管理的一个沟通管道，且在与第三方串接上的表现令人深刻。而ICINGA 即为一套容易部署以及容易为网管人员短期学习并使用的监控软件，在此本文以Slack和ICINGA 为功能安装，设定及展示之主角，让读者可全面了解并可简单于读者所使用的网络环境下应用ICINGA 。在本篇文章我们将示范如何利用ICINGA 的监控程序并透过Slack的传讯功能发布即时消息至管理团队。
　　主要包括以下内容：
　　1. Slack 注册与安装
　　2. Slack 设定
　　3. ICINGA 设定
　　4. 告警信息传送测试
　　5. 总结
　　ICINGA与Slack架构原理图
　　Icinga是Nagios 的分支，它提供了全面的监控和报警框架; 是一个容易安装且功能强大的网络监控软件且与 Nagios 一样提供了开放及充足的可扩展性。除可以监控主机之外，任何的设备只要能提供SNMP的服务，如此Icinga即可有充足的信息监控。透过这样的监控协议，我们可以呼叫被监测主机以测量任何可供监控的项目。此外，根据笔者对于其他监控软件的使用经验，如SNSC(IBM System Networking Switch Center)及CNA(Cisco Network Assistant)，两者皆为功能强大的监控软件，但是只针对各自产品做监控而且皆是需付费的软件。因此，相较于Icinga的表现更为全面也较容易符合大众需求。
　　Slack
　　Slack 是「团队沟通平台」, 同时可以在网页版、 Android App、 iPhone App、 Windows 与 Mac 中安装软件使用，跨平台而且实时同步，虽然以网页版的管理功能最完整，但是其它平台也都能满足团队沟通分流的需求, 在 Slack 沟通可以被管理，并转化为有效率的工作流程。在本文中我们把Slack当成是一个client 端，它本身并不提供监控的功能，但透过与Webhook和 ICINGA 的集成，可以提供用户实时报警的功能。
　　架构原理图
　　ICINGA server收集信息的行为如Check_snmp是经由SNMP的服务来认定每个硬件的ID值来取得数值，回传到server上并以图表纪录，当有报警情况产生，即可透过Slack Clinet 传送讯信息管理员。
　　 
　　▲架构原理图
　　操作系统准备
　　 
　　1. Slack 网页注册与安装
　　Slack 支持 Mac, Windows 及 iOS & Andorid, 下面将介绍网页注册和手持装置配置过程。
　　 
　　1.1 网页注册方式
　　利用网页方式新建账号，注册网址为https://slack.com/，输入Email后，选择 " Create New Team"。
　　 
　　电邮会收到由Slack寄来的验证信，在网页上输入验证码。
　　 
　　设定账号名称与密码，注册完成，进行下一步。
　　 
　　接下来设定网页上所要设定的群组名，不另更改的话即为DOMAIN 名。
　　 
　　最后可同时寄发邀请信，邀请朋友加入群组。
　　 
　　可设定邀请人员，并可设定不同群组，让不同群组人员直接讯息连络。
　　 
　　1.2 IOS APP 安装与设定
　　Slack 可透过手持装置，来接受实时告警通知，首先我们利用苹果的 Apple Store下载APP，并新建一群组及设定群组名。
　　 
　　输入注册电邮并启用通知功能。
　　 
　　登入后，下图为APP主要操控接口。
　　 
　　当手持装置设定完成后，系统会自动关闭邮件通知功能，改由APP发送简讯通知。
　　 
　　2. Slack 设定
　　Slack 提供了 WebHooks，可以实时传送数据，让整个channel 的人都能收到。利用这个特性，设定好事件报警触发的条件后，当管理的硬件出现异常时可通过 WebHooks 向特定的 channel 发送消息，所有在那个channel的管理人员都能立即收到报警消息。
　　首先选择 Apps & Integrations，并安装 “Incoming WebHooks”。
　　 
　　选择新增配置。
　　 
　　可分别设定下列数值:
　　l Channel: 监听的频道。
　　l Trigger Word: 触发的关键词，可以逗号分隔。
　　l URL: 接收数据的URL，一行一个。
　　l Token: Slack产生的，可以做为核对身分的依据。
　　 
　　下拉选单，并选择要传送讯息的 channel，然后新增 “Incoming WebHooks integration”。
　　 
　　记下 Webhook URL，储存后，并复制到ICINGA server上要用的 。
　　 
　　3. ICINGA 设定
　　3.1. 首先需要建立二个 Slack Notification Shell s，可直接由 Github 上下载 slack_host和 slack_service。链接网址为: https://github.com/linhc130/icinga-plugins-slack-notification
　　 
　　编辑 slack_service ，并加上所要连接之Slack 服务的设定参数。
　　 
　　 
　　 
　　编辑 slack_host.sh，同样的在最后端加入 Slack 的 WebHooks 连接信息。
　　 
　　3.2. 告警信息Shell s 发送测试
　　执行 slack_service.sh ，若正常，即会出现一个不带任何信息的告警信息。
　　 
　　ICINGA透过Slack所发出的空白信息。
　　 
　　3.3. 在 ICINGA设定 Contacts 及 Notification Commands 连接Slack 服务
　　首先在 contacts.cfg 加入下面设定值。
　　 
　　并在 commands.cfg 加入下面参数，让系统接收到报警时，去执行 slack_service.sh 和 slack_host.sh。
　　 
　　4. 告警信息传送测试
　　变更任一 ICINGA service 报警，如本文例子降低Cisco 温度警报触发度数，使 ICINGA 触发 notification。编辑 switch.cfg 配置文件，在此我们将温度警报设定从 45度降低至 35度 ，重新启动 ICINGA，并查询是否正确收到告警信息。
　　 
　　确认可在 Slack 上收到温度告警信息后即可改回,并重启 ICINGA。
　　 
　　当事件触发后，查看手机所接收到之信息，开启APP后即可查看告警信息内容。
　　 
　　5. 总结
　　维持主机服务的运行，是每个系统管理人员最基本的职责。但受限于人力的考虑，管理人员不可能 24 小时随时监控系统服务的运行。当遇到系统服务发生异常时，能实时通知管理者的监控系统，是每个管理人员所迫切需要的。我们利用 ICINGA 监控软件搭配 Slack 的通讯平台服务，不仅帮助管理人员实时监控系统服务的状态，也能在系统服务发生异常时，立刻以短信通知管理者。让管理人员可以快速处理，减少意外事件的冲击。

