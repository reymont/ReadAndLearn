Apache Camel：基于企业集成模式（EIP）的开源集成框架 - 资源 - 伯乐在线 http://hao.jobbole.com/apache-camel/

Apache Camel 是一个功能强大的开源集成框架，基于企业集成模式（EIP）提供了强大的Bean集成功能。

介绍

通过Camel可以用企业集成模式创建路由和仲裁规则，可以使用基于Java的领域特定语言（或者流式API）实现，也可以通过Spring或基于Xml配置文件的Blueprint实现，还可以用Scala DSL实现。这意味着，在IDE中无论是Java、Scala还是XML编辑器编写路由规则，都可以得到更好的智能补全体验。

Apache Camel使用了URI，因此可以对任何传输类型或消息模型都可以方便地接入，支持HTTP、ActiveMQ、JMS、JBI、SCA、MINA或CXF，使用时支持各种数据格式选项。Apache Camel开发库不大，尽可能地减少了依赖，可以更好地嵌入到各种Java应用。Apache Camel对不同的传输类型使用了相同的API，因此只要进行一次就API学习就可以很好地使用所有自带组件。

Apache Camel提供了强大的Bean绑定和无缝的框架集成，比如流行的Spring、Blueprint以及Guice等。

Apache Camel提供了丰富的测试支持，可以很方便地对你的路由进行单元测试。

Apache Camel可以用作路由和仲裁引擎，它提供了下列项目：

Apache ServiceMix：最流行的开源ESB、JBI和OSGi容器。
Apache ActiveMQ：最流行的开源消息代理。
Apache CXF：智能Web Service套件（JAX-WS 和 JAX-RS）。
Apache Karaf：基于OSGi的小型运行时，可以在Karaf上部署应用程序。
Apache MINA：网络框架。
新手指南

开始使用前，可以先尝试下列链接：

新手指南：http://camel.apache.org/getting-started.html
构建：http://camel.apache.org/building.html
贡献：我们非常欢迎各种贡献形式，http://camel.apache.org/contributing.html
可以通过下面这些链接进行问题追踪，查案邮件列表、Wiki或者通过IRC频道讨论
Wiki: http://camel.apache.org/
IRC: http://camel.apache.org/irc-room.html
Mailing list: http://camel.apache.org/mailing-lists.html
支持：需要帮助时，可以先阅读这里 http://camel.apache.org/support.html
论坛：http://camel.apache.org/discussion-forums.html
开发资源

下载
Javadoc
camel-core javadoc
camel-spring javadoc
文档
用户指南
手册
书籍
教程
示例
使用说明
架构
企业集成模式（EIP）
DSL
组件
数据格式
支持的语言
安全
安全指南
协议

Apache Camel遵循Apache 2.0开源协议发布。

Apache Camel发布的内容包含加密软件。发布这些模块时请注意，你所在的国家可能对加密程序发布有法律限制。请参见http://www.wassenaar.org/了解相关的法律限制。

下面这些模块包含了加密软件：

camel-ahc 配置https
camel-crypto 配置安全通信
camel-cxf 配置安全通信
camel-ftp 配置安全通信
camel-http 配置https
camel-http4 配置https
camel-infinispan 配置安全通信
camel-jasypt 配置安全通信
camel-jetty 配置https
camel-mail 配置安全通信
camel-nagios 配置安全通信
camel-netty-http 配置https
camel-netty4-http 配置https
camel-undertow 配置https
camel-xmlsecurity 配置安全通信
官方网站：http://camel.apache.org/
开源地址：https://github.com/apache/camel/

