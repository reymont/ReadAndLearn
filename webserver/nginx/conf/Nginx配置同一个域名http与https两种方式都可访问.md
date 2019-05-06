

* [Nginx配置同一个域名http与https两种方式都可访问 - 寂寞无言飘过 - 博客园 ](http://www.cnblogs.com/fjping0606/p/6006552.html)

```sh
    listen 80;
    listen 443 ssl;　　
   #   ssl on;　　##把ssl on；这行注释掉, ssl写在443端口后面, 这样http和https的链接都可以用
　　ssl_certificate /usr/local/nginx/ssl/test.pay.joyhj.com_cert.crt;
　　ssl_certificate_key /usr/local/nginx/ssl/test.pay.joyhj.com.key;
```