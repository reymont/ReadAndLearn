什么是webhook - 旺旺Ever - 博客园 http://www.cnblogs.com/wangwangever/p/7467142.html

什么是webhook

翻译，原文地址：https://sendgrid.com/blog/webhook-vs-api-whats-difference/

一、概述
Webhook是一个API概念，并且变得越来越流行。我们能用事件描述的事物越多，webhook的作用范围也就越大。Webhook作为一个轻量的事件处理应用，正变得越来越有用。

准确的说webhoo是一种web回调或者http的push API，是向APP或者其他应用提供实时信息的一种方式。Webhook在数据产生时立即发送数据，也就是你能实时收到数据。这一种不同于典型的API，需要用了实时性需要足够快的轮询。这无论是对生产还是对消费者都是高效的，唯一的缺点是初始建立困难。

Webhook有时也被称为反向API，因为他提供了API规则，你需要设计要使用的API。Webhook将向你的应用发起http请求，典型的是post请求，应用程序由请求驱动。

二、使用webhook
消费一个webhook是为webhook准备一个URL，用于webhook发送请求。这些通常由后台页面和或者API完成。这就意味你的应用要设置一个通过公网可以访问的URL。

多数webhook以两种数据格式发布数据：JSON或者XML，这需要解释。另一种数据格式是application/x-www-form-urlencoded or multipart/form-data。这两种方式都很容易解析，并且多数的Web应用架构都可以做这部分工作。

三、Webhook调试
调试webhook有时很复杂，因为webhook原则来说是异步的。你首先要解发他，然后等待，接着检查是否有响应。这是枯燥并且相当低效。幸运的是还有其他方法：

1、明白webhook能提供什么，使用如RequestBin之类的工具收集webhook的请求；

2、用cURL或者Postman来模拟请求；

3、用ngrok这样的工具测试你的代码；

4、用Runscope工具来查看整个流程。

四、webhook安全
因为webhook发送数据到应用上公开的URL，这就给其他人找到这个URL并且发送错误数据的机会。你可采用技术手段，防止这样的事情发生。最简单的方法是采用https（TLS connection）。除了使用https外，还可以采用以下的方法进一步提高安全性：

1、首先增加Token，这个大多数webhook都支持；

2、增加认证；

3、数据签名。

五、重要的问题
当作为webhook的消费者时有两件事需要铭记于心：

1、webhook通过请求发送数据到你的应用后，就不再关注这些数据。也就是说如果你的应用存在问题，数据会丢失。许多webhook会处理回应，如果程序出现错误会重传数据。如果你的应用处理这个请求并且依然返回一个错误，你的应用就会收到重复数据。

2、webhook会发出大量的请求，这样会造成你的应用阻塞。确保你的应用能处理这些请求。