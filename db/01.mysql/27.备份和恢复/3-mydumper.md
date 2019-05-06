https://github.com/maxbube/mydumper
http://www.cnblogs.com/zhoujinyi/p/6240445.html
https://www.cnblogs.com/zhoujinyi/p/3423641.html
https://blog.csdn.net/zengxuewen2045/article/details/51465099

mydumper -u USER -p PASSWORD -o /home/DESTINATION_DIR/DATABASE/ -B DATABASE
myloader -u USER -p PASSWORD -B DATABASE -d /home/SOURCE_DIR/DATABASE/
https://twindb.com/mydumper-rpm-for-centosrhel/

yum install https://twindb.com/twindb-release-latest.noarch.rpm
yum install mydumper
https://github.com/maxbube/mydumper/blob/master/docs/compiling.rst

yum install glib2-devel mysql-devel zlib-devel pcre-devel cmake -y
git clone https://github.com/maxbube/mydumper.git
cmake .
make
wget https://github.com/maxbube/mydumper/releases/download/v0.9.3/mydumper-0.9.3-41.el7.x86_64.rpm

