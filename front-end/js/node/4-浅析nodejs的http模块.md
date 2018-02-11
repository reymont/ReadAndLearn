浅析nodejs的http模块 - 简书 https://www.jianshu.com/p/ab2741f78858

我们知道传统的HTPP服务器会由Aphche、Nginx、IIS之类的软件来担任，但是nodejs并不需要，nodejs提供了http模块，自身就可以用来构建服务器，而且http模块是由C++实现的，性能可靠。我们在nodejs中的教程或者书籍中常常会通过一个简易的http服务器来作为开头的学习，就像下面这个例子

var http=require("http");

http.createServer(function(req,res){
    res.writeHead(200,{
        "content-type":"text/plain"
    });
    res.write("hello nodejs");
    res.end();
}).listen(3000);
打开浏览器，输入localhost:3000我们就可以看到屏幕上的hello nodejs了，这表明这个最简单的nodejs服务器已经搭建成功了。
nodejs中的http模块中封装了一个HTPP服务器和一个简易的HTTP客户端，http.Server是一个基于事件的http服务器，http.request则是一个http客户端工具，用于向http服务器发起请求。而上面的createServer方法中的参数函数中的两个参数req和res则是分别代表了请求对象和响应对象。其中req是http.IncomingMessage的实例，res是http.ServerResponse的实例，这可以从nodejs中的源码中获取这个信息（当然我们作为初学者，自然是不太可能读懂其源码，推荐慕课网的课程《进击的nodjs基础（一）》，scott老师会带我们基本走一下http模块的源码，会有一个大概的了解）。以下将从http服务器和http客户端简要走一遍http模块

# 一、http服务器####

文章开头使用的createServer方法返回了一个http.Server对象，这其实是一个创建http服务的捷径，如果我们用以下代码来实现的话，也将一样可行

var http=require("http");
var server=new http.Server();

server.on("request",function(req,res){
    res.writeHead(200,{
        "content-type":"text/plain"
    });
    res.write("hello nodejs");
    res.end();
});
server.listen(3000);
以上代码是通过直接创建一个http.Server对象，然后为其添加request事件监听，其实也就说createServer方法其实本质上也是为http.Server对象添加了一个request事件监听，这似乎更好理解了，那让我们看看http.Server的事件吧

## 1、http.Server的事件######

正如我们上面所说，http.Server是一个基于事件的服务器，她是继承自EventEmitter，事实上，nodejs中大部分模块都继承自EventEmitter，包括fs、net等模块，这也是为什么说nodejs基于事件驱动（关于EventEmitter的更多内容可以在官方api下的events模块找到），http.Server提供的事件如下：

request：当客户端请求到来时，该事件被触发，提供两个参数req和res，表示请求和响应信息，是最常用的事件
connection：当TCP连接建立时，该事件被触发，提供一个参数socket，是net.Socket的实例
close：当服务器关闭时，触发事件（注意不是在用户断开连接时）
正如上面我们所看到的request事件是最常用的，而参数req和res分别是http.IncomingMessage和http.ServerResponse的实例，那么我们来看看这两个类吧

## 2、http.IncomingMessage######

http.IncomingMessage是HTTP请求的信息，是后端开发者最关注的内容，一般由http.Server的request事件发送，并作为第一个参数传递，http请求一般可以分为两部分：请求头和请求体（更多关于http协议的知识可以查看我之前的笔记http入门与挖坑）;其提供了3个事件，如下

data：当请求体数据到来时，该事件被触发，该事件提供一个参数chunk，表示接受的数据，如果该事件没有被监听，则请求体会被抛弃，该事件可能会被调用多次（这与nodejs是异步的有关系）
end：当请求体数据传输完毕时，该事件会被触发，此后不会再有数据
close：用户当前请求结束时，该事件被触发，不同于end，如果用户强制终止了传输，也是用close
http.IncomingMessage的属性如下：


3、http.ServerResponse######

http.ServerResponse是返回给客户端的信息，决定了用户最终看到的内容，一般也由http.Server的request事件发送，并作为第二个参数传递，它有三个重要的成员函数，用于返回响应头、响应内容以及结束请求

res.writeHead(statusCode,[heasers])：向请求的客户端发送响应头，该函数在一个请求中最多调用一次，如果不调用，则会自动生成一个响应头
res.write(data,[encoding])：想请求的客户端发送相应内容，data是一个buffer或者字符串，如果data是字符串，则需要制定编码方式，默认为utf-8，在res.end调用之前可以多次调用
res.end([data],[encoding])：结束响应，告知客户端所有发送已经结束，当所有要返回的内容发送完毕时，该函数必需被调用一次，两个可选参数与res.write()相同。如果不调用这个函数，客户端将用于处于等待状态。
看完http服务器，我们看一看http的客户端吧

# 二、http客户端####

http模块提供了两个函数http.request和http.get，功能是作为客户端向http服务器发起请求。

## 1、http.request(options,callback)######

options是一个类似关联数组的对象，表示请求的参数，callback作为回调函数，需要传递一个参数，为http.ClientResponse的实例，http.request返回一个http.ClientRequest的实例。

options常用的参数有host、port（默认为80）、method（默认为GET）、path（请求的相对于根的路径，默认是“/”，其中querystring应该包含在其中，例如/search?query=byvoid）、headers（请求头内容）

如下示例代码：

```js
var http=require("http");

var options={
    hostname:"cn.bing.com",
    port:80
}

var req=http.request(options,function(res){
    res.setEncoding("utf-8");
    res.on("data",function(chunk){
        console.log(chunk.toString())
    });
    console.log(res.statusCode);
});
req.on("error",function(err){
    console.log(err.message);
});
req.end();
```
我们运行这段代码我们在控制台可以发现，必应首页的html代码已经呈现出来了。

接下来我们来做一个关于POST请求的代码。

```js
var http=require("http");
var querystring=require("querystring");

var postData=querystring.stringify({
    "content":"我真的只是测试一下",
    "mid":8837
});

var options={
    hostname:"www.imooc.com",
    port:80,
    path:"/course/document",
    method:"POST",
    headers:{
        "Accept":"application/json, text/javascript, */*; q=0.01",
        "Accept-Encoding":"gzip, deflate",
        "Accept-Language":"zh-CN,zh;q=0.8",
        "Connection":"keep-alive",
        "Content-Length":postData.length,
        "Content-Type":"application/x-www-form-urlencoded; charset=UTF-8",
        "Cookie":"imooc_uuid=6cc9e8d5-424a-4861-9f7d-9cbcfbe4c6ae; imooc_isnew_ct=1460873157; loginstate=1; apsid=IzZDJiMGU0OTMyNTE0ZGFhZDAzZDNhZTAyZDg2ZmQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMjkyOTk0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGNmNmFhMmVhMTYwNzRmMjczNjdmZWUyNDg1ZTZkMGM1BwhXVwcIV1c%3DMD; PHPSESSID=thh4bfrl1t7qre9tr56m32tbv0; Hm_lvt_f0cfcccd7b1393990c78efdeebff3968=1467635471,1467653719,1467654690,1467654957; Hm_lpvt_f0cfcccd7b1393990c78efdeebff3968=1467655022; imooc_isnew=2; cvde=577a9e57ce250-34",
        "Host":"www.imooc.com",
        "Origin":"http://www.imooc.com",
        "Referer":"http://www.imooc.com/video/8837",
        "User-Agent":"Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2763.0 Safari/537.36",
        "X-Requested-With":"XMLHttpRequest",
    }
}

var req=http.request(options,function(res){
    res.on("data",function(chunk){
        console.log(chunk);
    });
    res.on("end",function(){
        console.log("评论完毕！");
    });
    console.log(res.statusCode);
});

req.on("error",function(err){
    console.log(err.message);
})
req.write(postData);
req.end();
```
这段代码我们模拟了向慕课网发起评论的功能，但是因为慕课网对于这种发起方式专门做了重定向，所以我们并不能在评论区看到我们的评论（另外在一些对这种请求没有做处理的网站，擅自发起评论，很可能会当做网络攻击，所以不要玩火，你懂得），但是这段代码却很可以说明这个过程。另外，代码中的请求头和postData里面的键我们都是可以通过开发者工具network下找到的。

## 2、http.get(options,callback)######

这个方法是http.request方法的简化版，唯一的区别是http.get自动将请求方法设为了GET请求，同时不需要手动调用req.end()，但是需要记住的是，如果我们使用http.request方法时没有调用end方法，服务器将不会收到信息。因为http.get和http.request方法都是放回一个http.ClientRequest对象，所以我们来看一下这两个对象。

## 3、http.ClientRequest######

http.ClientRequest是由http.request或者是http.get返回产生的对象，表示一个已经产生而且正在进行中的HTPP请求，提供一个response事件，也就是我们使用http.get和http.request方法中的回调函数所绑定的对象，我们可以显式地绑定这个事件的监听函数

```js
var http=require("http");

var options={
    hostname:"cn.bing.com",
    port:80
}

var req=http.request(options);
req.on("response",function(res){
        res.setEncoding("utf-8");
    res.on("data",function(chunk){
        console.log(chunk.toString())
    });
    console.log(res.statusCode);
})

req.on("error",function(err){
    console.log(err.message);
});
req.end();
```

http.ClientRequest也提供了write和end函数，用于向服务器发送请求体，通常用于POST、PUT等操作，所有写操作都必须调用end函数来通知服务器，否则请求无效。此外，这个对象还提供了abort()、setTimeout()等方法，具体可以参考文档

## 4、http.ClientReponse######

与http.ServerRequest相似，提供了三个事件，data、end、close，分别在数据到达、传输结束和连接结束时触发，其中data事件传递一个参数chunk，表示接受到的数据。其属性如下


此外，这个对象提供了几个特殊的函数

response。setEncoding([encoding])：设置默认的编码，当data事件被触发时，数据将会以encoding编码，默认值是null，也就是不编码，以buffer形式存储
response.pause()：暂停结束数据和发送事件，方便实现下载功能
response.resume()：从暂停的状态中恢复
好的，到这里http模块的主要功能已经介绍完了。我们接着来做一个练习，我们知道中山大学今年院系改革，弄得我这个中大学生也不知道中大到底有那些学院了，是的，我们打开官网我们会发现有哪些学院，但是我想用http模块把里面的学院名给扒下来，好的，那我就做了以下代码

var cheerio=require("cheerio");
var http=require("http");
var fs=require("fs");

var options="http://www.sysu.edu.cn/2012/cn/jgsz/yx/index.htm";
var htmlData=""
var req=http.request(options,function(res){
    res.on("data",function(chunk){
        htmlData+=chunk;
    });
    res.on("end",function(){
        var $=cheerio.load(htmlData);
        var textcontent=$("tr").text();
        fs.writeFile("./school.txt",textcontent,"utf-8")
    });
});
req.end();
之后我们就可在school.txt文件中看到所有的学院了，怎么样，是不是很有成就感，题外话，我这里用了一个外部的模块cheerio，这个模块可以让我们像jquery一样操作html代码，这个模块的介绍就到这里了（大家不要用这个模块的知识去干坏事哦，否则我可不负责┑(￣Д ￣)┍）。

作者：忽如寄
链接：https://www.jianshu.com/p/ab2741f78858
來源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。