

# 安装

通过`cloudos-registry.yaml`方式安装



> docker login docker.ob.local

# 镜像仓库

镜像仓库地址：https://console.cloudos.yihecloud.com/registry
admin/password
liyang/123456

192.168.31.211
root/admin123

# registry

> vi /etc/docker/daemon.json
> /etc/dnsmasq.conf

> /etc/resolv.dnsmasq.conf
nameserver 114.114.114.114

curl -O https://dl.cloudos.yihecloud.com/release/registry2-pause-3.0.tar 2>&1
docker load < registry2-pause-3.0.tar
docker tag registry.service.ob.local:5000/google_containers/pause-amd64:3.0 image.service.ob.local:5000/google_containers/pause-amd64:3.0

```sh
#查询出所有镜像
http://192.168.0.142:5000/v2/_catalog
http://192.168.31.240:5000/v2/_catalog
curl http://127.0.0.1:5000/v2/_catalog|python -mjson.tool
#列出镜像tags
http://192.168.0.142:5000/v2/calico/cni/tags/list
http://192.168.0.142:5000/v2/prom/prometheus/tags/list
```



# 访问

* [Docker私有仓库Registry的搭建验证 - lienhua34 - 博客园 ](http://www.cnblogs.com/lienhua34/p/4922130.html)

插件镜像

https://dl.cloudos.yihecloud.com/release/

* [HTTP API V2 | Docker Documentation ](https://docs.docker.com/registry/spec/api/#pulling-an-image)



