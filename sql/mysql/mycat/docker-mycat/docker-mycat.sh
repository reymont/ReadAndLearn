

# 修改hosts文件 添加解析
```
% sudo vi /etc/hosts
# docker-mycat m1:mysql-master主服务器 s1,s2：mysql-slave 从服务器
# mycat mycat中间件服务器
172.18.0.2      m1
172.18.0.3      s1
172.18.0.4      s2
172.18.0.5      mycat
127.0.0.1       local
```
docker-machine ssh
eval $(docker-machine env)
# Build 镜像
docker-compose build m1 s1 s2
# 运行 docker mysql主从数据库 (mysql数据库密码在yml文件里面)
docker-compose up -d m1 s1 s2 