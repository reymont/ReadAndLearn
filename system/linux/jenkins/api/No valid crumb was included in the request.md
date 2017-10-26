

* [jenkins error: "No valid crumb was included in the request" - - ITeye博客 ](http://lixuanbin.iteye.com/blog/2040996)
* [Jenkins REST API Create job - Stack Overflow ](https://stackoverflow.com/questions/38137760/jenkins-rest-api-create-job)

enkins by default has CSRF Protection enabled which prevents one-click attacks. To invoke the request, you need to obtain the crumb from /crumbIssuer/api/xml using your credentials and include it into your request. For example:

```sh
CRUMB=$(curl -s 'http://USER:TOKEN@localhost:8080/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)')
```
then you can create a job (by including crumb into your header):

```sh
curl -X POST -H "$CRUMB" "http://USER:TOKEN@localhost:8080/createItem?name=NewJob"
```
If above won't work, check your crumb (echo $CRUMB) or run curl with -u USER:TOKEN.

For more detailed explanation, see: [Running jenkins jobs via command line](http://www.inanzzz.com/index.php/post/jnrg/running-jenkins-build-via-command-line).

三、错误原因（Reason）：
jenkins在http请求头部中放置了一个名为.crumb的token。在使用了反向代理，并且在jenkins设置中勾选了“防止跨站点请求伪造（Prevent Cross Site Request Forgery exploits）”之后此token会被转发服务器apache/nginx认为是不合法头部而去掉。导致跳转失败。
The problem is that jenkins stores its' csrf token in a http header called '.crumb', AFAIK headers must only contain alphanumerics and dashes, and apache/nginx will remove invalid headers from the request (unless configured not to).

四、解决方案（Solution）：
1.在apache/nginx中设置ignore_invalid_headers，或者：
2.在jenkins全局安全设置中取消勾选“防止跨站点请求伪造（Prevent Cross Site Request Forgery exploits）”。
1.Set ignore_invalid_headers in your apache/nginx server, or:
2.Uncheck "Prevent Cross Site Request Forgery exploits" in jenkins global security settings.
 
【参考资料（References）】
https://issues.jenkins-ci.org/browse/JENKINS-12875
http://en.wikipedia.org/wiki/Cross-site_request_forgery
http://www.cnblogs.com/hyddd/archive/2009/04/09/1432744.html