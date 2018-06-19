

SonarQube Scanner的配置与使用简介 - CSDN博客 http://blog.csdn.net/u012500848/article/details/72963587

一．下载

下载地址：
https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.0.3.778-windows.zip
官方文档：
https://docs.sonarqube.org/display/SCAN/Analyzing+with+SonarQube+Scanner

二．安装

第一步：
将下载的压缩包解压缩到任意目录；
第二步：
打开Sonar Scanner根目录下的/conf/sonar-scanner.properties文件，配置如下：
```conf
# sonar.host.url配置的是SonarQube服务器的地址
sonar.host.url=http://localhost:9000
```
第三步：
新建系统变量：
SONAR_SCANNER_HOME=Sonar Scanner根目录
修改系统变量path，新增%SONAR_SCANNER_HOME%\bin（不新建SONAR_SCANNER_HOME直接新增path亦可）；
打开cmd面板，输入sonar-scanner -version，出现下图，则表示环境变量设置成功：

三．使用

在项目根目录下新建sonar-project.properties文件，内容如下：
```conf
# 项目的key
sonar.projectKey=projectKey
# 项目的名字
sonar.projectName=projectName
# 项目的版本
sonar.projectVersion=1.0.0
# 需要分析的源码的目录，多个目录用英文逗号隔开
sonar.sources=D:/workspace/Demo/src
```
设置完后，打开cmd面板，进入项目根目录下，然后输入“sonar-scanner”命令，执行代码分析：

然后打开http://localhost:9000 （SonarQube服务器），输入账号密码，即可查看代码分析结果。

转载请注明：李锋镝的个人博客>> http://www.lifengdi.com/article/10050.html