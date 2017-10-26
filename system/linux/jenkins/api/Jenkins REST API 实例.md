

* [Jenkins REST API 实例 - 胖虫子 - 博客园 ](http://www.cnblogs.com/zjsupermanblog/archive/2017/07/26/7238422.html)

* api
  * 站点所有支持的API都可以通过地址http://192.168.6.224:8080/api 获取
  * 某一个job的所有相关API，可以通过地址 http://192.168.6.224:8080/job/{jobname}/api/来获取
  * http://192.168.6.224:8080/job/pythontest/api/json?pretty=true
  * http://192.168.6.224:8080/job/pythontest/api/xml
  * http://192.168.6.224:8080/job/pythontest/api/python?pretty=true

# JOB API---获取Build相关信息
```sh
# http://192.168.6.224:8080/job/pythontest/{build_number}/api/json?pretty=true
 http://192.168.6.224:8080/job/pythontest/1/api/json?pretty=true
#添加   tree=builds[*]  可以获取所有builds下的节点
http://192.168.6.224:8080/job/pythontest/api/json?pretty=true&tree=builds[*]
#获取builds下，所有displayName的节点
http://192.168.6.224:8080/job/pythontest/api/json?pretty=true&tree=builds[displayName]
#获取三个displayName节点中第二个节点，可以通过{X,Y}
http://192.168.6.224:8080/job/pythontest/api/json?pretty=true&tree=builds[displayName]{1,2}
#获取两个相关的节点，通过,连接两个过滤节点
http://192.168.6.224:8080/job/pythontest/api/json?pretty=true&tree=builds[*],url[*]
```

# JOB API--执行Build:
```sh
##1 直接执行，不包括参数 POST
http://192.168.6.224:8080/job/pythontest/build
##2 包括参数执行
http://192.168.6.224:8080/job/pythontest/buildWithParameters
test="testonly"
```

# JOB API--JOB conofig.xml:

http://192.168.6.224:8080/job/pythontest/config.xml

*  站点 API:
  * 站点所有相关的API
    * http://192.168.6.224:8080/api查询到
    * http://192.168.6.224:8080/api/xml
    * 过滤出所有jobs的name
      * http://192.168.6.224:8080/api/json?pretty=true&tree=jobs[name[*]]
  * 查询job的相关信息
    * http://192.168.6.224:8080/api/json?pretty=true
  * 还可以创建Job,拷贝Job，停止或重启Jenkis的服务

* 站点API_创建Job
  * 查看
    * http://192.168.6.224:8080/job/pythontest/config.xml
  * 创建
    * http://192.168.6.224:8080/createItem
    * 在Jenkins的安装目录下，找到子目录\jobs，然后在其中创建一个目录testjob
    * 如果不创建这个目录，直接调用API，是会失败的
    * 创建job的name
      * http://192.168.6.224:8080/createItem?name=testjob
* 站点API_拷贝Job
  * POST
    * http://192.168.6.224:8080/createItem
  * 三个参数
    * name (复制后新创建的的job name,如pythontest2
    * mode(模式，固定给予值copy)
    * from( 要复制的Job的Job name,如pythontest)
  * 站点API_重启
    * 重启：http://192.168.6.224:8080/restart
    * 安全重启：http://192.168.6.224:8080/safeRestart