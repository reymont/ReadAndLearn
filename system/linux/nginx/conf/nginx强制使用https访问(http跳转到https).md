

* [nginx强制使用https访问(http跳转到https) - yun007 - 博客园 ](http://www.cnblogs.com/yun007/p/3739182.html)

# nginx的rewrite方法
 

思路

这应该是大家最容易想到的方法，将所有的http请求通过rewrite重写到https上即可

```conf
server {  
    listen  192.168.1.111:80;  
    server_name test.com;  
      
    rewrite ^(.*)$  https://$host$1 permanent;  
}  
```

搭建此虚拟主机完成后，就可以将http://test.com的请求全部重写到https://test.com上了
 

# nginx的497状态码
 

error code 497


 
497 - normal request was sent to HTTPS  

解释：当此虚拟站点只允许https访问时，当用http访问时nginx会报出497错误码
 
思路

利用error_page命令将497状态码的链接重定向到https://test.com这个域名上
 
配置

```conf 
server {  
    listen       192.168.1.11:443;  #ssl端口  
    listen       192.168.1.11:80;   #用户习惯用http访问，加上80，后面通过497状态码让它自动跳到443端口  
    server_name  test.com;  
    #为一个server{......}开启ssl支持  
    ssl                  on;  
    #指定PEM格式的证书文件   
    ssl_certificate      /etc/nginx/test.pem;   
    #指定PEM格式的私钥文件  
    ssl_certificate_key  /etc/nginx/test.key;  
      
    #让http请求重定向到https请求   
    error_page 497  https://$host$uri?$args;  
}  
```
 

# index.html刷新网页
 

思路

上述两种方法均会耗费服务器的资源，我们用curl访问baidu.com试一下，看百度的公司是如何实现baidu.com向www.baidu.com的跳转
 

 
可以看到百度很巧妙的利用meta的刷新作用，将baidu.com跳转到www.baidu.com.因此我们可以基于http://test.com的虚拟主机路径下也写一个index.html，内容就是http向https的跳转
 
index.html
```html 
<html>  
<meta http-equiv="refresh" content="0;url=https://test.com/">  
</html>  
```

nginx虚拟主机配置

```conf
server {  
    listen 192.168.1.11:80;  
    server_name test.com;  
      
    location / {  
                #index.html放在虚拟主机监听的根目录下  
        root /srv/www/http.test.com/;  
    }  
        #将404的页面重定向到https的首页  
    error_page  404 https://test.com/;  
}  
```
 
 
后记
上述三种方法均可以实现基于nginx强制将http请求跳转到https请求，大家可以评价一下优劣或者根据实际需求进行选择。