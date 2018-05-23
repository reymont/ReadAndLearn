

配置docker中免密码SSH - Docker知识库 http://lib.csdn.net/article/docker/1020

更换docker国内镜像，使用DaoCloud，特别快
编写Dockerfile文件
FROM ubuntu

MAINTAINER ggzone xxx@live.com
ENV REFRESHED_AT 2015-10-21

RUN apt-get -qqy update && apt-get install -qqy openssh-server
ADD id_rsa.pub /root/.ssh/authorized_keys

RUN chmod 700 /root/.ssh/authorized_keys
RUN apt-get autoclean && apt-get autoremove && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/run/sshd

EXPOSE 22
CMD /usr/sbin/sshd -D
在dockerfile同一目录，添加id_rsa.pub文件，里面添加所有免登录公钥
构建镜像：
docker build -t "ggz/ubuntu-ssh:v1" ./
运行镜像：
docker run -d -p 22:10022 00bfdb6227f8
	
连接容器
ssh localhost -p 10022


改进：可以改成挂载卷的方式添加id_rsa.pub，同时可以替换ubuntu的国内软件源