

Docker中使用163 Hub 镜像下载加速(Centos 6)-奔跑的蜗牛-51CTO博客 
http://blog.51cto.com/441274636/1889627

在学习Docker的过程中，下载镜像速度特别慢，这是因为Docker Hub并没有在国内部署服务器或者CDN，再加上国内的网速慢等原因，镜像下载就十分耗时。为了克服跨洋网络延迟，能够快速高效地下载Docker镜像，最为有效的方式之一就是：使用 国内的Docker镜像源。下面就介绍一下使用163  镜像源来加速的办法。

添加镜像源：

vim /etc/sysconfig/docker
添加如下内容：

other_args="--registry-mirror=http://hub-mirror.c.163.com"
OPTIONS='--registry-mirror=
http://hub-mirror.c.163.com'

重启Docker服务：
1
2
3
[root@iZ25syqr8e5Z ~]# /etc/init.d/docker restart
Stopping docker:                                           [  OK  ]
Starting docker:

测试：
[root@iZ25syqr8e5Z ~]# docker search centos
NAME                                   DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
centos                                 The official build of CentOS.                   2979      [OK]       
jdeathe/centos-ssh                     CentOS-6 6.8 x86_64 / CentOS-7 7.3.1611 x8...   54                   [OK]
nimmis/java-centos                     This is docker images of CentOS 7 with dif...   20                   [OK]
consol/centos-xfce-vnc                 Centos container with "headless" VNC sessi...   16                   [OK]
torusware/speedus-centos               Always updated official CentOS docker imag...   8                    [OK]
egyptianbman/docker-centos-nginx-php   A simple and highly configurable docker co...   6                    [OK]
nathonfowlie/centos-jre                Latest CentOS image with the JRE pre-insta...   5                    [OK]
centos/mariadb55-centos7                                                               3                    [OK]
harisekhon/centos-java                 Java on CentOS (OpenJDK, tags jre/jdk7-8)       2                    [OK]
centos/tools                           Docker image that has systems administrati...   2                    [OK]
timhughes/centos                       Centos with systemd installed and running       1                    [OK]
sgfinans/docker-centos                 CentOS with a running sshd and Docker           1                    [OK]
centos/redis                           Redis built for CentOS                          1                    [OK]
blacklabelops/centos                   CentOS Base Image! Built and Updates Daily!     1                    [OK]
darksheer/centos                       Base Centos Image -- Updated hourly             1                    [OK]
harisekhon/centos-scala                Scala + CentOS (OpenJDK tags 2.10-jre7 - 2...   1                    [OK]
kz8s/centos                            Official CentOS plus epel-release               0                    [OK]
grossws/centos                         CentOS 6 and 7 base images with gosu and l...   0                    [OK]
smartentry/centos                      centos with smartentry                          0                    [OK]
grayzone/centos                        auto build for centos.                          0                    [OK]
vcatechnology/centos                   A CentOS Image which is updated daily           0                    [OK]
ustclug/centos                          USTC centos                                    0                    [OK]
januswel/centos                        yum update-ed CentOS image                      0                    [OK]
repositoryjp/centos                    Docker Image for CentOS.                        0                    [OK]
wenjianzhou/centos                     centos                                          0                    [OK]


wKiom1hvBE7gM5qzAACrMI7eNZ4194.png-wh_50

可以看出下载速度还是很快的！