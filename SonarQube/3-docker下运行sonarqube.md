docker下运行sonarqube - CSDN博客 http://blog.csdn.net/zhuchuangang/article/details/72464882

1 基于PostgreSQL运行SonarQube

docker-compose.yml:

version: '2'

services:
  sonarqube:
    image: sonarqube
    container_name: sonarqube-server
    ports:
     - "9000:9000"
     - "5432:5432"
    links:
      - db:db
    environment:
     - SONARQUBE_JDBC_URL=jdbc:postgresql://db:5432/sonar
    volumes:
      - /tmp:/opt/sonarqube/extensions

  db:
    image: postgres
    container_name: postgres
    environment:
     - POSTGRES_USER=sonar
     - POSTGRES_PASSWORD=sonar

注意：/opt/sonarqube/extensions是容器内部文件路径，映射到宿主机的/tmp目录下。
在docker-compose.yml文件所在的目录，控制台输入命令：

docker-compose up -d
1
打开浏览器输入网址：http://:9000，默认的用户名admin密码admin.

2 分析项目

maven项目，在项目目录下运行：

mvn sonar:sonar
1
或者

mvn sonar:sonar \
  -Dsonar.host.url=http://<DOCKER-MACHINE-IP>:9000 \
  -Dsonar.jdbc.url=jdbc:postgresql://<DOCKER-MACHINE-IP>/sonar
3 中文插件

可能会因为网络问题，造成中文插件无法下载，可以通过下面的地址https://github.com/SonarQubeCommunity/sonar-l10n-zh/releases/tag/sonar-l10n-zh-plugin-1.15下载sonar-l10n-zh-plugin-1.15.jar插件，并将插件放到/tmp/plugins目录下。