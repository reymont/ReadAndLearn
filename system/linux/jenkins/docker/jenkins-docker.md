
https://hub.docker.com/_/jenkins/
https://hub.docker.com/explore/

http://192.168.99.100:8080/

```sh
#下载镜像
docker pull jenkins
#启动Jenkins
docker run -p 8080:8080 -p 50000:50000 jenkins
#initialAdminPassword
/var/jenkins_homecrets/initialAdminPassword
#登陆用户密码
/var/jenkins_home/users/admin/config.xml
```