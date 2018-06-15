

* [Linux Shell函数返回值 - IT-Homer - CSDN博客 ](http://blog.csdn.net/ithomer/article/details/7954577)


Shell函数返回值，一般有3种方式：return，argv，echo

# return
shell函数的返回值，可以和其他语言的返回值一样，通过return语句返回。
示例：

```sh
#!/bin/bash -  
function mytest()  
{  
    echo "arg1 = $1"  
    if [ $1 = "1" ] ;then  
        return 1  
    else  
        return 0  
    fi  
}  
  
echo   
echo "mytest 1"  
mytest 1  
echo $?         # print return result  
  
echo   
echo "mytest 0"  
mytest 0  
echo $?         # print return result  
  
echo   
echo "mytest 2"  
mytest 2  
echo $?         # print return result  
  
  
echo  
echo "mytest 1 = "`mytest 1`  
if  mytest 1 ; then  
    echo "mytest 1"  
fi  
  
echo  
echo "mytest 0 = "`mytest 0`  
if  mytest 0 ; then  
    echo "mytest 0"  
fi  
  
echo  
echo "if fasle" # if 0 is error  
if false; then  
    echo "mytest 0"  
fi  
  
  
echo  
mytest 1  
res=`echo $?`   # get return result  
if [ $res = "1" ]; then  
    echo "mytest 1"  
fi  
  
echo  
mytest 0  
res=`echo $?`   # get return result  
if [ $res = "0" ]; then  
    echo "mytest 0"  
fi  
  
  
  
echo   
echo "end"  
```

结果：
mytest 1
arg1 = 1
1

mytest 0
arg1 = 0
0

mytest 2
arg1 = 2
0

mytest 1 = arg1 = 1
arg1 = 1

mytest 0 = arg1 = 0
arg1 = 0
mytest 0

if fasle

arg1 = 1
mytest 1

arg1 = 0
mytest 0

end
先定义了一个函数mytest，根据它输入的参数是否为1来return 1或者return 0.
获取函数的返回值通过调用函数，或者最后执行的值获得。
另外，可以直接用函数的返回值用作if的判断。
注意：return只能用来返回整数值，且和c的区别是返回为正确，其他的值为错误。


# argv

这种就类似于C语言中的全局变量（或环境变量）。

```sh
#!/bin/bash -  
  
g_var=  
function mytest2()  
{  
    echo "mytest2"  
    echo "args $1"  
    g_var=$1  
  
    return 0  
}  
  
mytest2 1  
echo "return $?"  
  
echo  
echo "g_var=$g_var"  
```

结果：
mytest2
args 1
return 0

g_var=1

函数mytest2通过修改全局变量的值，来返回结果。

注： 以上两个方法失效的时候
以上介绍的这两种方法在一般情况下都是好使的，但也有例外。
示例：

```sh
#!/bin/bash -  
  
  
function mytest3()  
{  
    grep "123" test.txt | awk -F: '{print $2}' | while read line ;do  
        echo "$line"  
        if [ $line = "yxb" ]; then  
            return 0    # return to pipe only  
        fi  
    done  
  
    echo "mytest3 here "  
    return 1            # return to main process  
}  
  
g_var=  
function mytest4()  
{  
    grep "123" test.txt | awk -F: '{print $2}' | while read line ;do  
        echo "$line"  
        if [ $line = "yxb" ]; then  
            g_var=0  
            echo "g_var=0"  
            return 0    # return to pipe only  
        fi  
    done  
  
    echo "mytest4 here "  
    return 1  
}  
  
mytest3  
echo $?  
  
echo  
mytest4  
echo $?  
  
echo  
echo "g_var=$g_var"  
```

其中，test.txt 文件中的内容如下：
456:kkk
123:yxb
123:test
结果：
yxb
mytest3 here 
1

yxb
g_var=0
mytest4 here 
1

g_var=
可以看到mytest3在return了以后其实没有直接返回，而是执行了循环体后的语句，同时看到mytest4中也是一样，同时，在mytest4中，对全局变量的修改也无济于事，全局变量的值根本就没有改变。这个是什么原因那？
笔者认为，之所以return语句没有直接返回，是因为return语句是在管道中执行的，管道其实是另一个子进程，而return只是从子进程中返回而已，只是while语句结束了。而函数体之后的语句会继续执行。
同理，全局变量在子进程中进行了修改，但是子进程的修改没有办法反应到父进程中，全局变量只是作为一个环境变量传入子进程，子进程修改自己的环境变量，不会影响到父进程。
因此在写shell函数的时候，用到管道（cmd &后台进程也一样）的时候一定要清楚此刻是从什么地方返回。

# echo

其实在shell中，函数的返回值有一个非常安全的返回方式，即通过输出到标准输出返回。因为子进程会继承父进程的标准输出，因此，子进程的输出也就直接反应到父进程。因此不存在上面提到的由于管道导致返回值失效的情况。
在外边只需要获取函数的返回值即可。

```sh
#!/bin/bash 

##############################################
# Author : IT-Homer
# Date   : 2012-09-06 
# Blog   : http://blog.csdn.net/sunboy_2050
##############################################

function mytest5()
{
    grep "123" test.txt | awk -F: '{print $2}' | while read line; do
        if [ $line = "yxb" ]; then
            echo "0"    # value returned first by this function
            return 0
        fi
    done

    return 1
}

echo '$? = '"$?"
result=$(mytest5)

echo "result = $result"

echo
if [ -z $result ]       # string is null
then
    echo "no yxb. result is empyt"
else
    echo "have yxb, result is $result"
fi
```