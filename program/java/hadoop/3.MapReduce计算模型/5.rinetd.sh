

### 1. 安装
yum -y install gcc* automake
curl -O http://www.boutell.com/rinetd/http/rinetd.tar.gz
tar -xvf rinetd.tar.gz
cd rinetd
sed -i 's/65536/65535/g' rinetd.c
mkdir /usr/man/
make && make install
# 启动
pkill rinetd && /usr/sbin/rinetd -c /etc/rinetd.conf && ps -ef|grep rinetd

