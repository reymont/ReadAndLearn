

* [Jenkins REST API 使用指北 - CSDN博客 ](http://blog.csdn.net/xiaosongluo/article/details/52797156)

* Jenkins Plugin基础开发入门
  * Stapler
    * 自动为应用程序对象绑定URL，并创建直观的URL层次结构
  * 持久化
  * 插件
* 对象的数据可以通过固定的URL进行访问
  * XML: /jenkins/…/api/xml
  * JSON: /jenkins/…/api/json
  * PYTHON:/jenkins/…/api/python
* 官方搭建的 Jenkins 的 以下三个 URL
  * https://ci.jenkins.io/api/
  * https://ci.jenkins.io/
  * https://ci.jenkins.io/api/json

* Job CRUD
```sh
  # Create a Job with config.xml
  curl -X POST "http://user:password@<Jenkins_URL>/createItem?name=<Job_Name>" --data-binary "@newconfig.xml" -H "Content-Type: text/xml"
  # Retrieve/Fetch a Job’s config.xml
  curl -X GET http://user:password@<Jenkins_URL>/job/<Job_Name>/config.xml
  # Update a Job’s config.xml
  curl -X POST http://user:password@<Jenkins_URL>/job/<Job_Name>/config.xml --data-binary "@mymodifiedlocalconfig.xml"
  # Delete a job
  curl -X POST http://user:password@<Jenkins_URL>/job/<Job_Name>/doDelete
```

* Build - CONTROL
```sh
#Perform a Build
curl -X POST http://user:password@<Jenkins_URL>/job/<Job_Name>/build
#参数化构建
curl -X POST http://user:password@<Jenkins_URL>/job/JOB_NAME/build --data --data-urlencode json=<Parameters>
#Retrieve a Build
curl -X GET http://user:password@<Jenkins_URL>/queue/api/json?<Filter_Condition>
#例如，可以按照如下的方式查找名字为 name 的 task :
curl -X GET http://user:password@<Jenkins_URL>/queue/api/json?tree=items[id,task[name]]
#或者可以直接按如下方式访问 Job 最近一次构建的详情：
curl -X GET http://user:password@<Jenkins_URL>/lastBuild/api/json
#Stop a Build
curl -X POST http://user:password@<Jenkins_URL>/job/<Job_Name>/<Build_Number>/stop
curl -X POST http://user:password@<Jenkins_URL>/queue/cancelItem?id=<Queue_Item>
```
