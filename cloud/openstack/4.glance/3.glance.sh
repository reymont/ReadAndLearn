

### 2. 查看配置，忽略注释
# https://www.cnblogs.com/kevingrace/p/5707003.html
cat /etc/glance/glance-api.conf|grep -v "^#"|grep -v "^$"
# 镜像地址
# filesystem_store_datadir = /var/lib/glance/images
cat /etc/glance/glance-registry.conf|grep -v "^#"|grep -v "^$"

### 3. 查询现有的镜像
glance image-list
openstack image list
cd /var/lib/glance/images

### 4. 日志
# 记录 REST API 调用情况
/var/log/glance/api.log
# 记录 Glance 服务处理请求的过程以及数据库操作
/var/log/glance/registry.log


## 参考

1. https://mp.weixin.qq.com/s/QtdMkt9giEEnvFTQzO9u7g
