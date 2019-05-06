
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [MySQL数据导出与导入](#mysql数据导出与导入)
	* [应用举例](#应用举例)
		* [导出](#导出)
		* [导入](#导入)
			* [恢复全库数据到MySQL,因为包含mysql库的权限表,导入完成需要执行FLUSH PRIVILEGES;命令](#恢复全库数据到mysql因为包含mysql库的权限表导入完成需要执行flush-privileges命令)
			* [恢复某个库的数据(mysql库的user表)](#恢复某个库的数据mysql库的user表)
			* [恢复MySQL服务器上面的txt格式文件(需要FILE权限,各数据值之间用"制表符"分隔)](#恢复mysql服务器上面的txt格式文件需要file权限各数据值之间用制表符分隔)
			* [恢复本地的txt或csv文件到MySQL](#恢复本地的txt或csv文件到mysql)
	* [注意事项](#注意事项)

<!-- /code_chunk_output -->
---

# MySQL数据导出与导入

* [MySQL数据导出与导入-ning_lianjie-ChinaUnix博客 ](http://blog.chinaunix.net/uid-16844903-id-3411118.html)



发一篇基础的,关于MySQL数据导出导入的文章,目的有二:

1.备忘
2.供开发人员测试
工具

mysql
mysqldump

## 应用举例

### 导出
导出全库备份到本地的目录
mysqldump -u$USER -p$PASSWD -h127.0.0.1 -P3306 --routines --default-character-set=utf8 --lock-all-tables --add-drop-database -A > db.all.sql

导出指定库到本地的目录(例如mysql库)
mysqldump -u$USER -p$PASSWD -h127.0.0.1 -P3306 --routines --default-character-set=utf8 --databases mysql > db.sql

导出某个库的表到本地的目录(例如mysql库的user表)
mysqldump -u$USER -p$PASSWD -h127.0.0.1 -P3306 --routines --default-character-set=utf8 --tables mysql user> db.table.sql

导出指定库的表(仅数据)到本地的目录(例如mysql库的user表,带过滤条件)
mysqldump -u$USER -p$PASSWD -h127.0.0.1 -P3306 --routines --default-character-set=utf8 --no-create-db --no-create-info --tables mysql user --where="host='localhost'"> db.table.sql

导出某个库的所有表结构
mysqldump -u$USER -p$PASSWD -h127.0.0.1 -P3306 --routines --default-character-set=utf8 --no-data --databases mysql > db.nodata.sql

导出某个查询sql的数据为txt格式文件到本地的目录(各数据值之间用"制表符"分隔)
例如sql为'select user,host,password from mysql.user;'
mysql -u$USER -p$PASSWD -h127.0.0.1 -P3306 --default-character-set=utf8 --skip-column-names -B -e 'select user,host,password from mysql.user;' > mysql_user.txt

导出某个查询sql的数据为txt格式文件到MySQL服务器.
登录MySQL,将默认的制表符换成逗号.(适应csv格式文件).
指定的路径,mysql要有写的权限.最好用tmp目录,文件用完之后,再删除!
SELECT user,host,password FROM mysql.user INTO OUTFILE '/tmp/mysql_user.csv' FIELDS TERMINATED BY ',';

### 导入

#### 恢复全库数据到MySQL,因为包含mysql库的权限表,导入完成需要执行FLUSH PRIVILEGES;命令
```sh
第一种方法:
mysql -u$USER -p$PASSWD -h127.0.0.1 -P3306 --default-character-set=utf8 < db.all.sql

第二种方法:
登录MySQL,执行source命令,后面的文件名要用绝对路径.
......
mysql> source /tmp/db.a-ll.sql;
```

#### 恢复某个库的数据(mysql库的user表)
```sh
第一种方法:
mysql -u$USER -p$PASSWD -h127.0.0.1 -P3306 --default-character-set=utf8 mysql < db.table.sql

第二种方法:
登录MySQL,执行source命令,后面的文件名要用绝对路径.
mysql -u$USER -p$PASSWD -h127.0.0.1 -P3306 --default-character-set=utf8
......
mysql> use mysql;
mysql> source /tmp/db.table.sql;
```

#### 恢复MySQL服务器上面的txt格式文件(需要FILE权限,各数据值之间用"制表符"分隔)
mysql -u$USER -p$PASSWD -h127.0.0.1 -P3306 --default-character-set=utf8
......
mysql> use mysql;
mysql> LOAD DATA INFILE '/tmp/mysql_user.txt' INTO TABLE user ;
恢复MySQL服务器上面的csv格式文件(需要FILE权限,各数据值之间用"逗号"分隔)
mysql -u$USER -p$PASSWD -h127.0.0.1 -P3306 --default-character-set=utf8
......
mysql> use mysql;
mysql> LOAD DATA INFILE '/tmp/mysql_user.csv' INTO TABLE user FIELDS TERMINATED BY ',';

#### 恢复本地的txt或csv文件到MySQL
```sh
mysql -u$USER -p$PASSWD -h127.0.0.1 -P3306 --default-character-set=utf8
......
mysql> use mysql;
# txt
mysql> LOAD DATA LOCAL INFILE '/tmp/mysql_user.csv' INTO TABLE user;
# csv
mysql> LOAD DATA LOCAL INFILE '/tmp/mysql_user.csv' INTO TABLE user FIELDS TERMINATED BY ',';
```
## 注意事项

关于MySQL连接
-u$USER 用户名
-p$PASSWD 密码
-h127.0.0.1 如果连接远程服务器,请用对应的主机名或者IP地址替换
-P3306 端口
--default-character-set=utf8 指定字符集
关于mysql参数
--skip-column-names 不显示数据列的名字
-B 以批处理的方式运行mysql程序.查询结果将显示为制表符间隔格式.
-e 执行命令后,退出
关于mysqldump参数
-A 全库备份
--routines 备份存储过程和函数
--default-character-set=utf8 设置字符集
--lock-all-tables 全局一致性锁
--add-drop-database 在每次执行建表语句之前,先执行DROP TABLE IF EXIST语句
--no-create-db 不输出CREATE DATABASE语句
--no-create-info 不输出CREATE TABLE语句
--databases 将后面的参数都解析为库名
--tables 第一个参数为库名 后续为表名
关于LOAD DATA语法
如果LOAD DATA语句不带LOCAL关键字,就在MySQL的服务器上直接读取文件,且要具有FILE权限.
如果带LOCAL关键字,就在客户端本地读取数据文件,通过网络传到MySQL.
LOAD DATA语句,同样被记录到binlog,不过是内部的机制.
