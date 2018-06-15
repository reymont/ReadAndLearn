<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [Ubuntu 12.04下安装 SQLite及其使用方法](#ubuntu-1204下安装-sqlite及其使用方法)
	* [安装](#安装)
	* [创建数据库](#创建数据库)
	* [查询数据表](#查询数据表)
* [Ubuntu 12.04下安装 SQLite及其使用方法 第2页_数据库技术](#ubuntu-1204下安装-sqlite及其使用方法-第2页_数据库技术)
	* [新建数据库](#新建数据库)
		* [sqlite中命令:](#sqlite中命令)
	* [集合函数](#集合函数)
	* [其他函数](#其他函数)
	* [插入记录](#插入记录)
	* [子查询：](#子查询)
	* [建立索引](#建立索引)
* [Ubuntu 12.04下安装 SQLite及其使用方法](#ubuntu-1204下安装-sqlite及其使用方法-1)

<!-- /code_chunk_output -->


# Ubuntu 12.04下安装 SQLite及其使用方法

* [Ubuntu 12.04下安装 SQLite及其使用方法_数据库技术_Linux公社-Linux系统门户网站 ](http://www.linuxidc.com/Linux/2013-08/89155.htm)

知道学习嵌入式技术，数据库是必须懂的，看的书上嵌入式的教程都在用，看来我是非学不可了，下面就简单的记录一下我在Ubuntu 12.04系统上安装 SQLite 的过程以及使用。
相关阅读：
SQLite3 安装、基本操作 http://www.linuxidc.com/Linux/2012-05/60452.htm
Ubuntu 12.04下SQLite数据库简单应用 http://www.linuxidc.com/Linux/2012-06/63379.htm

## 安装
1、首先建一个文件夹，这里我命名为 sqlite，如下，它的路径为 /home/song/sqlite
2、进入 sqlite 文件夹，执行命令：sudo apt-get install sqlite sqlite3 ，我看着网上都需要安装 sqlite sqlite3，我就纳闷，后者不是前者的升级吗，怎么还需要安装 sqlite，还是不

实验了，先安装上用用再说。
这时候已经安装上了，其实安装也没什么的。
3、执行命令：sqlite -version ，查看 sqlite 的版本
同时，我也执行了：sqlite3 -version ，这不是也有一个版本吗，很明显安装的是两个版本，我在想是不是需要支持一些旧格式的文件，所以把就格式也安装上了呢？
使用


## 创建数据库
4、在该文件夹下，执行命令：sqlite3 test.db ，创建一个名为test.db 的数据库，如下图
5、你可以输入 .help 命令，查看帮助信息。
创建数据表（注意，是数据表，不是数据库了。至少要在数据库中建立一个表或者试图，这样才能将数据库保存在磁盘中，否则数据库不会被创建）
6、现在输入：create table mytable(id,name,age); （注意这里要加分号）我在这里创建了一个名字叫mytabel的数据表，该数据表内定义了三个字段，分别为 id、name、age。
向数据表插入数据
7、执行命令：insert into mytable(id,name,age) values(1,"张三","21");
insert into mytable(id,name,age) values(2,"李四","23");


## 查询数据表
8、执行命令：select * from mytable;
设置格式
9、执行命令：.mode column （注意没有分号），设置为列显示模式
10、执行命令：
退出数据库
11、执行命令：
再次进入数据库
12、执行命令：sqlite3 test.db 打开咱们刚才创建的数据库
查看数据库信息
13、执行命令：.databases 查看数据库信息
查看该数据库内的表信息
14、执行命令：.tables 可以看到该数据库内有一个表文件
15、执行命令：sudo apt-get install sqlitebrowser 安装可视化工具
16、执行命令：sqlitebrowser test.db ，可以看到咱们的数据库了
Sqlite 貌似还有很多命令，我先将它贴出来 见 http://www.linuxidc.com/Linux/2013-08/89155p2.htm


# Ubuntu 12.04下安装 SQLite及其使用方法 第2页_数据库技术
* [Ubuntu 12.04下安装 SQLite及其使用方法 第2页_数据库技术_Linux公社-Linux系统门户网站 ](http://www.linuxidc.com/Linux/2013-08/89155p2.htm)
sqlite数据库只用一个文件就ok，小巧方便，所以是一个非常不错的嵌入式数据库，SQLite大量的被用于手机，PDA，MP3播放器以及机顶盒设备。
    Mozilla Firefox使用SQLite作为数据库。
    Mac计算机中的包含了多份SQLite的拷贝，用于不同的应用。
    PHP将SQLite作为内置的数据库。
    Skype客户端软件在内部使用SQLite。
    SymbianOS(智能手机操作平台的领航)内置SQLite。
    AOL邮件客户端绑定了SQLite。
    Solaris 10在启动过程中需要使用SQLite。
    McAfee杀毒软件使用SQLite。
    iPhones使用SQLite。
    Symbian和Apple以外的很多手机生产厂商使用SQLite。
下面就sqlite中的常用命令和语法介绍
http://www.sqlite.org/download.html可下载不同操作系统的相关版本sqlite  gedit
也可以使用火狐中的插件sqlite manager 

## 新建数据库
sqlite3 databasefilename
检查databasefilename是否存在，如果不存在就创建并进入数据库（如果直接退出，数据库文件不会创建）  如果已经存在直接进入数据库 对数据库进行操作


### sqlite中命令:
以.开头,大小写敏感（数据库对象名称是大小写不敏感的）
.exit
.help 查看帮助 针对命令
.database 显示数据库信息；包含当前数据库的位置
.tables 或者 .table 显示表名称  没有表则不显示
.schema 命令可以查看创建数据对象时的SQL命令；
.schema databaseobjectname查看创建该数据库对象时的SQL的命令；如果没有这个数据库对象就不显示内容，不会有错误提示
.read FILENAME 执行指定文件中的SQL语句
.headers on/off  显示表头 默认off
.mode list|column|insert|line|tabs|tcl|csv  改变输出格式，具体如下
sqlite> .mode list
sqlite> select * from emp;
7369|SMITH|CLERK|7902|17-12-1980|800||20
7499|ALLEN|SALESMAN|7698|20-02-1981|1600|300|30
如果字段值为NULL 默认不显示 也就是显示空字符串
sqlite> .mode column
sqlite> select * from emp;
7369        SMITH      CLERK      7902        17-12-1980  800                    20        
7499        ALLEN      SALESMAN    7698        20-02-1981  1600        300        30        
7521        WARD        SALESMAN    7698        22-02-1981  1250        500        30
sqlite> .mode insert
sqlite> select * from dept;
INSERT INTO table VALUES(10,'ACCOUNTING','NEW YORK');
INSERT INTO table VALUES(20,'RESEARCH','DALLAS');
INSERT INTO table VALUES(30,'SALES','CHICAGO');
INSERT INTO table VALUES(40,'OPERATIONS','BOSTON');
sqlite> .mode line
sqlite> select * from dept;
DEPTNO = 10
 DNAME = ACCOUNTING
  LOC = NEW YORK
DEPTNO = 20
 DNAME = RESEARCH
  LOC = DALLAS
DEPTNO = 30
 DNAME = SALES
  LOC = CHICAGO
DEPTNO = 40
 DNAME = OPERATIONS
  LOC = BOSTON
sqlite> .mode tabs
sqlite> select * from dept;
10 ACCOUNTING  NEW YORK
20 RESEARCH  DALLAS
30 SALES  CHICAGO
40 OPERATIONS  BOSTON
sqlite> .mode tcl
sqlite> select * from dept;
"10" "ACCOUNTING""NEW YORK"
"20" "RESEARCH""DALLAS"
"30" "SALES"  "CHICAGO" 
"40" "OPERATIONS""BOSTON"
sqlite> .mode csv
sqlite> select * from dept;
10,ACCOUNTING,"NEW YORK"
20,RESEARCH,DALLAS
30,SALES,CHICAGO
40,OPERATIONS,BOSTON
.separator "X" 更改分界符号为X
sqlite> .separator '**'  
sqlite> select * from dept;
10**ACCOUNTING**"NEW YORK"
20**RESEARCH**DALLAS
30**SALES**CHICAGO
40**OPERATIONS**BOSTON
.dump ?TABLE?            生成形成数据库表的SQL脚本
.dump 生成整个数据库的脚本在终端显示
.output stdout          将输出打印到屏幕  默认
.output filename  将输出打印到文件（.dump  .output 结合可将数据库以sql语句的形式导出到文件中）
.nullvalue STRING        查询时用指定的串代替输出的NULL串 默认为.nullvalue ''
字段类型：
数据库中存储的每个值都有一个类型,都属于下面所列类型中的一种,(被数据库引擎所控制)
NULL: 这个值为空值
INTEGER: 值被标识为整数,依据值的大小可以依次被存储为1,2,3,4,5,6,7,8个字节
REAL: 所有值都是浮动的数值,被存储为8字节的IEEE浮动标记序号.
TEXT: 文本. 值为文本字符串,使用数据库编码存储(TUTF-8, UTF-16BE or UTF-16-LE).
BLOB: 值是BLOB数据,如何输入就如何存储,不改变格式.
值被定义为什么类型只和值自身有关,和列没有关系,和变量也没有关系.所以sqlite被称作 弱类型 数据库
数据库引擎将在执行时检查、解析类型，并进行数字存储类型(整数和实数)和文本类型之间的转换.
SQL语句中部分的带双引号或单引号的文字被定义为文本,
如果文字没带引号并没有小数点或指数则被定义为整数,
如果文字没带引号但有小数点或指数则被定义为实数, 
如果值是空则被定义为空值.
BLOB数据使用符号X'ABCD'来标识.
但实际上，sqlite3也接受如下的数据类型： 
smallint 16位的整数。 
interger 32位的整数。 
decimal(p,s) 精确值p是指全部有几个十进制数,s是指小数点后可以有几位小数。如果没有特别指定，则系统会默认为p=5 s=0 。 
float  32位元的实数。 
double  64位元的实数。 
char(n)  n 长度的字串，n不能超过 254。 
varchar(n) 长度不固定且其最大长度为 n 的字串，n不能超过 4000。 
graphic(n) 和 char(n) 一样，不过其单位是两个字节， n不能超过127。这个形态是为了支持两个字节长度的字体，如中文字。
vargraphic(n) 可变长度且其最大长度为n的双字元字串，n不能超过2000 
date  包含了 年份、月份、日期。 
time  包含了 小时、分钟、秒。 
timestamp 包含了 年、月、日、时、分、秒、千分之一秒。
SQLite包含了如下时间/日期函数： 
datetime() 产生日期和时间    无参数表示获得当前时间和日期
sqlite> select datetime();
2012-01-07 12:01:32
有字符串参数则把字符串转换成日期
sqlite> select datetime('2012-01-07 12:01:30'); 
2012-01-07 12:01:30
select date('2012-01-08','+1 day','+1 year');
2013-01-09
select datetime('2012-01-08 00:20:00','+1 hour','-12 minute');
2012-01-08 01:08:00
select datetime('now','start of year');
2012-01-01 00:00:00
select datetime('now','start of month');
2012-01-01 00:00:00
select datetime('now','start of day');
2012-01-08 00:00:00
select datetime('now','start of week');错误
select datetime('now','localtime');
结果：2006-10-17 21:21:47
date()产生日期    
sqlite> select date('2012-01-07 12:01:30'); 
2012-01-07
同理 有参和无参
select date('now','start of year');
2012-01-01
select date('2012-01-08','+1 month');
2012-02-08
time() 产生时间 
select time();
03:14:30
select time('23:18:59');
23:18:59
select time('23:18:59','start of day');
00:00:00
select time('23:18:59','end of day');错误
在时间/日期函数里可以使用如下格式的字符串作为参数： 
YYYY-MM-DD 
YYYY-MM-DD HH:MM 
YYYY-MM-DD HH:MM:SS 
YYYY-MM-DD HH:MM:SS.SSS 
HH:MM 
HH:MM:SS 
HH:MM:SS.SSS 
now 
其中now是产生现在的时间。
日期不能正确比较大小,会按字符串比较，日期默认格式 dd-mm-yyyy
select hiredate from emp order by hiredate;
17-11-1981
17-12-1980
19-04-1987
20-02-1981
22-02-1981
strftime() 对以上三个函数产生的日期和时间进行格式化
strftime()函数可以把YYYY-MM-DD HH:MM:SS格式的日期字符串转换成其它形式的字符串。 strftime(格式, 日期/时间, 修正符, 修正符, …)  select strftime('%d',datetime());
它可以用以下的符号对日期和时间进行格式化： 
%d 在该月中的第几天, 01-31 
%f 小数形式的秒，SS.SSS 
%H 小时, 00-23 
%j 算出某一天是该年的第几天，001-366 
%m 月份，00-12 
%M 分钟, 00-59 
%s 从1970年1月1日到现在的秒数 
%S 秒, 00-59 
%w 星期, 0-6 (0是星期天) 
%W 算出某一天属于该年的第几周, 01-53 
%Y 年, YYYY 
%% 百分号
select strftime('%Y.%m.%d %H:%M:%S','now'); 
select strftime('%Y.%m.%d %H:%M:%S','now','localtime'); 
结果：2006.10.17 21:41:09
select hiredate from emp 
order by strftime('%Y.%m.%d %H:%M:%S',hiredate); 正确
select strftime('%Y.%m.%d %H:%M:%S',hiredate) from emp 
order by strftime('%Y.%m.%d %H:%M:%S',hiredate); 错误
算术函数 
abs(X) 返回给定数字表达式的绝对值。 
max(X,Y[,...]) 返回表达式的最大值。  组函数 max(列名)
sqlite> select max(2,3,4,5,6,7,12);
12
min(X,Y[,...]) 返回表达式的最小值。 
random() 返回随机数。
sqlite> select random();
3224224213599993831
round(X[,Y]) 返回数字表达式并四舍五入为指定的长度或精度。
字符处理函数 
length(X) 返回给定字符串表达式的字符个数。 
lower(X) 将大写字符数据转换为小写字符数据后返回字符表达式。 
upper(X) 返回将小写字符数据转换为大写的字符表达式。 
substr(X,Y,Z) 返回表达式的一部分。  从Y开始读Z个字符  Y最小值1
sqlite> select substr('abcdef',3,3);            
cde
quote(A) 给字符串加引号
 sqlite> select quote('aaa');
'aaa'
条件判断函数 
ifnull(X,Y)  如果X为null 返回Y
select ifnull(comm,0) from emp;
0
300
500
0
1400


## 集合函数 
avg(X) 返回组中值的平均值。 
count(X) 返回组中项目的数量。 
max(X) 返回组中值的最大值。 
min(X) 返回组中值的最小值。 
sum(X) 返回表达式中所有值的和。

## 其他函数 
typeof(X) 返回数据的类型。 
sqlite> select typeof(111);
integer
sqlite> select typeof('233');
text
sqlite> select typeof('2012-12-12');
text
sqlite> select typeof('223.44');
text
sqlite> select typeof(223.44);
real
last_insert_rowid() 返回最后插入的数据的ID。 
sqlite_version() 返回SQLite的版本。 
sqlite> select sqlite_version();
3.7.9
change_count() 返回受上一语句影响的行数。 
last_statement_change_count()
create table emp_bak select * from EMP;不能在sqlite中使用

## 插入记录
insert into table_name values (field1, field2, field3...);
查询
select * from table_name;查看table_name表中所有记录；
select * from table_name where field1='xxxxx'; 查询符合指定条件的记录；
select ..... 
from table_name[,table_name2,...]
where ..... 
group by.... 
having .... 
order by ...
select ..... 
from table_name  inner join | left outer join | right outer join table_name2
on ...
where ..... 
group by.... 
having .... 
order by ...


## 子查询：
select * 
from EMP m
where SAL>
(select avg(SAL) from EMP where DEPTNO=m.DEPTNO); 
支持case when then 语法
update EMP
set SAL=
(
case
when DEPTNO=10 and JOB='MANAGER' then SAL*1.1
when DEPTNO=20 and JOB='CLERK' then SAL*1.2
when DEPTNO=30  then SAL*1.1
when DEPTNO=40  then SAL*1.2
else SAL
END
);
select ENAME, 
case DEPTNO
when 10 then '后勤部'
when 20 then '财务部'
when 30 then '内务部门'
else '其他部门'
end as dept
from EMP;
支持关联子查询  in后面的语法中可以有limit（mysql不可以）
select *
from emp e
where e.EMPNO in 
(
select empno  
from EMP
where deptno=e.DEPTNO
order by SAL desc
limit 0,2
);
支持表和表之间的数据合并等操作
union 去重复  union all 不去掉重复
select deptno from emp
union 
select deptno from dept;
select deptno from emp
union all
select deptno from dept;
在列名前加distinct也是去重复
sqlite> select distinct deptno from emp;
删除
delete from table_name where ...
删除表
drop table_name;    删除表；
drop index_name;    删除索引；
修改
update table_name
set xxx=value[, xxx=value,...]
where ...

## 建立索引
如果资料表有相当多的资料，我们便会建立索引来加快速度。好比说：
create index film_title_index on film(title);
意思是针对film资料表的name字段，建立一个名叫film_name_index的索引。这个指令的语法为
CREATE [ UNIQUE ]  NONCLUSTERED  INDEX index_name
    ON { table | view } ( column [ ASC | DESC ] [ ,...n ] )
create index index_name on table_name(field_to_be_indexed);
一旦建立了索引，sqlite3会在针对该字段作查询时，自动使用该索引。这一切的操作都是在幕后自动发生的，无须使用者特别指令。
其他sqlite的特别用法
sqlite可以在shell底下直接执行命令：
sqlite3 film.db "select * from emp;"
输出 HTML 表格：
sqlite3 -html film.db "select * from film;"
将数据库「倒出来」：
sqlite3 film.db ".dump" > output.sql
利用输出的资料，建立一个一模一样的数据库（加上以上指令，就是标准的SQL数据库备份了）：
sqlite3 film.db < output.sql
在大量插入资料时，你可能会需要先打这个指令：
begin;
插入完资料后要记得打这个指令，资料才会写进数据库中：
commit;
sqlite> begin;
sqlite> insert into aaaa values('aaa','333');
sqlite> select * from aaaa;
2|sdfds
sdfsd|9
2012-12-12|13:13:13
aaa|333
sqlite> rollback;
sqlite> select * from aaaa;
2|sdfds
sdfsd|9
2012-12-12|13:13:13
创建和删除视图
CREATE VIEW view_name AS
SELECT column_name(s)
FROM table_name
WHERE condition
DROP VIEW view_name
create view  e as
select avg(SAL) avgsal,DEPTNO
from EMP
group by DEPTNO;
select ENAME,EMP.DEPTNO,SAL,avgsal
from EMP inner join e
on EMP.DEPTNO=e.DEPTNO
where SAL>avgsal;
练习员工表：
PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE DEPT
(
DEPTNO int(2) not null,
DNAME varchar(14),
LOC    varchar(13)
);
INSERT INTO "DEPT" VALUES(10,'ACCOUNTING','NEW YORK');
INSERT INTO "DEPT" VALUES(20,'RESEARCH','DALLAS');
INSERT INTO "DEPT" VALUES(30,'SALES','CHICAGO');
INSERT INTO "DEPT" VALUES(40,'OPERATIONS','BOSTON');
CREATE TABLE EMP
(
EMPNO    int(4) not null,
ENAME    varchar(10),
JOB      varchar(9),
MGR      int(4),
HIREDATE date,
SAL      int(7 ),
COMM    int(7 ),
DEPTNO  int(2)
);
INSERT INTO "EMP" VALUES(7369,'SMITH','CLERK',7902,'17-12-1980',800,NULL,20);
INSERT INTO "EMP" VALUES(7499,'ALLEN','SALESMAN',7698,'20-02-1981',1600,300,30);
INSERT INTO "EMP" VALUES(7521,'WARD','SALESMAN',7698,'22-02-1981',1250,500,30);
INSERT INTO "EMP" VALUES(7566,'JONES','MANAGER',7839,'02-04-1981',2975,NULL,20);
INSERT INTO "EMP" VALUES(7654,'MARTIN','SALESMAN',7698,'28-09-1981',1250,1400,30);
INSERT INTO "EMP" VALUES(7698,'BLAKE','MANAGER',7839,'01-05-1981',2850,NULL,30);
INSERT INTO "EMP" VALUES(7782,'CLARK','MANAGER',7839,'09-06-1981',2450,NULL,10);
INSERT INTO "EMP" VALUES(7788,'SCOTT','ANALYST',7566,'19-04-1987',3000,NULL,20);
INSERT INTO "EMP" VALUES(7839,'KING','PRESIDENT',NULL,'17-11-1981',5000,NULL,10);
INSERT INTO "EMP" VALUES(7844,'TURNER','SALESMAN',7698,'08-09-1981',1500,0,30);
INSERT INTO "EMP" VALUES(7876,'ADAMS','CLERK',7788,'23-05-1987',1100,NULL,20);
INSERT INTO "EMP" VALUES(7900,'JAMES','CLERK',7698,'03-12-1981',950,NULL,30);
INSERT INTO "EMP" VALUES(7902,'FORD','ANALYST',7566,'03-12-1981',3000,NULL,20);
INSERT INTO "EMP" VALUES(7934,'MILLER','CLERK',7782,'23-01-1982',1300,NULL,10);
CREATE TABLE SALGRADE
(
GRADE int,
LOSAL int,
HISAL int
);
INSERT INTO "SALGRADE" VALUES(1,700,1200);
INSERT INTO "SALGRADE" VALUES(2,1201,1400);
INSERT INTO "SALGRADE" VALUES(3,1401,2000);
INSERT INTO "SALGRADE" VALUES(4,2001,3000);
INSERT INTO "SALGRADE" VALUES(5,3001,9999);
COMMIT;
# Ubuntu 12.04下安装 SQLite及其使用方法
* [Ubuntu 12.04下安装 SQLite及其使用方法 第3页_数据库技术_Linux公社-Linux系统门户网站 ](http://www.linuxidc.com/Linux/2013-08/89155p3.htm)
一些有用的 SQLite 命令
显示表结构：
sqlite> .schema [table]
获取所有表和视图： 
sqlite > .tables
获取指定表的索引列表：
sqlite > .indices [table ]
导出数据库到 SQL 文件： 
sqlite > .output [filename ] 
sqlite > .dump 
sqlite > .output stdout
从 SQL 文件导入数据库： 
sqlite > .read [filename ]
格式化输出数据到 CSV 格式： 
sqlite >.output [filename.csv ] 
sqlite >.separator , 
sqlite > select * from test; 
sqlite >.output stdout
从 CSV 文件导入数据到表中： 
sqlite >create table newtable ( id integer primary key, value text ); 
sqlite >.import [filename.csv ] newtable
备份数据库：
/* usage: sqlite3 [database] .dump > [filename] */
sqlite3 mytable.db .dump > backup.sql
恢复数据库： 
/* usage: sqlite3 [database ] < [filename ] */ 
sqlite3 mytable.db < backup.sql