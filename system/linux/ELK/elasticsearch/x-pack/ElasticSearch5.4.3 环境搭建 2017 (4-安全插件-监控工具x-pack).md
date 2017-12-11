

ElasticSearch5.4.3 环境搭建 2017 (4-安全插件-监控工具x-pack) - CSDN博客 http://blog.csdn.net/fly_leopard/article/details/73993180

前面已经说了配置了ElasticSearch和Kibana，下面说一下，安全插件x-pack。自5.0以后，marvel的监控功能移植到了x-pack，所以完成x-pack安装后，也就有了监控工具。

对于ElasticSearch的api请求和Kibana的管理界面都是无安全校验的，不需要用户密码。真实环境中都是需要配置用户密码来设置权限提高安全性。
更多参照：啊~~
ElasticSearch的x-pack安装：

         对于已加入到启动项的elasticsearch来说，安装需要到/usr/share/elasticsearch/bin下，执行elasticsearch-plugin脚本命令，如果到自定义安装目录里面的bin内执行这个最终安装的x-pack在自定义目录下，通过service启动时，这个x-pack是无效的。而最终x-pack要安装在/usr/share/elasticsearch/plugins/x-pack下，服务才能使用这个x-pack。
cd /usr/share/elasticsearch/bin
./elasticsearch-plugin install x-pack
等待下载并安装，随后输入2次y。安装完成。
附加：
上述操作完成，还有一项额外的操作，是用来验证，验证信息传输过程中是否被修改过的配置，
cd /usr/share/elasticsearch/bin/x-pack/
./syskeygen
生成system_key，默认在/etc/elasticsearch/x-pack/下

这个文件复制到其他节点上的配置文件目录，
注意：生成之后，要修改system_key的权限，我这里直接chmod -R 777/etc/elasticsearch/x-pack/修改的权限。
不修改启动时候elasticsearch读取该文件permission denied.
最后修改/etc/elasticsearch/elasticsearch.yml最后加上
xpack.security.audit.enabled: true
重启，访问ip:9200 (不能直接访问了，需要加用户名密码认证)
curl -u elastic ip:9200

elastic是默认用户，默认密码是changeme，修改密码，让输入elastic的原密码回车即可
或者curl -u elastic:密码 ip:9200回车即可，不需要再输入密码
[html] view plain copy
curl -XPUT -u elastic '10.144.255.45:9200/_xpack/security/user/elastic/_password' -H "Content-Type: application/json" -d '{  
  "password" : "xxxx"  
}'  

集群中修改一个主节点的密码即可，其他的就会自动修改。
Kibana的x-pack安装

 cd /usr/share/kibana/bin/
./kibana-plugin install x-pack
等待下载完成，并安装。
修改配置文件：/etc/kibana/kibana.yml
elasticsearch.username: "elastic"
elasticsearch.password: "xxxxx"
保存退出，service kibana restart 重启
访问如下：输入用户名密码登陆，用户名密码和elasticsearch中修改的相同。


x-pack用户的一些相关操作：官方的
监控：
