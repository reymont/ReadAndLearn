基于Spring Cloud的微服务实践 http://mp.weixin.qq.com/s/k6Sht9WFDTzcodIc4y_ttg

首先给大家看一张百度指数上，关于微服务、Spring Boot、Spring Cloud、Dubbo的趋势图：



从图中可见，Dubbo的搜索量增势放缓，Spring Boot从16年中下旬开始发力，一路高涨。学习了Spring Boot再学习Spring Cloud几乎顺理成章。

Spring Boot旨在解决Spring越来越臃肿的全家桶方案的配置地狱（讽刺的是，Spring刚出道是扯着轻量化解决方案大旗一路冲杀，现在自己也开始慢慢胖起来了）,提供了很多简单易用的starter。特点是预定大于配置。

Dubbo放缓是源于，阿里巴巴中间断更将近三年（dubbo-2.4.11 2014-10-30, dubbo-2.5.4 2017-09-07），很多依赖框架和技术都较为陈旧，也不接纳社区的PR（当然，最近开始恢复更新，后面会有说到），导致当当另起炉灶，fork了一个： https://github.com/dangdangdotcom/dubbox（现在已断更）。

而且Dubbo仅相当于Spring Cloud的一个子集，可参考文章《微服务架构的基础框架选择：Spring Cloud还是Dubbo？》：http://blog.csdn.net/kobejayandy/article/details/52078275

另外我们可以看看k8s、kubernetes 、docker的搜索趋势：



上面两图意在说明，微服务相关和容器相关越来越流行了，不再是一个特别新的、不成熟的技术。那单体服务和微服务的对比如何呢？
微服务 vs. 单体应用
单体应用好处：
开发简单
容易测试
易于部署
事务回滚容易
无分布式管理，调用开销
重复功能/代码较少

单体应用缺点:
迭代缓慢
维护困难
持续部署困难：微小改动，必须重启，不相干功能无法提供服务
牵一发而动全身：依赖项冲突，变更后，需要大量测试，防止影响其他功能
基础语言、框架升级缓慢
框架语言单一，无法灵活选用

微服务好处：
敏捷性：按功能拆分，快速迭代
自主性：团队技术选型灵活(PHP、python、java、C#、nodejs、golang)，设计自主
可靠性：微服务故障只影响此服务消费者，而单体式应用会导致整个服务不可用
持续集成持续交付
可扩展性：热点功能容易扩展

微服务的缺点：
性能降低：服务间通过网络调用
管理难度增大：增加了项目的复杂性
事务一致性

扩展阅读《Introduction to Microservices》：https://www.nginx.com/blog/introduction-to-microservices/
框架选型
下面分享一下我司在落地微服务时的框架选型方面的一些经验。

我们公司主要使用java，所以决定使用Spring框架中的Spring Cloud作为微服务基础框架，但是原生Spring Cloud学习曲线比较陡峭，需要学习feign、zuul、eureka、hystrix、zipkin、ribbon…需要老司机坐副驾驶，不然容易翻车。

最后考虑团队的技术水平和学习成本，多方面考察，我们最后采用了国外的开源框架JHipster http://www.jhipster.tech/。其实国内用Dubbo的较多，用JHipster的较少。我们不用Dubbo的原因，前面提到过，一个是中间断更，以及阿里说不更就不更的优良传统，还有Dubbo从功能来说，只是Spring Cloud的一个子集。

从JHipster官方资料看，登记在册的使用 jhipster的企业有224家，其中不乏Google、Adobe一类的大厂。可参见 http://www.jhipster.tech/companies-using-jhipster/

此处列举一下JHipster的技术栈（开箱即用）：

客户端技术栈：
angular4,5 or angularv1.x
Bootstrap
HTML5 Boilerplate
兼容IE11+及现代浏览器
支持国际化
支持sass
支持spring websocket
支持yarn、bower管理js库
支持webpack、gulp.js构建，优化，应用
支持Karma、Headless Chrome 和 Protractor 进行前端单元测试测试
支持Thymeleaf 模板引擎，从服务端渲染页面

服务端技术栈：
支持spring boot 简化spring配置
支持maven、gradle，构建、测试、运行程序
支持多配置文件(默认dev,prod)
spring security
spring mvc REST + jackson
spring websocket
spring data jpa + Bean Validation
使用liquibase管理数据库表结构变更版本
支持elasticsearch，进行应用内搜素
支持mongoDB 、Couchbase、Cassandra等NoSQL
支持h2db、pgsql、mysql、meriadb、sqlserver、oracle等关系型sql
支持kafka mq
使用 zuul或者traefik作为http理由
使用eureka或consul进行服务发现
支持ehcache、hazelcast、infinispan等缓存框架
支持基于hazelcast的httpsession集群
数据源使用HikariCP连接池
生成Dockerfile、docker-compose.yml
支持云服务商AWS、Cloud Foundry、Heroku、Kubernetes、Openshift、Docker …
支持统一配置中心

不过真正用了后，就会发现，这个列表不全，JHipster支持的不止列表中描述的这些，大家也可以参考我以前写的《JHipster开发笔记》： https://jh.jiankangsn.com/

JHipster是基于yoman的一个快速开发的脚手架（国内前几年流行的名字叫代码生成器），需要nodejs 环境 ，并且使用yarn搭建环境。当然不会也没事，它非常简单，如果实在想用，可以用《JHipster Online》：https://start.jhipster.tech/。类似Spring的http://start.spring.io/



值得一提的是JHipster也支持通过JHipster rancher-compose命令来生成rancher-compose.yml和docker-compose.yml，具体可参考《[BETA] Deploying to Rancher》：http://www.jhipster.tech/rancher/

对于小团队落地微服务，可以考虑使用JHipster来生成项目，能够极大的提高效率。基本上可以视作JHipster是一套基于Spring Boot的最佳实践（不仅支持微服务，也支持单体式应用）。对于想学习Spring Boot或者Spring Cloud的也建议了解一下JHipster，好过独自摸索。

JHipster依赖的技术框架版本基本都是最新稳定版，版本更新比较及时，基本上一月一个版本，对GitHub上的issues和PR响应比较及时（一般在24小时内）。
10分钟搭建微服务
下面我将分享如何10分钟搭建一套微服务（不含下载nodejs、安装maven等准备环境的时间）。

安装nodejs、yarn的指南可参见我在《JHipster开发笔记》中的一篇【安装】：https://jh.jiankangsn.com/install.html

需要注意的是，如果是windows nodejs，需要安装v7.x，因为注册中心和网关需要用到node-sass@4.5.0，但是github上的node-sass的rebuild只有v7.x(process 51) 版本的，而自己构建太反人类了。如果是linux，可以尝试高版本的，建议装nodejs v7.x，除非你想玩刺激，自己build一个node-sass。

为了加速下载，建议用npm的淘宝镜像：



安装jdk8、maven、maven加速这些就不说了，可自行百度。

下载注册中心

JHipster-registry github地址 ：https://github.com/jhipster/jhipster-registry)



浏览器访问 http://localhost:8761，初始用户名密码均为admin。


注册中心的页面

Spring Config Server，统一配置中心，可以统一管理不同环境的数据库地址、用户名、密码等敏感数据。



JHipster Registry对应SC（Spring Cloud）的eurake+spring config server。

创建网关

创建api网关，参见 
【Creating an application】：http://www.jhipster.tech/creating-an-app/ 
【The JHipster API Gateway】： http://www.jhipster.tech/api-gateway/



访问http://localhost:8080/，默认用户名密码均为admin。


创建服务

创建服务可参考：http://www.jhipster.tech/creating-an-app/



访问http://localhost:8080/#/docs 默认用户名密码均为 admin ，使用swagger管理api文档，开发时，仅需要添加对应的注解，即可自动生成文档，解决了传统通过word、pdf等管理接口时，文档更新不及时等问题。并且可以通过try it直接调用接口，避免了接口调试时使用curl、postman等工具。



至此，已经创建了一个简单微服务（JHipster-registry是注册中心，gateway是网关，foo是具体的功能模块）。

创建实体

JHipster支持通过命令行创建实体，也支持uml或jdl生成实体，为了省事，此处使用官方jdl-studio的默认jdl文件https://start.jhipster.tech/jdl-studio/。







重启foo服务，再次访问http://localhost:8080/#/docs，发现多了很多接口



通过swagger ui，找到region-resource，找到POST /api/regions，创建一个名为test的regison。



点 try it out! ，然后浏览器打开h2 数据库http://localhost:8081/h2-console




查询REGION表，数据已经插入成功。

至此，一个虽然简单、但是可用的微服务已经弄好。
将服务发布到Rancher
JHipster支持发布到Cloud Foundry、Heroku、Kubernetes、Openshift、Rancher、AWS、Boxfuse。

我们建议使用Rancher，因为Cloud Foundry 、Heroku、AWS、Boxfuse都是云环境，而k8s和openshift origin太复杂了，而Rancher则很容易上手，功能完备，也是完全开源，其联合创始人还是CNCF的理事会成员。

服务发布可以参见文档：http://www.jhipster.tech/rancher/




RANCHER-COMPOSE.YML



DOCKER-COMPOSE.YML




docker-compose.yml中给的JHipster-registry是本地模式的，可以根据注释部分内容，改成从Git拉。好处是维护方便，坏处是容易造成单点故障。使用Git模式，就可以将registry-config-sidekick 部分去掉。

JHipster使用liquibase进行数据库版本管理，便于数据库版本变更记录管理和迁移。(rancher server也用的liquibase)

把docker-compose.yml和rancher-compose.yml贴到rancher上，就能创建一个应用stack了。

不过，好像漏了点啥？少了CICD。Rancher和docker的compsoe.yml有了，但是，还没构建镜像呢，镜像还没push到registry呢，对吧？
CI/CD
自建GitLab
我司用GitLab管理源码，我在Docker Hub上发布了一个汉化的GitLab：https://hub.docker.com/r/gitlab/gitlab-ce/tags/
如果要用官方镜像，参见https://hub.docker.com/r/gitlab/gitlab-ce/tags/


GitLab CI
我们的CI用的是GitLab-CI，参见【GitLab Continuous Integration (GitLab CI)】： https://docs.gitlab.com/ce/ci/README.html

为啥不用Jenkins？这个萝卜白菜各有所爱，我是出于压缩技术栈的考虑：
GitLab-CI够简单，也够用
它和GitLab配套，不用多学习Jenkins，毕竟多一套，就多一套的学习成本

搭建镜像伺服

老牌sonatype nexus oss可以管理 Bower、Docker、Git LFS、Maven、npm、NuGet、PyPI、Ruby Gems、Yum Proxy，功能丰富：https://www.sonatype.com/download-oss-sonatype

GitLab Container Registry administration，GitLab Registry跟GitLab集成，不需要额外安装服务：https://docs.gitlab.com/ce/administration/container_registry.html#gitlab-container-registry-administration

Harbor应用商店就有，安装方便，号称企业级registry，功能强大：http://vmware.github.io/harbor/rancher

如何选择？还是那句话，看需求。我司有部署maven和npm的需要，所以用了nexus oss，顺便管理docker registry。

Service Mesh——下一代微服务

我司是从16年八九月份开始拆分单体服务，彼时国内Spring Cloud，微服务等相关资料较少，国内流行dubbo（那会已经断更1年多了，虽然现在复更，但是对其前景不太看好）。

从17年开始，圈内讨论Spring Cloud的渐渐多起来了，同时市面上也有了介绍Spring Cloud的书籍，比如周立的《Spring Cloud与Docker微服务架构实战》, 翟永超的《Spring Cloud微服务实战》等。

但是用了Spring Cloud后，感觉Spring Cloud太复杂了（如果用了JHipster情况会好点），并没有实现微服务的初衷：
跟语言，框架无关：局限于java
隐藏底层细节，需要学习zuul路由，eureka注册中心，configserver配置中心，需要熔断，降级，需要实现分布式跟踪…

在这种情况下，16年，国外buoyant公司提出Service Mesh概念，基于scala创建了linkerd项目。Service Mesh 的设想就是，让开发人员专注于业务，不再分心于基础设施。

目前主流框架：
istio：背靠google，ibm，后台硬，前景广阔
conduit：跟linkerd是一个公司的，使用Rust语言开发，proxy消耗不到10M内存，p99控制在毫秒内
linkerd：商用企业较多，国内我知道的有豆瓣
envoy：国内腾讯在用

其中istio和conduit都不太成熟，而linkerd和envoy都有商用案例，较为成熟。长远来看，我更看好istio和conduit。

对Dubbo的老用户来说也有个好消息，据说 Dubbo3 将兼容2，并且支持Service Mesh，支持反应式编程。
结语
建议大家根据公司、团队实际情况理性选择框架，目前Service Mesh还处于垦荒阶段，而Spring Cloud或者Dubbo还没到彻底过时的程度，建议持续关注，不建议立刻上马。

如果已经落地了相关的微服务技术，不要盲目跟风，在可接受学习成本和开发成本情况下，可以考虑研究一下Service Mesh。

如果使用的是Spring框架的话，建议抛开Spring Cloud，直接Spring Boot + Service Mesh，更清爽一些。

扩展阅读资料：

1. 【官方文档|ServiceMesh服务网格Istio面板组件&设计目标】 http://blog.shurenyun.com/untitled-102/
   
2. 【演讲实录 | Service Mesh 时代的选边与站队（附PPT下载）】 http://www.servicemesh.cn/?/article/25
   
3. 【Service Mesh：下一代微服务】 https://servicemesh.gitbooks.io/awesome-servicemesh/mesh/2017/service-mesh-next-generation-of-microservice/
Q&A
Q：你们是选择使用consul还是JHipster-register？
A：我们用的是JHipster-registry，核心是eureka，但是有问题，服务状态广播需要心跳时间，在升级服务的时候，容易丢请求，建议用consul或者类似kong这种的，或者用service mesh，比如istio，定义流量策略。

Q：Spring Boot＋k8s进行微服务改造可行不？先来简单的。
A：当然可行，如果可以，建议spring boot+service mesh(e.g. istio)+k8s，皇家拍档，类似咖啡跟咖啡伴侣。

Q：请问贵司是如何定制JHipster的呢？或者有没有什么好的建议。
A：JHipster本身是很open的，通过我贴的技术栈基本满足普通开发需求了，而且JHipster是基于Spring Boot/Spring Cloud，而Spring Boot又基于Spring 。所以理论上没有集成压力，或者说是定制压力。

Q：ORM能随意切换MyBais吗？
A：可以换，没问题。

Q：Spring Cloud里面的组件和k8s功能有重叠的部分，可不可以相互用下？
A：跟上题一样，只要能跟Spring集成，就能跟JHipster集成。如果没用SC或者JHipster，我是建议用Springboot+Service Mesh+k8s。不过只从开发体验来说，用JHipster和Service Mesh，差别不大（JHipster隐藏了很多SC的底层细节）。

Q：除了java以外的如何集成呢？
A：如果非java语言的话，建议Service mesh+k8s，可以参考微博的 Motan。

Q：数据库版本管理，有什么好的方式？
A：数据库版本管理，目前比较流行的有 liquibase（JHipster 默认使用，Rancher也用的liquibase) 与flyway。

Q：JHipster 默认使用JPA ，你安利案例中，你们是使用JPA 还是使用别的？如mybatis等。
A：JHipster默认使用JPA没错，但是在一些简单CURD中，已经够用了，稍微复杂点的，可以用@Query，再复杂点的，可以用【querydsl】 http://www.querydsl.com/ 。逆天难度的，可以国产的mybatis-plus。还是要看困难等级。50%的情况，用JPA就够了，比如 findAll()，不用写任何实现，findByName(String name)。

Q：在安利案例中，有是使用uaa做 Oauth2 服务器吗？
A：【uaa】http://www.jhipster.tech/using-uaa/
。从JHipster官方来看，建议用OIDC。当然也支持jwt。OIDC openID Connect： http://www.jhipster.tech/security/

Q：SC的通讯效率是不是有问题？没有Dubbo快
A：其实，SC用的是RESTful 基于http，Dubbo是rpc。虽然rest慢一些，更占带宽一些，但是，好处是调试方便，方便对接，扪心自问一下，你们的qps，真到了rest成瓶颈的级别了么？

Q：java与jhipster在CICD持续集成，结合K8S如何做的，具体的例子有没有
A：k8s CD：http://www.jhipster.tech/kubernetes/

Q:是不是k8s安装了linkerd组件就有service mesh了？
A：建议 k8s + istio conduit 
linkerd基于scala，性能有点差，当然目前也是商用最多的方案。同时 service mesh，也是 linkerd提出的概念，service mesh类似微服务，只是一个概念，具体实现，目前主流的有istio、conduit、linkerd、envoy。

Q：scala性能不算差吧？跟java是同样的。
A：对啊，基于jvm，而conduit 使用Rust语言（可以理解成c++）开发，proxy消耗不到10M内存，p99控制在毫秒内,而 linkerd一般300-500M，不是一个量级。


扫描下方二维码，可加入技术交流群，参与下一次微信群技术分享。