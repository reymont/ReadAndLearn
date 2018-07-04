### http://www.mamicode.com/info-detail-1625053.html
### 1、启动Rabbitmq
systemctl enable rabbitmq-server.service
# Created symlink from /etc/systemd/system/multi-user.target.wants/rabbitmq-server.service to /usr/lib/systemd/system/rabbitmq-server.service.
systemctl start rabbitmq-server.service
### 2. 新建Rabbitmq用户并授权
rabbitmqctl add_user openstack openstack
# Creating user "openstack" ...
# rabbitmqctl set_permissions openstack ".*" ".*" ".*"
# Setting permissions for user "openstack" in vhost "/" ...
### 3. 启用Rabbitmq的web管理插件
rabbitmq-plugins list
rabbitmq-plugins enable rabbitmq_management
### 4. 重启Rabbitmq
systemctl restart rabbitmq-server.service
### 5. 查看Rabbit的端口，其中5672是服务端口，15672是web管理端口，25672是做集群的端口
ss -tunlp|grep 5672
### 在web界面添加openstack用户，设置权限，首次登陆必须使用账号和密码，必须都是guest