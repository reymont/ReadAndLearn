xargs命令详解，xargs与管道的区别 - 薰衣草的旋律 - 博客园 https://www.cnblogs.com/wangqiguo/p/6464234.html

阅读目录

为什么要用xargs，问题的来源
xargs是什么，与管道有什么不同
xargs的一些有用的选项
回到顶部
为什么要用xargs，问题的来源
在工作中经常会接触到xargs命令，特别是在别人写的脚本里面也经常会遇到，但是却很容易与管道搞混淆，本篇会详细讲解到底什么是xargs命令，为什么要用xargs命令以及与管道的区别。为什么要用xargs呢，我们知道，linux命令可以从两个地方读取要处理的内容，一个是通过命令行参数，一个是标准输入。例如cat、grep就是这样的命令，举个例子：

1
echo 'main' | cat test.cpp
这种情况下cat会输出test.cpp的内容，而不是'main'字符串，如果test.cpp不存在则cat命令报告该文件不存在，并不会尝试从标准输入中读取。echo 'main' | 会通过管道将 echo 的标准输出(也就是字符串'main')导入到 cat 的标准输入，也就是说此时cat的标准输入中是有内容的，其内容就是字符串'main'但是上面的内容中cat不会从它的标准输入中读入要处理的内容。(注:标准输入是有一个缓冲区的，就像我们在程序中使用scanf函数从标准输入中读取一样，实际上是从标准输入的缓冲区中读取的)。其实基本上linux的命令中很多的命令的设计是先从命令行参数中获取参数，然后从标准输入中读取，反映在程序上，命令行参数是通过main函数 int main(int argc,char*argv[]) 的函数参数获得的，而标准输入则是通过标准输入函数例如C语言中的scanf读取到的。他们获取的地方是不一样的。例如：

echo 'main' | cat
这条命令中cat会从其标准输入中读取内容并处理，也就是会输出 'main' 字符串。echo命令将其标准输出的内容 'main' 通过管道定向到 cat 的标准输入中。

cat
如果仅仅输入cat并回车，则该程序会等待输入，我们需要从键盘输入要处理的内容给cat，此时cat也是从标准输入中得到要处理的内容的，因为我们的cat命令行中也没有指定要处理的文件名。大多数命令有一个参数  -  如果直接在命令的最后指定 -  则表示从标准输入中读取，例如：

1
echo 'main' | cat -
这样也是可行的，会显示 'main' 字符串，同样输入 cat - 直接回车与输入 cat 直接回车的效果也一样，但是如果这样呢：

1
echo 'main' | cat test.cpp -
同时指定test.cpp 和 - 参数，此时cat程序还是会显示test.cpp的内容。但是有一个程序的策略则不同，它是grep，例如：

1
echo 'main' | grep 'main' test.cpp -
该命令的输出结果是:
test.cpp:int main()
(standard input):main

此时grep会同时处理标准输入和文件test.cpp中的内容，也就是说会在标准输入中搜索 'main' 也会在文件 test.cpp (该文件名从grep命令行参数中获得)中搜索 'main'。也就是说当命令行中 test.cpp 和 - 两个参数同时存在的时候，不同的程序处理不同。我们看到了cat与grep处理就不同。但是有一点是一样的，首先在命令行中查找要处理的内容的来源(是从文件还是从标准输入，还是都有)，如果在命令行中找不到与要处理的内容的来源相关的参数则默认从标准输入中读取要处理的内容了。

另外很多程序是不处理标准输入的，例如 kill , rm 这些程序如果命令行参数中没有指定要处理的内容则不会默认从标准输入中读取。所以：

echo '516' | kill
这种命里是不能执行的。

1
echo 'test' | rm -f
这种也是没有效果的。

这两个命令只接受命令行参数中指定的处理内容，不从标准输入中获取处理内容。想想也很正常，kill 是结束进程，rm是删除文件，如果要结束的进程pid和要删除的文件名需要从标准输入中读取，这个也很怪异吧。 但是像 cat与grep这些文字处理工具从标准输入中读取待处理的内容则很自然。

但是有时候我们的脚本却需要 echo '516' | kill 这样的效果，例如 ps -ef | grep 'ddd' | kill 这样的效果，筛选出符合某条件的进程pid然后结束。这种需求对于我们来说是理所当然而且是很常见的，那么应该怎样达到这样的效果呢。有几个解决办法：

```sh
1. 通过 kill `ps -ef | grep 'ddd'`    
#这种形式，这个时候实际上等同于拼接字符串得到的命令，其效果类似于  kill $pid

2. for procid in $(ps -aux | grep "some search" | awk '{print $2}'); do kill -9 $procid; done   
#其实与第一种原理一样，只不过需要多次kill的时候是循环处理的，每次处理一个

3. ps -ef | grep 'ddd' | xargs kill  
#OK，使用了xargs命令，铺垫了这么久终于铺到了主题上。xargs命令可以通过管道接受字符串，并将接收到的字符串通过空格分割成许多参数(默认情况下是通过空格分割) 然后将参数传递给其后面的命令，作为后面命令的命令行参数
```

## xargs是什么，与管道有什么不同
xargs与管道有什么不同呢，这是两个很容易混淆的东西，看了上面的xargs的例子还是有点云里雾里的话，我们来看下面的例子弄清楚为什么需要xargs：

echo '--help' | cat 
输出：
--help

echo '--help' | xargs cat 
输出：


Usage: cat [OPTION]... [FILE]...
Concatenate FILE(s), or standard input, to standard output.
 
  -A, --show-all           equivalent to -vET
  -b, --number-nonblank    number nonempty output lines
  -e                       equivalent to -vE
  -E, --show-ends          display $ at end of each line
  -n, --number             number all output lines
  -s, --squeeze-blank      suppress repeated empty output lines
  -t                       equivalent to -vT
  -T, --show-tabs          display TAB characters as ^I
  -u                       (ignored)
  -v, --show-nonprinting   use ^ and M- notation, except for LFD and TAB
      --help     display this help and exit
      --version  output version information and exit
 
With no FILE, or when FILE is -, read standard input.
 
Examples:
  cat f - g  Output f's contents, then standard input, then g's contents.
  cat        Copy standard input to standard output.
 
Report cat bugs to bug-coreutils@gnu.org
GNU coreutils home page: <http://www.gnu.org/software/coreutils/>
General help using GNU software: <http://www.gnu.org/gethelp/>
For complete documentation, run: info coreutils 'cat invocation'
可以看到 echo '--help' | cat   该命令输出的是echo的内容，也就是说将echo的内容当作cat处理的文件内容了，实际上就是echo命令的输出通过管道定向到cat的输入了。然后cat从其标准输入中读取待处理的文本内容。这等价于在test.txt文件中有一行字符 '--help' 然后运行  cat test.txt 的效果。

而 echo '--help' | xargs cat 等价于 cat --help 什么意思呢，就是xargs将其接受的字符串 --help 做成cat的一个命令参数来运行cat命令，同样  echo 'test.c test.cpp' | xargs cat 等价于 cat test.c test.cpp 此时会将test.c和test.cpp的内容都显示出来。

## xargs的一些有用的选项
相信到这里应该都知道xargs的作用了，那么我们看看xargs还有一些有用的选项：

1. -d 选项
默认情况下xargs将其标准输入中的内容以空白(包括空格、Tab、回车换行等)分割成多个之后当作命令行参数传递给其后面的命令，并运行之，我们可以使用 -d 命令指定分隔符，例如：
echo '11@22@33' | xargs echo 
输出：
11@22@33
默认情况下以空白分割，那么11@22@33这个字符串中没有空白，所以实际上等价于 echo 11@22@33 其中字符串 '11@22@33' 被当作echo命令的一个命令行参数

echo '11@22@33' | xargs -d '@' echo 
输出：
11 22 33
指定以@符号分割参数，所以等价于 echo 11 22 33 相当于给echo传递了3个参数，分别是11、22、33

2. -p 选项
使用该选项之后xargs并不会马上执行其后面的命令，而是输出即将要执行的完整的命令(包括命令以及传递给命令的命令行参数)，询问是否执行，输入 y 才继续执行，否则不执行。这种方式可以清楚的看到执行的命令是什么样子，也就是xargs传递给命令的参数是什么，例如：
echo '11@22@33' | xargs -p -d '@'  echo 
输出：
echo 11 22 33
 ?...y      ==>这里询问是否执行命令 echo 11 22 33 输入y并回车，则显示执行结果，否则不执行
 11 22 33   ==>执行结果

3. -n 选项
该选项表示将xargs生成的命令行参数，每次传递几个参数给其后面的命令执行，例如如果xargs从标准输入中读入内容，然后以分隔符分割之后生成的命令行参数有10个，使用 -n 3 之后表示一次传递给xargs后面的命令是3个参数，因为一共有10个参数，所以要执行4次，才能将参数用完。例如：

echo '11@22@33@44@55@66@77@88@99@00' | xargs -d '@' -n 3 echo 
输出结果：
11 22 33
44 55 66
77 88 99
00
等价于：
echo 11 22 33
echo 44 55 66
echo 77 88 99
echo 00
实际上运行了4次，每次传递3个参数，最后还剩一个，就直接传递一个参数。

4. -E 选项，有的系统的xargs版本可能是-e  eof-str
该选项指定一个字符串，当xargs解析出多个命令行参数的时候，如果搜索到-e指定的命令行参数，则只会将-e指定的命令行参数之前的参数(不包括-e指定的这个参数)传递给xargs后面的命令
echo '11 22 33' | xargs -E '33' echo 
输出：
11 22

可以看到正常情况下有3个命令行参数 11、22、33 由于使用了-E '33' 表示在将命令行参数 33 之前的参数传递给执行的命令，33本身不传递。等价于 echo 11 22 这里-E实际上有搜索的作用，表示只取xargs读到的命令行参数前面的某些部分给命令执行。

注意：-E只有在xargs不指定-d的时候有效，如果指定了-d则不起作用，而不管-d指定的是什么字符，空格也不行。

echo '11 22 33' | xargs -d ' ' -E '33' echo  => 输出 11 22 33
echo '11@22@33@44@55@66@77@88@99@00 aa 33 bb' | xargs -E '33' -d '@' -p  echo  => 输出 11 22 33 44 55 66 77 88 99 00 aa 33 bb

