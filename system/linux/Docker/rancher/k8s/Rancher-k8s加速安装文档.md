Rancher-k8s加速安装文档 | Rancher 
https://www.cnrancher.com/rancher-k8s-accelerate-installation-document/

by Shirley Huang on 7月 11, 2017

坚持不懈地改善人民生活水平——教你如何加速安装Kubernetes。

Kubernetes是一个强大的容器编排工具，帮助用户在可伸缩性系统上可靠部署和运行容器化应用。Rancher容器管理平台原生支持K8s，使用户可以简单轻松地部署K8s集群。

很多同学正常部署k8s环境后无法进入Dashboard，基础设施应用栈均无报错。但通过查看 基础架构|容器 发现并没有Dashboard相关的容器。

因为k8s在拉起相关服务（如Dashboard、内置DNS等服务）是通过应用商店里面的YML文件来定义的，YML文件中定义了相关的镜像名和版本。而Rancher部署的k8s应用栈属于k8s的基础框架，相关的镜像通过dockerhub/rancher 仓库拉取。

默认Rancher-catalog k8s YML中服务镜像都是从谷歌仓库拉取，在没有科学上网的情况下，国内环境几乎无法成功拉取镜像。

为了解决这一问题，优化中国区用户的使用体验，我们修改了http://git.oschina.net/rancher/rancher-catalog仓库中的YML文件，将相关的镜像也同步到国内仓库，通过替换默认商店地址来实现加速部署。

环境准备
整个演示环境由以下4台本地虚拟机组成，相关信息说明如下：

表格

操作说明
具体演示操作说明如下：

第一步
1、直接运行Rancher_server：

Sudo docker run -d --restart always –name rancher_server -p 8080:8080 rancher/server:stable && sudo docker logs -f rancher-server
容器初始化完成后，通过主机IP:8080访问WEB。

2、添加变量启动Rancher_server：

Sudo docker run -d --name rancher-server -p 8080:8080 --restart=unless-stopped -e DEFAULT_CATTLE_CATALOG_URL='{"catalogs":{"library":{"url":"http://git.oschina.net/rancher/rancher-catalog.git","branch":"k8s-cn"}}}' \

rancher/server:stable && sudo docker logs -f rancher-server
变量的作用后面介绍。

第二步，Rancher基本配置：
因为Rancher修改过的设置参数无法同步到已创建的环境，所以在创建环境前要把相关设置配置好。比如，如果你想让Rancher默认去拉取私有仓库的镜像，需要配置registry.default= 参数等。

应用商店（Catalog）地址配置：在系统管理\系统设置中，找到应用商店。禁用Rancher 官方认证仓库并按照下图配置。

名称：library （全小写）
地址： https://git.oschina.net/rancher/rancher-catalog.git
分支： k8s-cn

PS：回到最开始的启动命令，如果以第二种方式启动，这个地方就会被默认配置好。所以，根据自己的情况选择哪一种配置方式， 最后点击保存。

第三步，Kubernetes环境配置查看对比：
重启并进入WEB后，选择环境管理。如图：

在环境模板中，找到Kubernetes 模板，点击右边的编辑图标，接着点击编辑配置。

以下是Rancher-k8s的默认配置对比，图一为默认商店的参数，图二为自定义商店的参数。

这里只是查看参数不做相关修改。点击cancel返回模板编辑页面。 在这里，根据需要可以定制组件，比如可以把默认的ipsec网络改为vxlan网络等，这里不再叙述。 最后点保存或者cancle返回环境管理界面。

第四步，添加环境：
在环境管理界面中，点击页面上方的添加环境按钮：

填写环境名称，选择环境模板（Kubernetes），点击创建。创建后：


PS：default环境由于没有添加host，会显示Unhealthy。

切换模板


等待添加主机


第五步，添加主机：

如上图，进入添加主机界面

指定用于注册这台主机的公网IP。如果留空，Rancher会自动检测IP注册。通常在主机有唯一公网IP 的情况下这是可以的。如果主机位于防火墙/NAT设备之后，或者主机同时也是运行rancher/server容器的主机时，则必须设置此IP。

以上这段话会在添加主机页面显示，这段话的意思就是：如果准备添加的节点有运行Rancher-server容器，那么在添加节点的时候就要输入节点可被直接访问的主机IP地址（如果做的Rancher-HA，那么每台运行Rancher-server的节点都要添加主机IP地址）,如果不添加主机IP地址，那么在添加节点后获取到的地址很可能会是Rancher-server容器内部的私网地址，导致无法使各节点通信。所以需要注意一下！

本示例三个节点都没有运行rancher_server，所以直接复制生成的代码，在三个节点执行。

11

节点添加成功，应用栈创建完毕，正在启动服务：

12

镜像拉取中

13 14

到此为止，k8s就部署完成。

15 16

服务容器查看：点击基础架构|主机

17

对比基础设施中kubernetes 应用栈，可以发现有以下容器是不在应用栈中的：

18

这些应用是在k8s框架运行起来之后，再通过YML配置文件拉起的k8s服务，比如Dashboard服务

19

那些点击 kubernetes UI 提示服务不可达的。 可以先看看有没有此服务容器。

接下来在k8s中简单部署一个应用。

第六步，k8s应用部署：
进入k8s的Dashboard后，默认显示的是default 命名空间。

可以通过下拉箭头切换到kube-system命名空间，这里显示了CPU、内存使用率，以及一些系统组件的运行状况。

20

应用部署：

页面右上角点击create 按钮，进入部署配置界面，并简单做一写设置：

21

注：在service中，如果选择Internal， 将需要ingress功能，ingress类似于LB的功能，这个后续讲解。这里我们选择External 。

最后点击deploy .点击deploy后将会跳转到部署状态界面，如图：

22

部署完成后显示状态：

23

页面右侧点击service

24

可以看到部署的服务以及访问信息。

25 26

返回Rancher，进入基础设施

27

可以看到自动增加了一个kubernetes-loadbalancers 应用栈。 这个应用栈的信息是通过k8s传递到Rancher，所以在部署应用后，在Rancher中很容易找到服务访问点。