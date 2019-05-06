

* [以Docker方式运行的Jenkins | 封尘网 ](https://www.58jb.com/html/109.html)

```sh
#获取镜像
docker pull jenkins  
#查找镜像
docker search jenkins 
#启动
docker run -d -t --name=jenkins -p 8080:8080 -v /tmp/jenkins/:/var/jenkins jenkins 
#查看Docker数据目录
docker inspect jenkins|grep "Source" 
# /var/jenkins_home/secrets/initialAdminPassword
```