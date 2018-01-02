

* express 获取请求参数的方式 - CSDN博客 http://blog.csdn.net/u012849872/article/details/50768507
* http://qiaolevip.iteye.com/blog/2164206
* https://scotch.io/tutorials/use-expressjs-to-get-url-and-post-parameters


1、req.params //获取路由信息，例如： /user/:id 
例如：127.0.0.1:3000/index，这种情况下，我们为了得到index，我们可以通过使用req.params得到，通过这种方法我们就可以很好的处理Node中的路由处理问题，同时利用这点可以非常方便的实现MVC模式；（注：默认为{}）

2、req.query //get 方法的获取参数，例如：?id=12 
例如：127.0.0.1:3000/index?id=12，这种情况下，这种方式是获取客户端get方式传递过来的值，通过使用req.query.id就可以获得（注：默认为{}）

3、req.body //post方法的获取参数，例如：id= 
例如：127.0.0.1：300/index，然后post了一个id=2的值，这种方式是获取客户端post过来的数据，可以通过req.body.id获取

```js
var express        =         require("express");  
var bodyParser     =         require("body-parser");  
var app            =         express();  

var bodyParser = require('body-parser');
app.use(bodyParser.json()); // support json encoded bodies
app.use(bodyParser.urlencoded({ extended: true })); // support encoded bodies
  
// need it...  
app.use(bodyParser.urlencoded({ extended: false }));  
  
app.post('/login',function(req,res){  
  var user_name=req.body.user;  
  var password=req.body.password;  
  console.log("User name = "+user_name+", password is "+password);  
  res.end("yes");  
});  

```