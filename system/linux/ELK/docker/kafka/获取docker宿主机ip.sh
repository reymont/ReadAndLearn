
# http://blog.csdn.net/lz7955823/article/details/52804628
alias hostip="ifconfig en0 | grep inet | grep -v inet6 | cut -d ' ' -f2"\
 && docker run --add-host=docker:$(hostip) .....
# 比如运行在docker里运行一个nodejs应用：
alias hostip="ifconfig en0 | grep inet | grep -v inet6 | cut -d ' ' -f2"\
 && docker run --add-host=docker:$(hostip) -p 3001:3000 -v node start.js

ifconfig eth0 | grep inet | grep -v inet6 | cut -d ' ' -f10
host_ips=(`ip addr show |grep inet |grep -v inet6 |grep brd |awk '{print $2}' |cut -f1 -d '/'`)
echo "${host_ips[0]}"