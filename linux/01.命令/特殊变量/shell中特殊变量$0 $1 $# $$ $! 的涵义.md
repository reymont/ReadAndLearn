

shell中特殊变量$0 $1 $# $$ $! $?的涵义 - CSDN博客 
http://blog.csdn.net/williamwang2013/article/details/8594463

```sh
$0:
执行脚本的名字
$*和$@:
将所有参数返回
$#:
参数的个数
$_:
代表上一个命令的最后一个参数
$$:
代表所在命令的PID
$!:
代表最后执行的后台命令的PID
$?:
代表上一个命令执行是否成功的标志，如果执行成功则$? 为0，否则不为0
```

写个脚本测试下
[wang@localhost 桌面]$ vim test1.sh
```sh
#!/bin/sh
echo "number:$#"
echo "name:$0"
echo "first:$1"
echo "second:$2"
echo "argure1:$@"
ret="$@"
ret1=$@
echo "$ret"
echo "$ret1"
echo "argure2:$*"
echo "arg:$_"
echo "result:$?"
echo "PID:$$"
echo "pid:$!"

[wang@localhost 桌面]$ chmod +x test1.sh 
[wang@localhost 桌面]$ ./test1.sh a b c
number:3
name:./test1.sh
first:a
second:b
argure1:a b c
a b c
a b c
argure2:a b c
arg:argure2:a b c
result:0
PID:14973
pid:
```
[wang@localhost 桌面]$ ./test1.sh "a" "b" "c"
除了PID不一样，其他结果是相同的。

经测试对以下表示怀疑：
$*:
以一对双引号给出参数列表
$@:
将各个参数分别加双引号返回

注意：
$0在shell和awk中的涵义不同。
shell:命令行的第一个单词  awk:当前记录