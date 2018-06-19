

开源微服务管理平台fabric8简介 - jimmysong.io|宋净超的博客|Cloud Native|Big Data
 https://jimmysong.io/posts/fabric8-introduction/

Mon Apr 10, 2017

1800 Words|Read in about 4 Min

Tags: fabric8   platform   devops  

fabric8

前言
无意中发现Fabric8这个对于Java友好的开源微服务管理平台。

其实这在这里发现的Achieving CI/CD with Kubernetes（by Ramit Surana,on February 17, 2017），其实是先在slideshare上看到的。

大家可能以前听过一个叫做fabric的工具，那是一个 Python (2.5-2.7) 库和命令行工具，用来流水线化执行 SSH 以部署应用或系统管理任务。所以大家不要把fabric8跟fabric搞混，虽然它们之间有一些共同点，但两者完全不是同一个东西，fabric8不是fabric的一个版本。Fabric是用python开发的，fabric8是java开发的。

如果你想了解简化Fabric可以看它的中文官方文档。

Fabric8简介
fabric8是一个开源集成开发平台，为基于Kubernetes和Jenkins的微服务提供持续发布。

使用fabric可以很方便的通过Continuous Delivery pipelines创建、编译、部署和测试微服务，然后通过Continuous Improvement和ChatOps运行和管理他们。

Fabric8微服务平台提供：

Developer Console，是一个富web应用，提供一个单页面来创建、编辑、编译、部署和测试微服务。
Continuous Integration and Continous Delivery，使用 Jenkins with a Jenkins Workflow Library更快和更可靠的交付软件。
Management，集中式管理Logging、Metrics, ChatOps、Chaos Monkey，使用Hawtio和Jolokia管理Java Containers。
Integration Integration Platform As A Service with deep visualisation of your Apache Camel integration services, an API Registry to view of all your RESTful and SOAP APIs and Fabric8 MQ provides Messaging As A Service based on Apache ActiveMQ。
Java Tools 帮助Java应用使用Kubernetes:
Maven Plugin for working with Kubernetes ，这真是极好的
Integration and System Testing of Kubernetes resources easily inside JUnit with Arquillian
Java Libraries and support for CDI extensions for working with Kubernetes.
Fabric8微服务平台
Fabric8提供了一个完全集成的开源微服务平台，可在任何的Kubernetes和OpenShift环境中开箱即用。

整个平台是基于微服务而且是模块化的，你可以按照微服务的方式来使用它。

微服务平台提供的服务有：

开发者控制台，这是一个富Web应用程序，它提供了一个单一的页面来创建、编辑、编译、部署和测试微服务。
持续集成和持续交付，帮助团队以更快更可靠的方式交付软件，可以使用以下开源软件：
Jenkins：CI／CD pipeline
Nexus： 组件库
Gogs：git代码库
SonarQube：代码质量维护平台
Jenkins Workflow Library：在不同的项目中复用Jenkins Workflow scripts
Fabric8.yml：为每个项目、存储库、聊天室、工作流脚本和问题跟踪器提供一个配置文件
ChatOps：通过使用hubot来开发和管理，能够让你的团队拥抱DevOps，通过聊天和系统通知的方式来approval of release promotion
Chaos Monkey：通过干掉pods来测试系统健壮性和可靠性
管理
日志 统一集群日志和可视化查看状态
metris 可查看历史metrics和可视化
参考
fabric8：容器集成平台——伯乐在线

Kubernetes部署微服务速成指南——2017-03-09 徐薛彪 容器时代微信公众号

上面那篇文章是翻译的，英文原文地址：Quick Guide to Developing Microservices on Kubernetes and Docker

fabric8官网

fabric8 get started

后记
我在自己笔记本上装了个minikube，试玩感受将在后续发表。

试玩时需要科学上网。

$gofabric8 start
using the executable /usr/local/bin/minikube
minikube already running
using the executable /usr/local/bin/kubectl
Switched to context "minikube".
Deploying fabric8 to your Kubernetes installation at https://192.168.99.100:8443 for domain  in namespace default

Loading fabric8 releases from maven repository:https://repo1.maven.org/maven2/
Deploying package: platform version: 2.4.24

Now about to install package https://repo1.maven.org/maven2/io/fabric8/platform/packages/fabric8-platform/2.4.24/fabric8-platform-2.4.24-kubernetes.yml
Processing resource kind: Namespace in namespace default name user-secrets-source-admin
Found namespace on kind Secret of user-secrets-source-adminProcessing resource kind: Secret in namespace user-secrets-source-admin name default-gogs-git
Processing resource kind: Secret in namespace default name jenkins-docker-cfg
Processing resource kind: Secret in namespace default name jenkins-git-ssh
Processing resource kind: Secret in namespace default name jenkins-hub-api-token
Processing resource kind: Secret in namespace default name jenkins-master-ssh
Processing resource kind: Secret in namespace default name jenkins-maven-settings
Processing resource kind: Secret in namespace default name jenkins-release-gpg
Processing resource kind: Secret in namespace default name jenkins-ssh-config
Processing resource kind: ServiceAccount in namespace default name configmapcontroller
Processing resource kind: ServiceAccount in namespace default name exposecontroller
Processing resource kind: ServiceAccount in namespace default name fabric8
Processing resource kind: ServiceAccount in namespace default name gogs
Processing resource kind: ServiceAccount in namespace default name jenkins
Processing resource kind: Service in namespace default name fabric8
Processing resource kind: Service in namespace default name fabric8-docker-registry
Processing resource kind: Service in namespace default name fabric8-forge
Processing resource kind: Service in namespace default name gogs
...
-------------------------

Default GOGS admin username/password = gogsadmin/RedHat$1

Checking if PersistentVolumeClaims bind to a PersistentVolume ....
Downloading images and waiting to open the fabric8 console...

-------------------------
.....................................................
启动了半天一直是这种状态：

Waiting, endpoint for service is not ready yet...
我一看下载下来的

https://repo1.maven.org/maven2/io/fabric8/platform/packages/fabric8-platform/2.4.24/fabric8-platform-2.4.24-kubernetes.yml
文件，真是蔚为壮观啊，足足有24712行(这里面都是实际配置，没有配置充行数)，使用了如下这些docker镜像，足足有53个docker镜像：

fabric8/alpine-caddy:2.2.311
fabric8/apiman-gateway:2.2.168
fabric8/apiman:2.2.168
fabric8/chaos-monkey:2.2.311
fabric8/configmapcontroller:2.3.5
fabric8/eclipse-orion:2.2.311
fabric8/elasticsearch-k8s:2.3.4
fabric8/elasticsearch-logstash-template:2.2.311
fabric8/elasticsearch-v1:2.2.168
fabric8/exposecontroller:2.3.2
fabric8/fabric8-console:2.2.199
fabric8/fabric8-forge:2.3.88
fabric8/fabric8-kiwiirc:2.2.311
fabric8/fluentd-kubernetes:v1.19
fabric8/gerrit:2.2.311
fabric8/git-collector:2.2.311
fabric8/gogs:v0.9.97
fabric8/grafana:2.6.1
fabric8/hubot-irc:2.2.311
fabric8/hubot-letschat:v1.0.0
fabric8/hubot-notifier:2.2.311
fabric8/hubot-slack:2.2.311
fabric8/jenkins-docker:2.2.311
fabric8/jenkinshift:2.2.199
fabric8/kafka:2.2.153
fabric8/kibana-config:2.2.311
fabric8/kibana4:v4.5.3
fabric8/lets-chat:2.2.311
fabric8/maven-builder:2.2.311
fabric8/message-broker:2.2.168
fabric8/message-gateway:2.2.168
fabric8/nexus:2.2.311
fabric8/taiga-back:2.2.311
fabric8/taiga-front:2.2.311
fabric8/turbine-server:1.0.28
fabric8/zookeeper:2.2.153
fabric8/zookeeper:2.2.168
funktion/funktion-nodejs-runtime:1.0.3
funktion/funktion:1.0.9
gitlab/gitlab-ce
jboss/keycloak:2.2.0.Final
jfrog-docker-registry.bintray.io/artifactory/artifactory-oss
jimmidyson/configmap-reload:v0.1
manageiq/manageiq:latest
mongo
mysql:5.7
nginxdemos/nginx-ingress:0.3.1
openzipkin/zipkin:1.13.0
postgres
prom/blackbox-exporter:master
prom/node-exporter
prom/prometheus:v1.3.1
registry:2
你们感受下吧，我果断放弃了在自己笔记本上安装的念头。