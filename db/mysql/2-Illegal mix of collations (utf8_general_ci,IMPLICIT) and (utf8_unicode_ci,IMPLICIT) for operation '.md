https://blog.csdn.net/xsl_1126571587/article/details/49473061

今天在mysql中进行字符串比较时提示：

 Illegal mix of collations (utf8_general_ci,IMPLICIT) and (utf8_unicode_ci,IMPLICIT) for operation '='

创建数据库时选择的COLLATION 是用在排序，大小比较上。一个字符集有一个或多种collation，并且以_ci（大小写不敏感）、_cs（大小写敏感）或_bin（二元）结束。在做比较时，应该确保两个表的字符排序相同。一般建表的时候不指定，可以走默认的，全是默认的就没什么问题了。


解决方法：
只要修改一下表的字符集就可以了，如下：

ALTER TABLE users CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;


1.列出MYSQL支持的所有字符集：

SHOW CHARACTER SET;

2.当前MYSQL服务器字符集设置

SHOW VARIABLES LIKE 'character_set_%';

3.当前MYSQL服务器字符集校验设置

SHOW VARIABLES LIKE 'collation_%';

4.显示某数据库字符集设置

show create database 数据库名;

5.显示某数据表字符集设置

show create table 表名;

6.修改数据库字符集

alter database 数据库名default character set 'utf8';

7.修改数据表字符集

alter table 表名default character set 'utf8';

8.建库时指定字符集

create database 数据库名character set gbk collate gbk_chinese_ci;

9.建表时指定字符集

CREATE TABLE `mysqlcode` (

`id` TINYINT( 255 ) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY ,

`content` VARCHAR( 255 ) NOT NULL

) TYPE = MYISAM CHARACTER SET gbk COLLATE gbk_chinese_ci;