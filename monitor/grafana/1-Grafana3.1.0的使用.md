

Grafana3.1.0的使用 - CSDN博客 http://blog.csdn.net/tony_bo/article/details/54095616


 
 
 
3、配置Zabbix数据源

    添加新数据源，单击选择齿轮图标的向下按钮，打开 “Data Sources”

，单击“Add new”。

 
注意红线标注的地方

    Name自定义

    Type选择Zabbix

    Http settings URL填入http://zabbix服务器ip/zabbix/api_jsonrpc.php

    Zabbix details用户名和密码需要在Zabbix web页面中设置，本文中用户名：admin，密码：zabbix。如不想新建的话，可以使用zabbix的初始用户。

    配置过程如下图所示：

 
    设置完成点击Save & Test按钮，弹出下图所示的Success提示对话框：

 
本文档的Zabbix版本为Zabbix-3.0.5，详细配置教程请参考官方文档：

http://docs.grafana-zabbix.org/installation/configuration

常见错误解决请参考：http://docs.grafana.org/installation/troubleshooting/

4、开始使用Grafana-Zabbix

添加新的仪表板

    让我们开始创建一个新的仪表板。添加新的仪表板过程如下所示：

 

 
在新建的仪表板中添加图面板

 

    图面板在Grafana中只是命名图。它提供了一组丰富的图形选项。如下图所示：

 


    单击标题面板可打开一个菜单框。单击edit 选项面板将会打开额外的配置选项。

如下图所示：

 
Graph里面的选项有：

    General（常规选择）、Metrics（指标）、Axes（坐标轴）、Legend（图例）、 Display（显示样式）、Time range（时间范围）

Genera（常规选择）：添加图形标题，图形宽度高度等

    Title：仪表板上的面板标题

    Span：列在面板中的宽度

    Height：面板内容高度(以像素为单位)

 
钻取/详细信息链接（Drilldown / detail link）

    钻取部分允许添加动态面板的链接，可以链接到其他仪表板或URL。

    每个链接都有一个标题,一个类型和参数。链接可以是 dashboard或 absolute链接。如果它是一个仪表板链接, dashboard值必须是一个仪表板的名字。如果这是一个 absolute链接,是URL链接的URL。

    params允许添加额外的URL参数的链接。格式是 name=value与多个参数分开，当链接到另一个仪表板使用模板变量,你可以使用 var-myvar=value填充模板变量的期望值链接。

 
Metrics（指标）

    定义了来源数据的呈现，每个数据源都提供不同的选择。面板的来源数据通过group,host,application,item从zabbix中获得。

 
Axes（坐标轴）

    用于坐标轴和网格的显示方式，包括单位，比例，标签等。

Left Y和 Right Y可以定制使用，因其中的可选参数太多，怕描述不准确。所以请在使用的时候参考官方文档

 
Legend（图例）：图例展示

    图例的参数:

    Total:返回所有度量查询值的总和

    Current:返回度量查询的最后一个值

    Min:返回最小的度量查询值

    Max:返回最大的度量查询值

    Avg:返回所有度量查询的平均值

    Decimals:控制Legend值的多少，以小数显示悬浮工具提示(图)

    Grafana 中Legend值的计算取决于你使用的度量查询方式和什么样类型的聚合或合并点来实现的，所有上述所说的值在同一时间可能都是不正确的。例如，如果你是每秒请求一次,这可能是使用平均值来作为一个整合,然而这个Legend值不会代表请求的总数。这只是Grafana收到的所有数据点的总和。

 

Display（显示样式）

    显示样式的控件属性图如下：

 
图表模式(Draw Modes)

Bar:一个条形图显示值

Lines:显示线图值

 Points:显示点值

选择模式（Mode Options）

Fill:系列的颜色填充,0是没有。

Line Width:线的宽度。

 Staircase:楼梯状显示。

    如果有多个选择项,它们可以作为一个群体显示。

叠加和空值（Stacking & Null value）

Stack：每个系列是叠在另一个之上

Null value：空值

    如果你启用了堆栈可以选择应该显示鼠标悬停功能。

Time range（时间范围）

 

顶级头介绍

 

上图显示了仪表板顶部的标题。

    1.侧菜单切换:切换菜单，让你专注于仪表板中给出的数据。侧菜单提供了访问特性，仪表板，用户，组织和数据源等。

    2.仪表板下拉菜单:下拉菜单显示你当前浏览的仪表板，并允许轻松地切换到另一个新的仪表板。在这里你还可以创建一个新的仪表板，导入现有的仪表板和管理仪表板播放列表。

    3.星仪表板:星(或unstar)当前的仪表板。默认情况下星仪表板将出现在自己建立的仪表板里，为你提供快捷的查看途径。

    4.仪表板分享:通过创建一个链接或创建一个静态快照分享当前仪表板。

    5.保存仪表板:以当前仪表板的名字保存。

    6.设置:管理仪表板的设置和特性，比如模板和注释。

5、创建流量监控图形

 

 
 
 
 


6、仪表盘模板功能

    单纯的手动去添加一个个监控图,只能显示一个主机的所有监控图形，若要查看不同主机的所有监控图形，就要通过变量的方式去实现。我们要设置的变量包括group，host，application和iteam。

模板

    仪表盘模板可以让你创建一个交互式和动态性的仪表板，它是Grafana里面最强大的、最常用的功能之一。创建的仪表盘模板参数，可以在任何一个仪表盘中使用。

创建变量

    点击顶部导航栏上的齿轮图标，选择模板。



   单击新建按钮，你会看到模板变量编辑器。它包含以下部分：



变量（Variable）

命名：变量的名称。

标签：可见标签变量。例如，主机组，而不是HOST_GROUP。

类型：查询类型选择。

    图中有五种变量类型: query,custom,interval，Data source和Contsta。它们都可以用来创建动态变量,不同之处在于获得的数据值不一样。

查询选项（Query Options）

数据源：用于查询变量值的数据源。

刷新：更新此变量的值。

查询：查询字符串。 

正则表达式：如果你需要筛选值或提取价值的一部分，那就使用正则表达式。

选择选项（Selection Options）

多值：启用，如果你想在同一时间选择多个值。

数值组/标签（实验功能）（Value groups/tags (Experimental feature)）

7、查询格式

   zabbix模板变量数据源查询是一个包含了4个部分的以.号隔开的字符串{host group}.{host}.{application}.{item name}。例如， Zabbix servers.Zabbix server.CPU.*。

   例子：

   * 返回所有可用主机组

   *.* 返回主机组里所有可用主机

   Servers.*返回服务器组里的所有主机

   Linux servers.*.* 返回Linux服务器组中的所有应用程序

   Linux servers.*.*.* 返回Linux服务器组中所有主机的监控项。

   你可以使用另一个变量作为查询的一部分。例如，你有一个变量组，它返回的是主机组的列表，并仅希望将其用于在选定的组在查询主机。下面是这种情况的查询条件：

   $group.*

8、变量的使用

    当你创建一个变量,你可以使用它作为一个数据源查询的一部分。Grafana还支持变量在不同的地方被使用,比如面板和行标题、文本面板的内容等。

 
    注意,你需要在变量的名字之前添加$标志。

创建模板

 
 

   添加变量group，host，Application，iteam


    添加完四个变量，如下图所示：



    group匹配的显示结果



   变量添加完成后，就可以设置图形属性了。将之前所有添加的图形用下面的group，host，application，iteam变量来表示。



    这样我们就可以通过切换，来查看不同主机的所有监控内容 



    下图是通过仪表盘功能在一个页面中用多个graph显示多台机器的网卡流量。

 
    下图是在仪表盘中使用模板功能在一个页面中用一个graph显示单台机器或所有机器的单个监控项或所有监控项。



 
 
    这个仪表盘模板是在一个页面中用多个graph显示单台机器的多个监控项

 
grafana3.0.5的使用暂时先写到这里，未完待续。如果你阅读了本博文，但在实际的操作中有遇到问题，欢迎加我qq与我一起交流。