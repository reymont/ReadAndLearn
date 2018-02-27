Docker镜像仓库Harbor之Swagger REST API整合配置 - CSDN博客 http://blog.csdn.net/aixiaoyang168/article/details/73607305

目录

Swagger介绍
预览Harbor REST API
Harbor与Swagger 整合配置
FAQ
1、Swagger 介绍

Swagger 是一个规范和完整的框架，用于生成、描述、调用和可视化 RESTFul 风格的 Web 服务。通过 Swagger，我们可以方便的、快速的实现 RESTFul API，同时它也提供UI界面，可以直观的管理和测试各个API接口，它还可以集成到各种开发语言中，大大提高了我们日常工作效率。
2、预览 Harbor REST API 整合配置

我们可以通过 Harbor 提供的 REST API yaml 描述文件，通过在线 Swagger 编辑器，来直观的预览一下 Harbor REST API信息。 
1) 下载或直接复制 Harbor 的 swagger.yaml 信息到官网在线 Swagger 编辑器 左侧区域，右侧即可直观看到信息。 
2）直接在官网在线 Swagger 编辑器，通过Import URL或Import File，右侧即可直观看到信息。

Harbor swagger.yaml 地址
URL1：https://raw.githubusercontent.com/vmware/harbor/master/docs/swagger.yaml
URL2：https://github.com/vmware/harbor/blob/master/docs/swagger.yaml
1
2
3
这里写图片描述

3、Harbor与Swagger整合配置

1）下载 prepare-swagger.sh 和 swagger.yaml 到 Harbor 安装目录下，我本地虚拟机安装目录为：/home/wanyang3/harbor

$ cd /home/wanyang3/harbor

地址1：
$ wget https://raw.githubusercontent.com/vmware/harbor/master/docs/prepare-swagger.sh 
$ wget https://raw.githubusercontent.com/vmware/harbor/master/docs/swagger.yaml

地址2：
$ wget https://github.com/vmware/harbor/blob/master/docs/prepare-swagger.sh
$ wget https://github.com/vmware/harbor/blob/master/docs/swagger.yaml
1
2
3
4
5
6
7
8
9
2）编辑 prepare-swagger.sh，修改 SCHEME 和 SERVER_IP 配置

1、修改SCHEME为Harbor配置文件harbor.cfg中设置的ui_url_protocol=http
SCHEME=http

2、修改SERVER_ID为Harbor服务的IP或域名地址，这里我们使用ip
SERVER_ID=10.236.60.101
1
2
3
4
5
3）给 prepare-swagger.sh 可执行权限

chmod +x prepare-swagger.sh
1
4）执行 prepare-swagger.sh 文件，它会下载依赖的 Swagger 包，并将解压缩目录复制到../src/ui/static/vendors目录，并修改index.html相关配置。同时复制swagger.yaml文件复制到../src/ui/static/resources/目录，并修改yaml相关配置。

 ./prepare-swagger.sh
1
5）编辑 docker-compose.yml 文件，在 ui.volumes 下增加挂载 swagger 的配置

$ vim docker-compose.yml

...
ui:
  ... 
  volumes:
    - ./common/config/ui/app.conf:/etc/ui/app.conf:z
    - ./common/config/ui/private_key.pem:/etc/ui/private_key.pem:z
    - /data/secretkey:/etc/ui/key:z
    - /data/ca_download/:/etc/ui/ca/:z
    ## 下边就是增加的配置 ##
    - ../src/ui/static/vendors/swagger-ui-2.1.4/dist/:/harbor/static/vendors/swagger/:z
    - ../src/ui/static/resources/yaml/swagger.yaml:/harbor/static/resources/yaml/swagger.yaml:z
    ...
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
6）重启 Harbor 容器

$ docker-compose down -v
$ docker-compose up -d 
1
2
7）访问 Harbor Swagger Web 查看 REST API，访问地址为：http://10.236.60.101/static/vendors/swagger/index.html。

这里写图片描述

注意：在使用 Harbor API 时，是需要 session ID 的，当我们未登录 Harbor 时，直接使用API将得不到任何结果，这里如果我们想使用 Swagger UI 点击访问API返回结果，那么需要在浏览器中先登录 Harbor Web UI，登录后新开一个tab，在这个tab访问 Harbor Swagger Web，将会得到正常的响应结果，因为这时session已经共享，会话认证通过。我们以 http://10.236.60.101/api/users/current 获取当前用户信息接口为例：

这里写图片描述

这里写图片描述

4、FQA

上边第三步的第5步，编辑 docker-compose.yml 文件，在 ui.volumes 下增加挂载 swagger 的配置时，

## 下边就是增加的配置 ##
- ../src/ui/static/vendors/swagger-ui-2.1.4/dist/:/harbor/static/vendors/swagger/:z
- ../src/ui/static/resources/yaml/swagger.yaml:/harbor/static/resources/yaml/swagger.yaml:z
1
2
3
注意：…swagger-ui-2.1.4/dist 后边的/以及 …vendors/swagger 后边的/得带上，否则dist目录下的文件不能正常挂载到容器swagger目录下，访问时报错404。

这里我们着重介绍了Harbor之Swagger REST API整合配置相关操作，忽略Harbor安装配置，详细可以参考上一篇文章 Docker镜像仓库Harbor之搭建及配置。

参考资料

harbor swagger configure
swagger docs