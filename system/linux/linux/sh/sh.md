

# 调试

* [Shell脚本调试技术 ](https://www.ibm.com/developerworks/cn/linux/l-cn-shell-debug/)

## 三. 使用shell的执行选项
上一节所述的调试手段是通过修改shell脚本的源代码，令其输出相关的调试信息来定位错误的，那有没有不修改源代码来调试shell脚本的方法呢？答案就是使用shell的执行选项，本节将介绍一些常用选项的用法：
-n 只读取shell脚本，但不实际执行
-x 进入跟踪方式，显示所执行的每一条命令
-c "string" 从strings中读取命令
“-n”可用于测试shell脚本是否存在语法错误，但不会实际执行命令。在shell脚本编写完成之后，实际执行之前，首先使用“-n”选项来测试脚本是否存在语法错误是一个很好的习惯。因为某些shell脚本在执行时会对系统环境产生影响，比如生成或移动文件等，如果在实际执行才发现语法错误，您不得不手工做一些系统环境的恢复工作才能继续测试这个脚本。
“-c”选项使shell解释器从一个字符串中而不是从一个文件中读取并执行shell命令。当需要临时测试一小段脚本的执行结果时，可以使用这个选项，如下所示：
sh -c 'a=1;b=2;let c=$a+$b;echo "c=$c"'
"-x"选项可用来跟踪脚本的执行，是调试shell脚本的强有力工具。“-x”选项使shell在执行脚本的过程中把它实际执行的每一个命令行显示出来，并且在行首显示一个"+"号。 "+"号后面显示的是经过了变量替换之后的命令行的内容，有助于分析实际执行的是什么命令。 “-x”选项使用起来简单方便，可以轻松对付大多数的shell调试任务,应把其当作首选的调试手段。
如果把本文前面所述的trap ‘command’ DEBUG机制与“-x”选项结合起来，我们 就可以既输出实际执行的每一条命令，又逐行跟踪相关变量的值，对调试相当有帮助。
仍以前面所述的exp2.sh为例，现在加上“-x”选项来执行它：

```sh
$ sh –x exp2.sh
+ trap 'echo "before execute line:$LINENO, a=$a,b=$b,c=$c"' DEBUG
++ echo 'before execute line:3, a=,b=,c='
before execute line:3, a=,b=,c=
+ a=1
++ echo 'before execute line:4, a=1,b=,c='
before execute line:4, a=1,b=,c=
+ '[' 1 -eq 1 ']'
++ echo 'before execute line:6, a=1,b=,c='
before execute line:6, a=1,b=,c=
+ b=2
++ echo 'before execute line:10, a=1,b=2,c='
before execute line:10, a=1,b=2,c=
+ c=3
++ echo 'before execute line:11, a=1,b=2,c=3'
before execute line:11, a=1,b=2,c=3
+ echo end
end
```

在上面的结果中，前面有“+”号的行是shell脚本实际执行的命令，前面有“++”号的行是执行trap机制中指定的命令，其它的行则是输出信息。
shell的执行选项除了可以在启动shell时指定外，亦可在脚本中用set命令来指定。 "set -参数"表示启用某选项，"set +参数"表示关闭某选项。有时候我们并不需要在启动时用"-x"选项来跟踪所有的命令行，这时我们可以在脚本中使用set命令，如以下脚本片段所示：
set -x　　　 #启动"-x"选项 
要跟踪的程序段 
set +x　　　　 #关闭"-x"选项
set命令同样可以使用上一节中介绍的调试钩子—DEBUG函数来调用，这样可以避免脚本交付使用时删除这些调试语句的麻烦，如以下脚本片段所示：
DEBUG set -x　　　 #启动"-x"选项 
要跟踪的程序段 
DEBUG set +x　　　 #关闭"-x"选项
