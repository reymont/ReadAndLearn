https://blog.csdn.net/jasonliujintao/article/details/53509620

sed 之 & 符号
& 这个符号，其实很有用，在对相同模式进行处理的时候很方便。
我们这边主要讲讲这个& 符号的用法
看一下下面这行命令，你觉得会输出什么？

echo hello|sed 's/hello/(&)/'
1
看看结果，你是否猜对了：

[www@]$ echo hello|sed 's/hello/(&)/'
(hello)
1
2
相信大家也明白了，& 符号代表的是你前面的匹配的模式。
那么我们也可以用正则表达式去匹配
echo hello| sed 's/[a-z]*/(&)/' 
1
在看一下结果：

[www@]$ echo hello| sed 's/[a-z]*/(&)/' 
(hello)
1
2
如果说我们多输出一个单词会怎么样？

[www@]$ echo "hello world"| sed 's/[a-z]*/(&)/' 
(hello) world
1
2
为什么world没有加（）呢？这个是前面一篇讲过 sed 是以行为单位的，默认匹配第一个。如果需要把world 也加上 （） 那么就需要加上 g 参数。

[www@]$ echo "hello world"| sed 's/[a-z]*/(&)/g' 
(hello) (world)
1
2
我们是否可以在替换的字符串里添加其他字符呢？当然可以：

[www@]$ echo hello| sed 's/[a-z]*/(&) world/g' 
(hello) world