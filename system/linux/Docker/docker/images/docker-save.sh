

# http://www.jianshu.com/p/8408e06b7273
# http://www.simapple.com/343.html


## 镜像和容器 导出和导入的区别
# 镜像导入和容器导入的区别：
# 1）容器导入 是将当前容器 变成一个新的镜像
# 2）镜像导入 是复制的过程
# save 和 export区别：
# 1）save 保存镜像所有的信息-包含历史
# 2）export 只导出当前的信息

# docker save命令-打包image
sudo docker save busybox > busybox.tar
ls -sh busybox.tar
docker save --output busybox.tar busybox
ls -sh busybox.tar
docker save -o fedora-all.tar fedora
docker save -o fedora-latest.tar fedora:latest
# Docker images导出和导入
## 镜像的保存
docker save 9045 > tomcat8-apr.tar
## 镜像的导入
docker load < tomcat8-apr.tar
docker images
docker tag 9045 tomcat8-apr:3.0
## 容器的导出
docker ps 
docker export b91d9ad83efa > tomcat80824.tar
镜像导出的文件比容器导出文件大哦。
## 容器的导入
docker import tomcat80824.tar
```
