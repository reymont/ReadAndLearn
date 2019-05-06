聊聊Service Mesh：linkerd_搜狐科技_搜狐网 http://www.sohu.com/a/155869760_198222
DockOne微信分享（一二九）：聊聊Service Mesh：linkerd - DockOne.io http://dockone.io/article/2485


【编者的话】随着企业逐渐将传统的单体应用向微服务或云原生应用的转变，虽然微服务或者云原生应用能给企业带来更多的好处，但也会带来一些具有挑战的问题，如怎么管理从单体应用转向微服务所带来的服务间通讯的复杂性，怎么实现微服务间安全，高效，可靠的访问，如何满足多语言多环境的透明通讯，服务发现、熔断，动态流量迁移，金丝雀部署，跨数据中心访问等等。本次分享给大家引入一新概念服务网格（Service Mesh）以及介绍业界主要服务网格（Service Mesh）工具linkerd。

【3 天烧脑式容器存储网络训练营 | 深圳站】本次培训以容器存储和网络为主题，包括：Docker Plugin、Docker storage driver、Docker Volume Pulgin、Kubernetes Storage机制、容器网络实现原理和模型、Docker网络实现、网络插件、Calico、Contiv Netplugin、开源企业级镜像仓库Harbor原理及实现等。

在开始介绍linkerd之前，首先不知道大家对Service Mesh这个概念或者名词有多深的了解，反正我在今年之前是没有听说过这么个新词儿（孤陋寡闻了）。Service Mesh其实是在当前微服务或者云原生应用领域的一个buzzword。那么，Service Mesh到底是什么东东？能做什么？能给微服务或者云原生应用带来什么好处？有必要使用或者部署Service Mesh吗？好，那今晚就跟大家聊聊linkerd，顺便回答这些问题。
什么是Service Mesh？

Service Mesh是专用的基础设施层。
轻量级高性能网络代理。
提供安全的、快速的、可靠地服务间通讯。
与实际应用部署一起但对应用是透明的。

Service Mesh能做什么？
提供熔断机制（circuit-breaking）。
提供感知延迟的负载均衡（latency-awareload balancing）。
最终一致的服务发现（service discovery）。
连接重试（retries）及终止（deadlines）。
管理微服务和云原生应用通讯的复杂性，确保可靠地交付应用请求。

Service Mesh是必要的吗？这可能没有一个绝对的答案，但是:
Service Mesh可使得快速转向微服务或者云原生应用。
Service Mesh以一种自然的机制扩展应用负载，解决分布式系统不可避免的部分失败，捕捉高度动态分布式系统的变化。
完全解耦于应用。

业界有哪些Service Mesh产品？
Buoyant的linkerd，基于Twitter的Fingle，长期的实际产线运行经验及验证，支持Kubernetes、DC/OS容器管理平台，也是CNCF官方支持的项目之一。
Lyft的Envoy，7层代理及通信总线，支持7层HTTP路由、TLS、gRPC、服务发现以及健康监测等。
IBM、Google、Lyft支持的Istio，一个开源的微服务连接、管理平台以及给微服务提供安全管理，支持Kubernetes、Mesos等容器管理工具，其底层依赖于Envoy。

什么是linkerd？

为云原生应用提供弹性的Service Mesh。
透明高性能网络代理。
提供服务发现机制、动态路由、错误处理机制及应用运行时可视化。

linkerd的特性：
快速、轻量级、高性能。
每秒以最小的时延及负载处理万级请求。
易于水平扩展。
支持任意开发语言及任意环境。
提供基于感知时延的负载均衡。
通过实时性能数据分发请求。
由于linkerd工作于RPC层，可根据实时观测到的RPC延迟、要处理请求队列大小决定如何分发请求，优于传统启发式负载均衡算法如LRU、TCP活动情况等。
提供多种负载均衡算法如：Power of Two Choices (P2C): Least Loaded、Power of Two Choices: Peak EWMA、Aperture: Least Loaded、Heap: Least Loaded以及Round-Robin。
运行时流量路由。
通过特定HTTP头进行Per-Request级别路由。
动态修改dtab规则实现流量迁移、蓝绿部署、金丝雀部署、跨数据中心failover等。
熔断机制。
Fail Fast — 会话驱动的熔断器。
Failure Accrual — 请求驱动的熔断器。
插入式服务发现。
支持各种服务发现机制如：基于文件（File-based），Zookeeper，Consul及Kubernetes。
支持多种协议：HTTP/1.1、HTTP/2、gRPC、Thrift、Mux。
经过产线测试及验证。

linkerd术语：
##################################################################################
# A basic service mesh for internal linkerd config. This config contains an      #
# outgoing router that proxies requests from local applications to the linkerd   #
# running on the destination host and an incoming router that reverse-proxies    #
# incoming requests to the application instance running on the local host.       #
##################################################################################
admin:
port: 9990

namers:
- kind: io.l5d.consul
host: 127.0.0.1
port: 8500
includeTag: false
setHost: false
- kind: io.l5d.rewrite
prefix: /srv
pattern: "/{service}"
name: “/srv/{service}"

routers:
- protocol: http
identifier:
kind: io.l5d.path
segments: 1
label: routerA_outgoing
dtab: |
/srv  => /#/io.l5d.consul/dc;
/svc    => /#/srv;
httpAccessLog: /alloc/logs/access_routerA.log
servers:
- port: 8080
ip: 0.0.0.0
- protocol: http
label: outgoing
dtab: |
/consul => /#/io.l5d.consul/dc;
/svc    => /$/io.buoyant.http.subdomainOfPfx/svc.consul/consul;
httpAccessLog: /alloc/logs/access_outgoing.log
servers:
- port: 80
ip: 0.0.0.0
interpreter:
kind: default
transformers:
# Instead of sending the request directly to the destination, send it to
# the linkerd (listening on port 81) running on the destination host.
- kind: io.l5d.port
  port: 81
protocol: http
label: incoming
dtab: |
/consul => /#/io.l5d.consul/dc;
/svc    => /$/io.buoyant.http.subdomainOfPfx/svc.consul/consul;
servers:
port: 81
ip: 0.0.0.0
interpreter:
kind: default
transformers:
# Instead of sending the request to a random destination instance, send it
# only to instances running on localhost.
- kind: io.l5d.localhost

telemetry:
- kind: io.l5d.recentRequests
sampleRate: 1.0
- kind: io.l5d.prometheus

usage:
enabled: false

Router：linkerd配置必须定义router模块，可以定义多个router，其它包括服务所使用协议Protocol、Identifier、Transformer、Server、Dtab、Client、Service以及Interpreter。
Identifier：用于给请求赋值逻辑名字（logical name）或者成路径（path），常用的Identifier如：io.l5d.methodAndHost，io.l5d.path，io.l5d.header，io.l5d.header.token和io.l5d.static，例如Identifer：io.l5d.header.token将GET http://example/hello赋值逻辑名字/svc/example。可以开发自定制的Indentifier插件。更多参考https://linkerd.io/config/1.1. ... iers.
Namer: 定义如何将客户端名字和真实地址进行绑定，本质上是如何通过服务发现系统进行服务发现，常用Namer如：io.l5d.fs，io.l5d.consul，io.l5d.k8s，io.l5d.marathon和 io.l5d.rewrite，更多参考https://linkerd.io/config/1.1. ... amers。
Interpreter：决定如何解析namer, 常用如：default, io.l5d.namerd, io.l5d.namerd.http, io.l5d.mesh和io.l5d.fs，更多参考https://linkerd.io/config/1.1. ... reter。
Transformer：根据Interpreter如何转换已解析的地址，Transformer以出现的顺序生效，如：io.l5d.localhost，io.l5d.specificHost，io.l5d.port，io.l5d.k8s.daemonset，io.l5d.k8s.localnode，io.l5d.replace和io.l5d.const，更多参考https://linkerd.io/config/1.1. ... ormer。
Delegation Table（a.k.a. Dtab）：定义如何把服务名字（service name）（逻辑名字）转换为客户端名字（client name）， 客户端名字对应用于服务发现条目，服务发现工具根据这个条目如何发现服务，其必须以/$或者/#打头，如/#/io.l5d.consul/dc/product。

linkerd如何处理应用请求？

在细聊linkerd如何处理应用请求之前，我们来看看linkerd官方给出的数据处理流程图。
26a878aa-b40d-400d-b225-4df9b0e6ac3f.png

从图中我们可以把整个流程分解为4个主要步骤:
Identification: 把实际应用请求如http://foo.com实际为GET foo.com转换为逻辑名字（logical name）或服务名字（service name），具体转换规则由Identifier决定，linkerd提供多种Identifier并根据实际需求选择使用，如图中Identifier为io.l5d.header.token将GET foo.com转换为/svc/foo.com。
Binding：在Identification完成后，Dtab开始登场，将产生的服务名字跟客户端名字绑定起来，如何绑定取决于Dtab规则如何设置，如图中所示Dtab，则将/svc/foo.com绑定为/#/io.l5d.fs/foo.com。
Resolution：即使Binding完成后，此时linkerd仍然未能将请求转发给后端服务，实际上还不知道客户端名字/#/io.l5d.fs/foo.com具体代表什么，而Resolution则将客户端名字转换为真实服务地址，IP地址以及端口。转换逻辑由指定的Namer来确定，不同的Namer转换逻辑不一样，若Namer为io.l5d.consul则查找Consul Catalog API获取IP地址和端口信息，而图中Namer为io.l5d.fs，File-based的Namer，linkerd将读取名为foo.com的本地文件，文件具体位置由配置所决定，该文件会包含图中的2条记录1.1.1.1:8080和1.1.1.2:8080，然后返回上述2条记录。
Loadbalancing：一旦完成Resolution，找到真实的服务地址，然后linkerd会根据前面所述配置的负载均衡算法选取一服务地址提供服务。

至此，linkerd已完成如何处理应用请求，下面是一个演习如何从服务名字到真实地址转换的例子。
18025905-7baf-4b41-aae5-a605fbda7d7b.png

简单Demo

以host模式部署linkerd。
创建服务customer和product，customer会跟product进行通讯并返回一些信息，两者都以容器的方式运行。
注册服务customer和product到Consul。
通过linkerd访问服务customer，curl -s -H “Host: customer.svc.consul” 10.xx.xx.199/product会输出如下信息：
0e5c488f-31c9-4014-be64-53ada1abdd4b.png

Q&A

Q：具体的测试性能有么，对比LVS、Nginx？
A：linkerd虽然是网络代理，但跟LVS、Nginx还是有不同的，所解决的问题也不同，比如linkerd常用的部署方式以sidecar模式部署。 对于性能数据，单个linkerd是可以可以处理20K/sec请求，p99延迟在10ms以内，但是超过20K，在我的测试环境，提高不大。而跟Nginx和LVS的对比，还没做过。
Q：能否说说 “熔断机制（circuit-breaking） ”怎么理解？
A：linkerd支持2种方式进行熔断，一种是基于会话或者链接，另一种是基于请求的熔断。对于会话层的熔断，linkerd在转发请求到后端应用实例时，如果发现其中一个链接出现问题，linkerd会将它从维护的一个池子里移除，不会有真实请求发送到该实例，而在后台，linkerd会尝试连接，一旦连接成功，linkerd再次将它加入池子继续提供服务。
而对基于请求的熔断，linkerd会根据linkerd的配置进行处理，比如配置为io.l5d.consecutiveFailures， linkerd观察到指定数量的连续错误，则熔断，其他的方式可以查看https://linkerd.io/config/1.1. ... crual。
Q：linkerd如何实现水平扩展的？集群对linkerd计算节点数量有限制吗？
A：linkerd本身是无状态的，所以水平扩展非常容易，集群对linkerd的数量取决于你是怎么部署linkerd的，https://linkerd.io/in-depth/deployment/这个地方列出各种部署方式优势及缺点。
Q：看最后的表格好像能实现展示服务调用链，展示上下游关系？能不能借此发现具体服务压力瓶颈在哪一环，是否有性能监控？
A：linkerd提供详细的metric, 这些metric会告诉你性能出现在哪个地方，还有linkerd原生跟zipkin集成，所以你能trace到服务的访问流，会展示每一环节的性能情况。
Q：可否对比一下Istio？
A：对应Istio的底层Envoy和linkerd本质上实现了差不多类似的功能，linkerd支持Kubernetes、DC/OS，并且跟多种服务发现工具集成，而Istio，就我了解，目前支持Kubernetes，具体Istio的使用，没有使用过，不太清楚。
Q：如果linkd是无状态，那怎么维护内部的熔断池？
A：这里的无状态是指linkerd工作时各个实例之间不需要信息的同步，即使一个实例出现问题，对个整个环境的正常工作无关痛痒，只需重新启动即可，所有服务发现的信息都是存储在外部，比如Consul、ZK等，本地只会有缓存，没有持久化的数据，而熔断池的信息就是来自于服务发现系统。
以上内容根据2017年07月04日晚微信群分享内容整理。分享人杨章显，思科高级系统工程师。主要关注云计算，容器，微服务等领域，目前在思科负责内部PaaS平台的构建相关工作。 DockOne每周都会组织定向的技术分享，欢迎感兴趣的同学加微信：liyingjiesa，进群参与，您有想听的话题或者想分享的话题都可以给我们留言。
