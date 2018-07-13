[Kubernetes] 国内获取 Kubernetes 镜像的方法 - CSDN博客 http://blog.csdn.net/shida_csdn/article/details/78480241

一、  背景介绍

            众所周知，由于国内网络原因，在搭建 Kubernetes 环境时，经常遇到必须的镜像找不到的情况。

            到 DockerHub 捡垃圾毕竟不是个好办法，本文就教大家在 DockerHub 搭建自己的镜像仓库。

            要求：有 GitHub 账号，有 DockerHub 账号，没有请注册。

二、  基本步骤

    2.1  登陆 GitHub，创建代码仓库，比如：googlecontainer

     

    2.2  克隆代码（地址换成你的）

[plain] view plain copy
# git clone https://github.com/SataQiu/googlecontainer.git  
    2.3  编写 Dockerfile (以 dashboard 为例)

[plain] view plain copy
# cd googlecontainer  
# mkdir dashboard  
# cd dashboard  
# vim Dockerfile  
[plain] view plain copy
FROM gcr.io/google_containers/kubernetes-dashboard-amd64:v1.7.1  
MAINTAINER qiushida@buaa.edu.cn  
   2.4  提交代码

[plain] view plain copy
# cd <克隆代码根目录>  
# git add .  
# git commit -m "kubernetes-dashboard-amd64:v1.7.1"  
# git push  
        

    2.5  最后提交完成后的代码结构

        

   2.6  登陆 DockerHub，创建 Automated Build 项目

           如未关联账号，会提示绑定 github 账号，按提示操作即可。

           如已绑定 github，则选择 github 方式的 Automated Build 项目，如图

        

           接着按照提示，选择 github 上我们的项目 googlecontainer 即可，仓库名设置为 dashboard

          

    2.7  配置 Build Settings

           指定 Dockerfile 所在的目录（到目录级即可），设置镜像 tag，先点 Save Changes，再点 Trigger

         

    2.8  在 Build Details 可以查看编译进度

           

   2.9  编译完成后，我们就可以把镜像拉取到本地。

          自己改一下 tag 就是 gcr.io/google_containers/kubernetes-dashboard-amd64:v1.7.1 镜像了。

[plain] view plain copy
# docker pull shidaqiu/dashboard:v1.7.1  
# docker tag shidaqiu/dashboard:v1.7.1 gcr.io/google_containers/kubernetes-dashboard-amd64:v1.7.1  
          