

* [【nginx】一台nginx服务器多域名配置 - wzl的博客 - CSDN博客 ](http://blog.csdn.net/wzl505/article/details/53213939)

server_name的匹配顺序
Nginx中的server_name指令主要用于配置基于名称虚拟主机，server_name指令在接到请求后的匹配顺序分别为：



* server_name的匹配顺序
  * `Nginx将按照1,2,3,4的顺序对server name进行匹配，只有有一项匹配以后就会停止搜索`
  * 1、准确的server_name匹配，例如：
  ```conf
  server {  
  listen 80;  
  server_name ssdr.info www.ssdr.info;  
  ...  
  }  
  ```
  * 2、以*通配符开始的字符串：
  server_name *.ssdr.info;  
  * 3、以*通配符结束的字符串：
  server_name www.*;  
  * 4、匹配正则表达式：
  server_name ~^(?.+)\.howtocn\.org$; 


