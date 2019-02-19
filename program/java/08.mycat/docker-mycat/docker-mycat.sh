
# https://github.com/liuwel/docker-mycat

docker-compose up -d mycat m1 s1 s2
docker-compose stop

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

docker exec -it m1 /bin/bash

# 进入m1主服务器mysql, 创建用于主从复制的用户repl
mysql -u root -p m1test
create user repl;
# 给repl用户授予slave的权限
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'172.18.0.%' IDENTIFIED BY 'repl';
# 锁表
## 当退去会话1后，就会自动释放锁,会话2,就可执行
FLUSH TABLES WITH READ LOCK;
# 查看binlog状态 记录File 和 Position 状态稍后从库配置的时候会用
show master status;

# 配置从库s1 s2
## 进入s1 shell
docker exec -it s1 /bin/bash
mysql -uroot -ps1test
change master to master_host='m1',master_port=3306,master_user='repl',master_password='repl',master_log_file='master-bin.000004',master_log_pos=154;
start slave;
## 进入s2 shell
docker exec -it s2 /bin/bash                                                          
mysql -uroot -ps2test
change master to master_host='m1',master_port=3306,master_user='repl',master_password='repl',master_log_file='master-bin.000004',master_log_pos=154;
start slave;

# mysql主从配置完成 现在测试一下
## 登陆主数据库 创建masterdb数据库 (这个数据库名在稍后的mycat里面会用到)
mysql -uroot -pm1test -hm1
create database masterdb;
## 进入从库看看数据库是否创建
mysql -uroot -ps1test -hs1

# 启动mycat
docker-compose up -d mycat
yum install -y mariadb
# 整体测试
mysql -uroot -p_mypassword -P8066 -hlocal
show databases;
use masterdb
CREATE TABLE `test_table` (                                        
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '自增主键',                        
  `title` varchar(255) DEFAULT NULL COMMENT '标题',                             
  `content` text COMMENT '内容',                                                
  PRIMARY KEY (`id`)                                                          
) ENGINE=InnoDB COMMENT='测试表';  
show tables;
INSERT INTO `test_table` VALUES ('1', '测试标题1', '测试内容1'); 
INSERT INTO `test_table` VALUES ('2', '测试标题2', '测试内容2'); 
INSERT INTO `test_table` VALUES ('3', '测试标题3', '测试内容3'); 
INSERT INTO `test_table` VALUES ('4', '测试标题4', '测试内容4'); 
INSERT INTO `test_table` VALUES ('5', '测试标题5', '测试内容5'); 
INSERT INTO `test_table` VALUES ('6', '测试标题6', '测试内容6'); 
select * from test_table; 
