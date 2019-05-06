yum install  -y strace
strace -cfp $(pidof mysqld)