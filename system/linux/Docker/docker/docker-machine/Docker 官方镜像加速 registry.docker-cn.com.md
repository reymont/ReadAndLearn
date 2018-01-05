

Docker 官方镜像加速 registry.docker-cn.com - CSDN博客 
http://blog.csdn.net/CSDN_duomaomao/article/details/72957392


Docker 官方镜像加速
通过 Docker 官方镜像加速，中国区用户能够快速访问最流行的 Docker 镜像。该镜像托管于中国大陆，本地用户现在将会享受到更快的下载速度和更强的稳定性，从而能够更敏捷地开发和交付 Docker 化应用。

Docker 中国官方镜像加速可通过 registry.docker-cn.com 访问。该镜像库只包含流行的公有镜像。私有镜像仍需要从美国镜像库中拉取。

您可以使用以下命令直接从该镜像加速地址进行拉取：

$ docker pull registry.docker-cn.com/myname/myrepo:mytag
例如:

$ docker pull registry.docker-cn.com/library/ubuntu:16.04
注: 除非您修改了 Docker 守护进程的 `--registry-mirror` 参数 (见下文), 否则您将需要完整地指定官方镜像的名称。例如，library/ubuntu、library/redis、library/nginx。
使用 --registry-mirror 配置 Docker 守护进程

您可以配置 Docker 守护进程默认使用 Docker 官方镜像加速。这样您可以默认通过官方镜像加速拉取镜像，而无需在每次拉取时指定 registry.docker-cn.com。

您可以在 Docker 守护进程启动时传入 --registry-mirror 参数：

$ docker --registry-mirror=https://registry.docker-cn.com daemon
注: 取决于您的本地主机设置，您可以将 `--registry-mirror` 参数添加至 /etc/default/docker 文件的 DOCKER_OPTS 变量中，或者可以使用适用于 Mac 的 Docker 和适用于 Windows 的 Docker 来进行设置。


http://www.docker-cn.com/registry-mirror  