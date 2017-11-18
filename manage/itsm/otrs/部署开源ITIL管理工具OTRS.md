

部署开源ITIL管理工具OTRS - Zeev Li的日志 - 网易博客 
http://zeevli.blog.163.com/blog/static/119591610201371424832747/
部署开源ITIL管理工具OTRS-IT运维网 365Master.com 
http://www.365master.com/event/zw2012/20120813/67556.shtml

http://www.otrs.com/cn/
引自：http://www.365master.com/event/zw2012/20120813/67556.shtml

`OTRS的名字是由Open-source Ticket Request System首字母縮略字而来，是一个开源的缺陷跟踪管理系统软件`。

`OTRS将电话，邮件等各种渠道提交进来的服务请求归类为不同的队列，服务级别，服务人员通过OTRS系统来跟踪和回复客户`，

相对传统的处理流程来而言，OTRS提供了一个部门或团队的协调环境，以更有效率的方式处理，查询和跟踪。

OTRS是Lisog德国开源非盈利性发展协会创始成中之一。在2010 年被评选为infoworld年度十佳开源网络软件[1]

1 简介

ITIL上世纪80年代起源于英国，英国政府商务部（Office of Government Commerce）出版的规范描述了创建相关规范所需考 虑的事项、计划和措施。 ITIL 提供了覆盖“端到端”服务管理 所有方面的全面的“最佳实践”指南，并且覆盖了人、过程、产品和合作伙伴的全部范畴。 目前最新版本是 ITIL v3。图1 是ITIL的核心结构图。

2 OTRS简介

 OTRS的ITSM 第一个符合ITIL的IT服务管理解决方案，是建立在开放源代码的基础上。这是一个兼容的开源ITIL的IT服务管理（ ITSM ）解决方案。OTRS包括以下几个特点：
（1） 能支持平台非常广。操作系统有Linux、Unix还有Windows；数据库有MySQL，PostgreSQL，Oracle和SQL Server。
（2） 安装和配置是相当的简单。我使用过Centos Linux和Windows 7 ，整个安装配置过程只需要10分钟。
（3） 支持多语言，目前能支持的语言有10几种，包括简繁体中文。
（4） 纯Web操作界面，Web界面可以定制；很好的邮件系统集成。有问题单生成接口，
   `能够将第三方网络系统监控的故障告警变成问题单，再自动分配到相关的维护组`。

从它的名字可以看出，他是一个“开放式问题系统”或者说是“帮助台”“Help Desk” “工单跟踪系统”。一个单纯的问题系统本身到没有什么特殊， 不过能做到像OTRS这样像ITIL靠拢，试图做成一个遵从ITIL的开源IT服务管理解决方案的，可真的是不容易了。在看看其它的Help Desk的 开源项目，都是在简单的在实现“问题管理”这个功能而已。OTRS现在最新的版本是otrs-3.1.7，等3.2正式发布后我期待它的CMDB，变更管 理，以及各个流程之间的衔接。3.1.7版本最值得关注的新功能如下：

（1） 用户为中心的图形用户界面，在一个戏剧 性的转变从结果重新设计一个全面的，但一个更强大的静态和动态的应用程序使用的，类似的Ajax，XHTML和优化的最先进的技术状态的CSS。
（2） 优化全 文搜索 – 新的搜索功能，您可以灵活定制的方式来浏览信息库。
（3） 工单缩放视图 – 关于Ajax技术让代理商来显示实时链接的信息结构复杂，同时让代理商目前的工作环境为基础的重新设计。这些公司会受益于增加的方向，提高工 作流程效率。
（4） 全局工单一览 – 知名的OTRS2.4全局工单概述已经得到了优化，以达到增加跨活动。根据不同的使用情况和您的代理人的喜好，他们可以轻松地更改机票概览布局根据自己的特殊需要。期权是小型，中型和大型，每个细节提供了不同程度的信息。
（5） 新客户界面 – 客户网络前端可集成到您的组织机构内部网，并充分考虑重新设计的桌面帮助系统集成。
（6） 存档功能 – OTRS的3.0现在提供一个新的归档功能。有了你分开存档受益于搜索，并增加结果显示花了时间却缩短。

说明：`工单(Ticket)：工单包含了与某个服务请求相关的所有信息。它包括客户的初始服务请求、服务人员与客户之间的沟通、服务人员与服务人员或第三方服务提供商之间的沟通`。

3 OTRS安装配置

OTRS支持两种平台：Lamp 和Wamp 。LAMP这个词的由来最早始于德国杂志“ct Magazine”，Michael Kunze在 1990年最先把这些项目组合在一起创造了LAMP的缩写字。这些组件虽然并不是开开始就设计为一起使用的，但是，这些开源软件都可以很方便的随时获得并 免费获得。这就导致了这些组件经常在一起使用。在过去的几年里，这些组件的兼容性不断完善，在一起的应用情形变得非常普便。为了改善不同组件之间的协作， 已经创建了某些扩展功能。目前，几乎在所有的Linux发布版中都默认包含了“LAMP stack”的产品。这些产品组成了一个强大的Web应用程序平 台。以前微软和一些传统的开源厂商认为，是否使用他们的软件乃是一个非此即彼的决定，即：要么选择Microsoft Windows完全排他的.Net 基础设施；要么就运行LAMP应用程序栈，这包括Linux、MySQL数据库、Apache Web服务器和3种以P字母起头的程序语言：Perl、 Python和PHP。简单地说，前一种选择保证更容易地管理，但价格更贵；后一种选择具有更低的成本和更好的安全性，但代价是更高的复杂性。但随着 LAMP逐渐成熟，LAMP也悄悄地演化出了WAMP。这是一种中间路线：称之为`WAMP（Windows、Apache、MySQL和 Perl/Python/PHP）`。现在已经有越来越多的IT用户认为，这种方式可以提供两个阵营中最好的东西。

Windows 7下面安装比较简单下载后运行exe文件，只要不占用Apache（80）、Mysql（3306）端口，一般不会有问题的。所以不再赘 述。软件安装成功能后，自动打开浏览器http://localhost/otrs/installer.pl，开始软件初始化设定：

第一步：许可证，要接受许可证。

第二步：数据库设置。

1、启动安装就有中文界面，应该是自动判断时区或者通过浏览器设置判定语言。

2、应该是使用自带的Mysql。使用帐号：root，密码为空。测试数据库。

3、建立数据库用户otrs/hot账号，数据库名称为otrs,“创建”动作已选中。点击：下一步如图2 。



图2 建立数据库用户

4、创建数据库全部成功。

第三步：一般设定及邮件设置：

1、数据库设置的3/5，定义全称域名、管理员邮箱、日志模式（文件/Syslog），Web前端默认语言、是否检查MX记录等。

2、设定收发邮件设置：

对于我来说，这里必须改变缺省值，输入smtp认证信息：接下来，是接收邮件设置，有IMAP/IMAPTLS/POP3三个选项，我选择POP3。

输入接收邮件必要的设置后，可以点击“检查邮件设置”检查邮箱设置是否正常。如图3 。



图3设定收发邮件设置

3、这一步，设置注册到OTRS，要求填写姓、名、组织、邮件地址，这些是必填项，职位、国家、电话，可以选填。这里我只选了国家。

这一步也可以跳过。如果把上面信息填写完成了，就可以点击“Complete registration and continue”.

4、这时候，就提示设置完成了。



图4 设置完成

上面的5个步骤已经全部完成。开始页面: http://localhost/otrs/index.pl

用户:root@localhost

密码:root

下面开始使用系统。点击刚才设定步骤地最后一页的开始页面的网址，期盼的登录界面出现了!系统登录后的首页终于出来了。其中一行红字显得特别着眼，难道就是这么难看的界面吗？错！知道那行红字写了什么吗？

“Don't use the Superuser account to work with OTRS! Create new Agents and work with these accounts instead. ”

也就是说，root@localhost/root是Superuser了？！是的，从右上角的提示可以证实：“您已登录为 Admin OTRS”如图5 。

图5 系统管理界面

4 安装ITSM

OTRS提供了一个非常灵活的框架，ITSM可做为插件安装在OTRS系统之上，这里暂时先不对ITSM做过多介绍。下面主要阐述如何安装ITSM到OTRS上。

1. 下载ITSM相关OPM

登陆otrs官方ftp，进入/pub/otrs/itsm文件夹。：

接下来需要根据自己的otrs版本来选择相对应的itsm文件，这里我们进入packages31文件夹。查找GeneralCatalog-3.1.4.opm、ITSMCore-3.1.4.opm 这两个文件并下载至本地。

2. 安装ITSM 相关OPM

以最高权限账户登陆OTRS系统后，点击菜单“ADMIN”进入管理员页面，在“System Adminstration”模块区域选择“Package Manager”按钮，进入系统配置页面。如图6：


我们可以通过系统配置页面来管理系统中所有的组件包信息。

在安装ITSM之前，我们需要先修改一下My SQL数据库的配置信息。查找到My SQL的安装目录，打开my.ini 文件，在该文件最后一行加入max_allowed_packet = 20M。

接下来，点击otrs系统管理页面左上角“浏览…”按钮来选择我们刚才下载的itsm相关opm包。先选择GeneralCatalog- 3.1.4.opm进行安装。接下来继续安装ITSMCore-3.1.4.opm 包，同样也是先选择这个包，然后点击 “Install Package”按钮进行安装。安装过程中，只需要根据系统提示一步一步完成安装即可。如图7 。

图7 ITSM 安装完成示意图

安装完成后，在页面Local Repository 列表框中即可看到已经安装成功的组建。到这里，ITSM的安装并没有完整结束，接下来，只需要我们通过在线安装的方式来继续完成ITSM的安装即可。

点击Package Manager页面，点击页面左边部分的下来列表框，你会发现多了一个与ITSM有关的选项，然后我们就选择该选项后，并点击Update repository information按钮。如图8：

图8 ITSM 3.0 在线更新地址选择示意图

otrs系统会根据你选择的下拉列表项，从指定的地址查找ITSM运行所需要的其他包信息并显示在Online Repository列表中。现在我们只需要根据相关的安装顺序点击列表ACTION列中的“Install”连接按钮即可根据系统提示一步一步实现安装。

ITSM 安装顺序如下建议安装顺序如下：

1. GeneralCatalog
2. ITSMCore
3. ITSMIncidentProblemManagement
4. ITSMConfigurationManagement
5. ITSMChangeManagement
6. ITSMServiceLevelManagement
7. ImportExport

ITSM页面展示，如图9 ：

图9  整个ITSM安装完成示意图

通过上图你会发现，在Local Repository 列表中多了很多与ITSM相关的包。同时，在页面顶部的菜单栏中，也出现了新的菜单项。这已经说明了你的ITSM安装成功。到这里，有关OTRS在Windows下的安装与部署已经介绍完毕。