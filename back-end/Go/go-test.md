




* [golang test测试实例 - 轩脉刃 - 博客园](http://www.cnblogs.com/yjf512/archive/2013/01/18/2865915.html)

本文的目的是对mymysql进行单元测试和性能测试
准备工作：
1 go get github.com/ziutek/mymysql/thrsafe
2 在mysql建表和初始化数据（db是test）
12	drop table if exists admin;
CREATE TABLE `admin` (
    `adminid` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `username` varchar(20) NOT NULL DEFAULT '' COMMENT '后台用户名',
    `password` char(32) NOT NULL DEFAULT '' COMMENT '密码,md5存',
    PRIMARY KEY(`adminid`)
)
COMMENT='后台用户信息表'
COLLATE='utf8_general_ci'
ENGINE=InnoDB;
 
insert into admin set adminid=1, username='admin', password='21232f297a57a5a743894a0e4a801fc3';
3 gopath下建立mymysql
 
4 mymysql.go的代码：
```go
package mymysql
import(
     "log"
     "github.com/ziutek/mymysql/mysql"
     _ "github.com/ziutek/mymysql/native"
)
func getAdmin(adminid int) (string, string){
     db := mysql.New("tcp", "", "127.0.0.1:3306", "root", "password", "test")
     err := db.Connect()
     if err != nil {
          panic(err)
     }
     rows, res, err := db.Query("select * from admin where adminid=%d", adminid)
     if err != nil {
          panic(err)
     }
     if len(rows) < 1 {
          log.Panic("rows error")
     }
     row := rows[0]
     first := res.Map("username")
     second := res.Map("password")
     username, password := row.Str(first), row.Str(second)
     return username, password
}
```
很好理解，根据adminid获取用户名和密码
5 mymysql_test.go的代码：
```go
package mymysql
import(
     "testing"
)
func Test_getAdmin(t *testing.T) {
    username, _ := getAdmin(1)
    if (username != "admin") {
         t.Error("getAdmin get data error")
    }
}
```
<br>这里做单元测试的，测试getAdmin函数
写到这里你就可以在命令行中运行go test了
 
这里有个 -v参数，如果不加这个参数的话，只会显示错误的测试用例，否则就显示所有的测试用例（成功 + 错误）

# -bench是可以指定运行的用例

6 下面做性能测试
mymysql_b_test.go的代码：
```go
package mymysql
import (
     "testing"
)
func Benchmark_getAdmin(b *testing.B){
     for i := 0; i < b.N; i++ { //use b.N for looping
            getAdmin(1)
    }
}
```
然后运行 go test -v -bench=".*"
这里的-bench是可以指定运行的用例
 
返回结果表示这个测试用例在1s中内运行了2000次，每次调用大约用了891898ns
7 用性能测试生成CPU状态图
使用命令：
go test -bench=".*" -cpuprofile=cpu.prof -c
cpuprofile是表示生成的cpu profile文件
-c是生成可执行的二进制文件，这个是生成状态图必须的，它会在本目录下生成可执行文件mymysql.test
然后使用go tool pprof工具
go tool pprof mymysql.test cpu.prof
 
调用web（需要安装graphviz）
 
显示svg文件已经生成了
 




Golang UnitTest单元测试(go test) 
| Go语言中文网 | Golang中文社区 | Golang中国
 http://studygolang.com/articles/4708

# Golang UnitTest单元测试

Golang单元测试对文件名和方法名，参数都有很严格的要求。
　　例如：
　　1、文件名必须以xx_test.go命名
　　2、方法必须是Test[^a-z]开头
　　3、方法参数必须 t *testing.T
　　之前就因为第 2 点没有写对，导致找了半天错误。现在真的让人记忆深刻啊，小小的东西当初看书没仔细。
　　下面分享一点go test的参数解读。来源

　　
go test是go语言自带的测试工具，其中包含的是两类，单元测试和性能测试
通过go help test可以看到go test的使用说明：
格式形如：
go test [-c] [-i] [build flags] [packages] [flags for test binary]
参数解读：
-c : 编译go test成为可执行的二进制文件，但是不运行测试。
-i : 安装测试包依赖的package，但是不运行测试。
关于build flags，调用go help build，这些是编译运行过程中需要使用到的参数，一般设置为空
关于packages，调用go help packages，这些是关于包的管理，一般设置为空
关于flags for test binary，调用go help testflag，这些是go test过程中经常使用到的参数
-test.v : 是否输出全部的单元测试用例（不管成功或者失败），默认没有加上，所以只输出失败的单元测试用例。
-test.run pattern: 只跑哪些单元测试用例
-test.bench patten: 只跑那些性能测试用例
-test.benchmem : 是否在性能测试的时候输出内存情况
-test.benchtime t : 性能测试运行的时间，默认是1s
-test.cpuprofile cpu.out : 是否输出cpu性能分析文件
-test.memprofile mem.out : 是否输出内存性能分析文件
-test.blockprofile block.out : 是否输出内部goroutine阻塞的性能分析文件
-test.memprofilerate n : 内存性能分析的时候有一个分配了多少的时候才打点记录的问题。这个参数就是设置打点的内存分配间隔，也就是profile中一个sample代表的内存大小。默认是设置为512 * 1024的。如果你将它设置为1，则每分配一个内存块就会在profile中有个打点，那么生成的profile的sample就会非常多。如果你设置为0，那就是不做打点了。
你可以通过设置memprofilerate=1和GOGC=off来关闭内存回收，并且对每个内存块的分配进行观察。
-test.blockprofilerate n: 基本同上，控制的是goroutine阻塞时候打点的纳秒数。默认不设置就相当于-test.blockprofilerate=1，每一纳秒都打点记录一下
-test.parallel n : 性能测试的程序并行cpu数，默认等于GOMAXPROCS。
-test.timeout t : 如果测试用例运行时间超过t，则抛出panic
-test.cpu 1,2,4 : 程序运行在哪些CPU上面，使用二进制的1所在位代表，和nginx的nginx_worker_cpu_affinity是一个道理
-test.short : 将那些运行时间较长的测试用例运行时间缩短



上实例： 

结果输出： 

本文来自：CSDN博客
感谢作者：samxx8
查看原文：Golang UnitTest单元测试(go test)





