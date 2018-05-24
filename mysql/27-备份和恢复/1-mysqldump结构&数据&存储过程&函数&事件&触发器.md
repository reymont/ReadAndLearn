

MySQL mysqldump 导入/导出 结构&数据&存储过程&函数&事件&触发器 - chevin.net - 博客园 https://www.cnblogs.com/chevin/p/5683281.html

## 库操作

1.①导出一个库结构
mysqldump -d dbname -u root -p > xxx.sql
②导出多个库结构
mysqldump -d -B dbname1 dbname2 -u root -p > xxx.sql
2.①导出一个库数据
mysqldump -t dbname -u root -p > xxx.sql
②导出多个库数据
mysqldump -t -B dbname1 dbname2 -u root -p > xxx.sql
3.①导出一个库结构以及数据
mysqldump dbname1 -u root -p > xxx.sql
②导出多个库结构以及数据
mysqldump -B dbname1 dbname2 -u root -p > xxx.sql
## 表操作
4.①导出一个表结构

mysqldump -d dbname1 tablename1 -u root -p > xxx.sql
②导出多个表结构

mysqldump -d -B dbname1 --tables tablename1 tablename2 -u root -p > xxx.sql
 

5.①导出一个表数据

mysqldump -t dbname1 tablename1 -u root -p > xxx.sql
②导出多个表数据

mysqldump -d -B dbname1 --tables tablename1 tablename2 -u root -p > xxx.sql
 

6.①导出一个表结构以及数据

mysqldump dbname1 tablename1 -u root -p > xxx.sql
②导出多个表结构以及数据

mysqldump -B dbname1 --tables tablename1 tablename2 -u root -p > xxx.sql


## 存储过程&函数操作
7.只导出存储过程和函数(不导出结构和数据，要同时导出结构的话，需要同时使用-d)

mysqldump -R -ndt dbname1 -u root -p > xxx.sql


## 事件操作
8.只导出事件

mysqldump -E -ndt dbname1 -u root -p > xxx.sql


## 触发器操作
9.不导出触发器（触发器是默认导出的–triggers，使用–skip-triggers屏蔽导出触发器）

mysqldump --skip-triggers dbname1 -u root -p > xxx.sql


————————————————————————————————
10.导入

mysql -u root -p
use game;
source xxx.sql


————————————————————————————————
总结一下：

-d 结构(--no-data:不导出任何数据，只导出数据库表结构)
-t 数据(--no-create-info:只导出数据，而不添加CREATE TABLE 语句)
-n (--no-create-db:只导出数据，而不添加CREATE DATABASE 语句）
-R (--routines:导出存储过程以及自定义函数)
-E (--events:导出事件)
--triggers (默认导出触发器，使用--skip-triggers屏蔽导出)
-B (--databases:导出数据库列表，单个库时可省略）
--tables 表列表（单个表时可省略）
①同时导出结构以及数据时可同时省略-d和-t
②同时 不 导出结构和数据可使用-ntd
③只导出存储过程和函数可使用-R -ntd
④导出所有(结构&数据&存储过程&函数&事件&触发器)使用-R -E(相当于①，省略了-d -t;触发器默认导出)
⑤只导出结构&函数&事件&触发器使用 -R -E -d

PS:如果可以使用相关工具，比如官方的MySQL Workbench，则导入导出都是极为方便的，如下图。（当然为了安全性，一般情况下都是屏蔽对外操作权限，所以需要使用命令的情况更多些）

