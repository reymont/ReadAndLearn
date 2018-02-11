nodejs中http的get和request使用方法详解 - 阿里云 https://yq.aliyun.com/ziliao/20655

GET简介

我们首先来运行一下下面的代码

const http = require("http")
http.get('http://www.baidu.com', (res) => {
  console.log(`Got response: ${res.statusCode}`);
  // consume response body
  res.resume();
}).on('error', (e) => {
  console.log(`Got error: ${e.message}`);
});
会返回一个200的状态码！

将上面代码稍微改进一下。

```js
const http = require("http") 
const url = "/post/nodejs_rmyyong" 
http.get(url,(res)=>{
    var html = ""
    res.on("data",(data)=>{
        html+=data
    })

    res.on("end",()=>{
        console.log(html)
    })
}).on("error",(e)=>{
    console.log(`获取数据失败: ${e.message}`)
})
```
运行一下这段代码，会怎么样？会把我这个页面大源码给爬下来了！

也就是说，我们可以利用http的get方法，写一个爬虫，来爬取网页数据！（很多网页爬虫都是用python写的）我们前端也可以用node写网页爬虫，来爬取数据！当然，我们来要对爬来的数据进行筛选和整合，筛选出我们想要的数据！我们可以引用cheerio,进行数据的筛选。爬取网页数据呢，可以配合nodejs的Promise对象，Promise对象是ES6的一个新的对象，最早是社区里面先提出来的，后来，jquery deferred等都引入关于jquery的deferred，我之前也写过一篇文章/post/jquery_deferred_img 有兴趣的可以看一下！

写爬虫代码，我在这里就不展开了，感兴趣的可以关注我的github，我会写一个简单的放上去，大家可以参考（ps暂时还没有写哦）。

# request简介

http的request也很厉害！官方这么描述“This function allows one to transparently issue requests.”他的官方案例如下：

var postData = querystring.stringify({
  'msg' : 'Hello World!'
});
var options = {
  hostname: 'www.google.com',
  port: 80,
  path: '/upload',
  method: 'POST',
  headers: {
    'Content-Type': 'application/x-www-form-urlencoded',
    'Content-Length': postData.length
  }
};

var req = http.request(options, (res) => {
  console.log(`STATUS: ${res.statusCode}`);
  console.log(`HEADERS: ${JSON.stringify(res.headers)}`);
  res.setEncoding('utf8');
  res.on('data', (chunk) => {
    console.log(`BODY: ${chunk}`);
  });
  res.on('end', () => {
    console.log('No more data in response.')
  })
});

req.on('error', (e) => {
  console.log(`problem with request: ${e.message}`);
});

// write data to request body
req.write(postData);
req.end();
我们可以利用这个http的request来提交一下评论，我们可以获取网站的一些评论接口，通过上面options，我们可以配置请求的headers信息，进行网站的灌水评论！

以上是云栖社区小编为您精心准备的的内容，在云栖社区的博客、问答、公众号、人物、课程等栏目也有的相关内容，欢迎继续使用右上角搜索按钮进行搜索网页 ， 数据 ， 对象 ， 代码 const nodejs request get、request.getpart 方法、getrequest 方法、ios set get方法详解、nodejs request，以便于您获取更多的相关知识。