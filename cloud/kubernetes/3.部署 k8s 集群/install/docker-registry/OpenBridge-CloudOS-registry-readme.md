


# OpenBridge-CloudOS-registry

* [OpenBridge-CloudOS-registry/README.md at develop - PaaS / OpenBridge-CloudOS-registry | GitLab ](http://git.yihecloud.com/PaaS/OpenBridge-CloudOS-registry/blob/develop/README.md)



# 构建之前先下载仓库程序
```
wget https://github.com/docker/distribution-library-image/raw/master/registry/registry
```

# 生产密钥对
```
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out root.crt -days 18000 -nodes
```
# 转化私钥格式 for java
openssl pkcs8 -topk8 -inform PEM -outform DER -in key.pem -out root.der -nocrypt

# 测试启动
```
#!/bin/bash

docker run -d -p 5000:5000 -p 8080:8080  --restart=always --name testreg\
    -v /data/registry:/var/lib/registry \
    -v /home/yong/test/registry.yaml:/program/registry.yaml \
    -v /home/yong/test/config.json:/program/config.json \
    docker.cloudos.yihecloud.com/cloudos/registry:5.0_20170718134704

```