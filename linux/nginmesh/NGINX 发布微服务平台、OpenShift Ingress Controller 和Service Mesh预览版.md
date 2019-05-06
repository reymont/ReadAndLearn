

http://www.infoq.com/cn/news/2017/09/nginx-platform-service-mesh


在美国波特兰举行的 nginx.conf 大会上，Nginx 公司发布了 NGINX 应用平台，这是一套基于开源技术构建的四种产品，旨在为开发部署、管理和观测微服务提供“一站式服务”。另外发布的版本还包括 Kubernetes Ingress Controller 解决方案，用于 Red Hat OpenShift 容器平台上的负载平衡，以及将 NGINX 作为 Istio Service Mesh （服务网格）控制面板的服务代理的实现。

新的 NGINX 应用平台由以下组件组成：

NGINX Plus，流行的开源 NGINX Web 服务器的商业版本。
NGINX Web 应用防火墙（WAF）。
NGINX Unit，可运行 PHP、Python 和 Go 的新型开源应用服务器。
NGINX Contrlller，用于监控和管理 NGINX Plus 的中央控制面板。
NGINX Plus 由 Web 服务器、内容缓存和负载均衡器组成。NGINX Web 应用程序防火墙（WAF）是一款基于开源 ModSecurity 研发的商业软件，为针对七层的攻击提供保护，例如 SQL 注入或跨站脚本攻击，并根据如 IP 地址或者报头之类的规则阻止或放行， NGNX WAF 作为 NGINX Plus 的动态模块运行，部署在网络的边缘，以保护内部的 Web 服务和应用程序免受 DDoS 攻击和骇客入侵。

NGINX Unit 是 Igor Sysoev 设计的新型开源应用服务器，由核心 NGINX 软件开发团队实施。Unit 是“完全动态的”，并允许以蓝绿部署的方式无缝重启新版本的应用程序，而无需重启任何进程。所有的 Unit 配置都通过使用 JSON 配置语法的内置 REST API 进行处理，并没有配置文件。目前 Unit 可运行由最近版本的 PHP、Python 和 Go 编写的代码。在同一台服务器上可以支持多语言的不同版本混合运行。即将推出更多语言的支持，包括 Java 和 Node.JS。

NGINX Controller 是 NGINX Plus 的中央集中式监控和管理平台。Controller 充当控制面板，并允许用户通过使用图形用户界面“在单一位置管理数百个 NGINX Plus 服务器”。该界面可以创建 NGINX Plus 服务器的新实例，并实现负载平衡、 URL 路由和 SSL 终端的中央集中配置。Controller 还具备监控功能，可观察应用程序的健壮性和性能。



图1. NGINX 应用平台（图片来自 NGINX 博客）

新发布的 NGINX Plus（Kubernetes）Ingress Controller 解决方案基于开源的 NGINX kubernetes-ingress 项目，经过测试、认证和支持，为 Red Hat OpenShift 容器平台提供负载平衡。该解决方案增加了对 NGINX Plus 中高级功能的支持，包括高级负载平衡算法、第7层路由、端到端认证、request/rate 限制以及内容缓存和 Web 服务器。

NGINX 还发布了 nginmesh，这是 NGINX 的开源预览版本，作为 Istio Service Mesh 平台中第7层负载平衡和代理的服务代理。它旨在作为挎斗容器（sidecar container）时，能提供与 Istio 集成的关键功能，并以“标准、可靠和安全的方式”促进服务之间的通信能力。此外，NGINX 将通过加入 Istio 网络特别兴趣小组，与 Istio 社区合作。

最近，“Service Mesh”的概念越来越受欢迎，因为它允许开发人员通过基础网格（或通信总线）来管理服务之间的流量，实现基于微服务的应用的松散藕合，实施访问策略和聚合遥测数据。Istio 是由 Google、IBM、Lyft 等领导的开源服务网格项目，目标是为服务代理的数据平面提供控制面板。目前，Istio 与 Kubernetes 紧密集成，但也有支持虚拟机的计划：如 Cloud Foundry 之类的 PaaS ，以及潜在“无服务器” FaaS 产品等平台。

默认情况下，Istio 使用 Matt Klein 和 Lyft 团队创建的 Envoy 服务代理，并在 Lyft 生产环境中已使用多年。NGINX 似乎并非唯一一家实现在微服务网格中提供并拥有服务代理组件的潜在优势公司，因为 Buoyant 也正在修改其基于 JVM 的服务代理 Linkerd （由 Twitter Finagle 栈孵出），用于与 Istio 集成。

NGINX nginmesh Istio 服务代理模块：为 NGINX Web 服务本身采用的是 Golang 编写而不是 C ，与作为挎斗模式运行的开源 NGINX 集成（如图 2 所示），并声称“占用的空间很小，具备先进的负载平衡算法的高性能代理、缓存、SSL 终端、使用 Lua 和 nginScript 的脚本功能、以及具备细粒度访问控制的各种安全功能。”



图2. NGINX nginmesh 架构（图片来自 nginmesh GitHub repo）

有关 nginx.conf 中所有 NGINX 版本和公告的更多详细信息，请参见 NGINX 博客。

查看英文原文：NGINX Releases Microservices Platform, OpenShift Ingress Controller, and Service Mesh Preview

感谢冬雨对本文的审校。

给InfoQ中文站投稿或者参与内容翻译工作，请邮件至editors@cn.infoq.com。也欢迎大家通过新浪微博（@InfoQ，@丁晓昀），微信（微信号：InfoQChina）关注我们。