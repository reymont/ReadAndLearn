docker镜像安装java-openjdk以及openjdk-debuginfo - CSDN博客 https://blog.csdn.net/learner198461/article/details/68925343


```Dockerfile
FROM centos:7

RUN yum install -y java-1.8.0-openjdk-devel && \
    yum install -y java-1.8.0-openjdk-debuginfo --enablerepo=*debug*

RUN useradd jdk-user

USER jdk-user

WORKDIR /home/jdk-user

CMD bash
```