

K8s Minikube on Windows - Winse Blog http://www.winseliu.com/blog/2017/02/08/k8s-minikube-on-windows/

在windows配置minikube需要先安装docker，或者更直接点的说就是需要docker一样的依赖环境（都是通过iso装载到虚拟机，我们这里不考虑iso内部的软件配置）。先安装docker会把这些依赖都配置好。

系统当前的版本不支持直接安装Docker（This version of Docker requires Windows 10 Pro, Enterprise or Education edition with a mininum build number of 10586, Please use Docker Toolbox），

https://docs.docker.com/toolbox/toolbox_install_windows/
Tutorial : Getting Started with Kubernetes on your Windows Laptop with Minikube
Setting up Kubernetes on Windows10 Laptop with Minikube use Hyper-V
如果直接全部安装toolbox的VirtualBox、git的应该一切顺利的。由于已有cygwin，想着复用下结果惹了一身骚。

按照自己的安装过程，先介绍下配合cygwin安装docker，然后再介绍全部按官网的工具安装k8s。

仅尝试Docker，不安装k8s

但是不想安装git直接使用cygwin来代替。刚刚开始的时刻出现了一些理解上的偏差，后来查询start.sh脚本后大概了解到快捷方式、脚本内容后问题就迎刃而解。

先安装docker toolbox：先禁用windows的Hyper-V；安装时去掉git组件。

安装完成后，启动cygwin的命令行（不要用Docker的快捷图标启动）。然后进行如下配置：

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
71
winse@Lenovo-PC ~
$ cd "C:\Program Files\Docker Toolbox"

做一个c盘的映射
winse@Lenovo-PC /cygdrive/c/Program Files/Docker Toolbox
$ ll /
...
lrwxrwxrwx   1 winse None               11 Apr  5  2016 c -> /cygdrive/c
...

根据cygwin的路径配置VirtualBox的路径
winse@Lenovo-PC /cygdrive/c/Program Files/Docker Toolbox
$ export VBOX_MSI_INSTALL_PATH="/cygdrive/c/Program Files/Oracle/VirtualBox/"

首先下载boot2docker.iso到 C:\Users\winse\.docker\machine\cache\boot2docker.iso
https://github.com/boot2docker/boot2docker/releases/download/v1.13.0/boot2docker.iso...

创建一个空的clear脚本（cygwin没有包括clear脚本）
winse@Lenovo-PC /cygdrive/c/Program Files/Docker Toolbox
$ touch ~/bin/clear && chmod +x ~/bin/clear

# 启动
winse@Lenovo-PC /cygdrive/c/Program Files/Docker Toolbox
$ ./start.sh


                        ##         .
                  ## ## ##        ==
               ## ## ## ## ##    ===
           /"""""""""""""""""\___/ ===
      ~~~ {~~ ~~~~ ~~~ ~~~~ ~~~ ~ /  ===- ~~~
           \______ o           __/
             \    \         __/
              \____\_______/

docker is configured to use the default machine with IP 192.168.99.100
For help getting started, check out the docs at https://docs.docker.com

Start interactive shell

winse@Lenovo-PC ~
$ docker run hello-world
time="2017-02-08T22:48:33+08:00" level=warning msg="Unable to use system certificate pool: crypto/x509: system root pool is not available on Windows"
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
78445dd45222: Pulling fs layer
78445dd45222: Verifying Checksum
78445dd45222: Download complete
78445dd45222: Pull complete
Digest: sha256:c5515758d4c5e1e838e9cd307f6c6a0d620b5e07e6f927b07d05f6d12a1ac8d7
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://cloud.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/engine/userguide/
使用默认安装，并安装k8s

由于cygwin的路径与windows的不兼容，而git bash则本身依托于windows的命令行的，兼容性方面更优。

重新安装Docker ToolBox，安装时选择git。

下载minikube需要的一些软件：

minikube.exe
minikube文档
kubectl.exe
Tutorial : Getting Started with Kubernetes on your Windows Laptop with Minikube
Hello Minikube On OS X
Running Kubernetes Locally via Minikube
下载minikube和kubectl放到PATH路径下（bin目录已经在PATH中）：

1
2
3
4
5
E:\local\bin>dir
...
2017-02-08  14:05        50,735,616 kubectl.exe
2017-02-08  11:22        84,239,872 minikube-windows-amd64.exe
2017-02-08  11:25    <SYMLINK>      minikube.exe [minikube-windows-amd64.exe] （mklink minikube.exe minikube-windows-amd64.exe）
运行 Docker Quickstart Terminal (这个快捷方式会先启动docker的虚拟机)，或者直接打开 C:\Program Files\Git\bin\bash.exe 执行如下命令：

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
查看帮助
winse@Lenovo-PC MINGW64 ~
$ minikube start --help
Starts a local kubernetes cluster using Virtualbox. This command
assumes you already have Virtualbox installed.
...

设置代理: 老外的教程都很简单就成功，但是我们操作一堆问题，主要就是万恶的防火墙！！！
winse@Lenovo-PC MINGW64 ~
$ export HTTPS_PROXY=http://localhost:8118
$ export HTTP_PROXY=http://localhost:8118
$ export NO_PROXY="192.168.0.0/16"

启动
winse@Lenovo-PC MINGW64 ~
$ minikube start --v=7 --logtostderr

winse@Lenovo-PC MINGW64 ~
$ minikube status
minikubeVM: Running
localkube: Running

winse@Lenovo-PC MINGW64 ~
$ kubectl get nodes
NAME       STATUS    AGE
minikube   Ready     3h
再次启动，添加代理参数后dashboard才正常运行

https://kubernetes.io/docs/tutorials/stateless-application/hello-minikube/
https://rominirani.com/tutorial-getting-started-with-kubernetes-on-your-windows-laptop-with-minikube-3269b54a226
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
71
72
73
74
75
76
77
78
79
80
81
82
83
84
85
86
87
88
89
90
91
winse@Lenovo-PC MINGW64 /c/Program Files/Git/bin
$ minikube start --docker-env HTTP_PROXY=http://192.168.99.1:8118 --docker-env HTTPS_PROXY=http://192.168.99.1:8118
Starting local Kubernetes cluster...
Kubectl is now configured to use the cluster.

winse@Lenovo-PC MINGW64 /c/Program Files/Git/bin
$ minikube status
minikubeVM: Running
localkube: Running

winse@Lenovo-PC MINGW64 /c/Program Files/Git/bin
$ kubectl cluster-info
Kubernetes master is running at https://192.168.99.100:8443
KubeDNS is running at https://192.168.99.100:8443/api/v1/proxy/namespaces/kube-system/services/kube-dns
kubernetes-dashboard is running at https://192.168.99.100:8443/api/v1/proxy/namespaces/kube-system/services/kubernetes-dashboard

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

#Open dashboard
https://github.com/kubernetes/minikube/issues/379
https://github.com/kubernetes/minikube/issues/522
winse@Lenovo-PC MINGW64 /c/Program Files/Git/bin
$ minikube dashboard
Opening kubernetes dashboard in default browser...

运行实例
winse@Lenovo-PC MINGW64 /e/local/home/k8s
$ kubectl get nodes
NAME       STATUS    AGE
minikube   Ready     8h

winse@Lenovo-PC MINGW64 /e/local/home/k8s
$ kubectl run hello-nginx --image=nginx --port=80
deployment "hello-nginx" created

winse@Lenovo-PC MINGW64 /e/local/home/k8s
$ kubectl.exe get pods
NAME                           READY     STATUS              RESTARTS   AGE
hello-nginx-2471083592-cgn29   0/1       ContainerCreating   0          19s

winse@Lenovo-PC MINGW64 /e/local/home/k8s
$ kubectl.exe get pods
NAME                           READY     STATUS             RESTARTS   AGE
hello-nginx-2471083592-cgn29   0/1       ImagePullBackOff   0          3m

winse@Lenovo-PC MINGW64 /e/local/home/k8s
$ kubectl.exe describe pod hello-nginx-2471083592-cgn29

winse@Lenovo-PC MINGW64 /e/local/home/k8s
$ kubectl.exe expose deployment hello-nginx --type=NodePort
service "hello-nginx" exposed

winse@Lenovo-PC MINGW64 /e/local/home/k8s
$ kubectl.exe get services
NAME          CLUSTER-IP   EXTERNAL-IP   PORT(S)        AGE
hello-nginx   10.0.0.145   <nodes>       80:31570/TCP   1m
kubernetes    10.0.0.1     <none>        443/TCP        9h

winse@Lenovo-PC MINGW64 /e/local/home/k8s
$ kubectl.exe describe service hello-nginx
Name:                   hello-nginx
Namespace:              default
Labels:                 run=hello-nginx
Selector:               run=hello-nginx
Type:                   NodePort
IP:                     10.0.0.145
Port:                   <unset> 80/TCP
NodePort:               <unset> 31570/TCP
Endpoints:              172.17.0.4:80
Session Affinity:       None
No events.

winse@Lenovo-PC MINGW64 /e/local/home/k8s
$ minikube service --url=true hello-nginx
http://192.168.99.100:31570

winse@Lenovo-PC MINGW64 /e/local/home/k8s
$ kubectl.exe logs hello-nginx-2471083592-cgn29
172.17.0.1 - - [10/Feb/2017:02:07:53 +0000] "GET / HTTP/1.1" 200 612 "-" "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.111 Safari/537.36" "-"
172.17.0.1 - - [10/Feb/2017:02:07:54 +0000] "GET /favicon.ico HTTP/1.1" 404 571 "http://192.168.99.100:31570/" "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.111 Safari/537.36" "-"
2017/02/10 02:07:54 [error] 6#6: *1 open() "/usr/share/nginx/html/favicon.ico" failed (2: No such file or directory), client: 172.17.0.1, server: localhost, request: "GET /favicon.ico HTTP/1.1", host: "192.168.99.100:31570", referrer: "http://192.168.99.100:31570/"

水平扩展
winse@Lenovo-PC MINGW64 /e/local/home/k8s
$ kubectl.exe scale --replicas=3 deployment/hello-nginx
deployment "hello-nginx" scaled

winse@Lenovo-PC MINGW64 /e/local/home/k8s
$ kubectl.exe get deployment
NAME          DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
hello-nginx   3         3         3            1           21m
暂时还不清楚负载均衡是怎么弄的。这个三个应用pods其实是在一个内网（172.17.0.4/5/6），对外有一个服务（10.0.0.145）。

基本的安装过程先记录这么多。

–END

Posted by Winse Li