



```sh
### 用grep结合sed取出网卡的ip地址  
ifconfig | grep -B1 "inet addr" |grep -v "\-\-" |sed -n -e 'N;s/eth[0−9].*\n.*addr:[0−9]{1,3}\.[0−9]{1,3}\.[0−9]{1,3}\.[0−9]{1,3}.*/\1 \2/p'  
```

## 参考

1. https://www.cnblogs.com/ctaixw/p/5860221.html