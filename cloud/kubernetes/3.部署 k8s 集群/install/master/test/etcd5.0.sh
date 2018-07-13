

http://192.168.0.140:2379/v2/keys

#检查etcd服务运行状态
http://192.168.0.140:2379/v2/members
#版本
http://192.168.0.140:2379/version
#读取写入
curl -L http://192.168.0.140:2379/v2/keys/message -XPUT -d value="Hello world"
http://192.168.0.140:2379/v2/keys/message