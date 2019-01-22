

* [nginx使用ssl模块配置支持HTTPS访问 - 梦徒 - 博客园 ](http://www.cnblogs.com/saneri/p/5391821.html)

```sh
# 首先确保机器上安装了openssl和openssl-devel		
yum install -y openssl openssl-devel
# 创建服务器私钥，命令会让你输入一个口令 kye1030
openssl genrsa -des3 -out server.key 1024
# 生成证书颁发机构,用于颁发公钥
openssl req -new -key server.key -out server.csr
# 在加载SSL支持的Nginx并使用上述私钥时除去必须的口令
cp server.key server.key.org
openssl rsa -in server.key.org -out server.key
# 最后标记证书使用上述私钥和CSR
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
# 修改Nginx配置文件，让其包含新标记的证书和私钥
#vim /usr/local/nginx/server/www.localhost.cn
server {
        listen       443;                                                                       //监听端口为443
        server_name  www.localhost.cn;
  
        ssl                  on;        　　　　　　　　　　//开启ssl
        ssl_certificate      /etc/pki/tls/certs/server.crt;      //证书位置
        ssl_certificate_key  /etc/pki/tls/certs/server.key;      //私钥位置
        ssl_session_timeout  5m;
        ssl_protocols  SSLv2 SSLv3 TLSv1;       　　　　 //指定密码为openssl支持的格式
        ssl_ciphers  HIGH:!aNULL:!MD5;              //密码加密方式
        ssl_prefer_server_ciphers   on;             //依赖SSLv3和TLSv1协议的服务器密码将优先于客户端密码
  
        location / {
            root   html;                        //根目录的相对位置
            index  index.html index.htm;
        }
    }
# 生效
../sbin/nginx -t
../sbin/nginx -s reload
```