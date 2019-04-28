# 1. http1.0，http1.1，http2.0区别
https://www.deanwangpro.com/2017/01/31/ali-interview/

说实话没有接触过1.0，只知道跟1.0相比1.1可以一次传输多个文件，各类浏览器大概都支持3~5个请求同时发送。

http2.0也是最近调Nginx才知道的一些，主要就是二进制的格式替代了原来的文本。后来查了资料大概知道增加了多路复用和首部压缩解决了head of line blocking，另外还有server pushing等新特性。协议的东西还是要看一看官网的说明，不过这东西过一段就容易忘。

# 2. 浏览器渲染机制
https://www.deanwangpro.com/2017/01/31/ali-interview/
这题其实我没法答，问的太大，大概瞥过V8的一些机制。比如构建Dom，生成CSS Rule等等。但是真实没有特别系统的理解过。

# 3. 浏览器meta charset和response中content-type的优先级
https://www.deanwangpro.com/2017/01/31/ali-interview/
http://www.w3school.com.cn/tags/tag_meta.asp

```html
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
```
简写才是
```html
<meta charset="utf-8" />
```
http-equiv 这个属性就是对应 HTTP response headers 里面的项目，其初衷是让不能（比如没有权限）设定服务器 header 的站点可以通过它来告知浏览器一些页面内容的相关信息。

了解以上就知道肯定是后者的优先级更高。