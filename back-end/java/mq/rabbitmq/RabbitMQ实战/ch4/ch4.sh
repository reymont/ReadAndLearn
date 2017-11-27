
# 下载easy_install，安装pika
wget http://peak.telecommunity.com/dist/ez_setup.py
python ez_setup.py
easy_install pika
# 在./sbin/目录中配置用户和密码
./rabbitmqctl add_user alert_user alterme
# 给alert_user用户授予默认vhost"/"上的read/write/configure权限
./rabbitmqctl set_permissions alert_user ".*" ".*" ".*"