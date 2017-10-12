

#镜像目录
/data/registry2/docker/registry/v2/repositories
#删除dev
rm -rf dev
#执行垃圾回收操作，注意2.4版本以上的registry才有此功能
docker exec registry bin/registry garbage-collect /etc/docker/registry/config.yml