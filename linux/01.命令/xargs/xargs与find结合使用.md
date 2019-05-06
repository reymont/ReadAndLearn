

## -0 选项表示以 '\0' 为分隔符，一般与find结合使用

find . -name "*.txt"
输出：
./2.txt
./3.txt
./1.txt     => 默认情况下find的输出结果是每条记录后面加上换行，也就是每条记录是一个新行

find . -name "*.txt" -print0
输出：
./2.txt./3.txt./1.txt     => 加上 -print0 参数表示find输出的每条结果后面加上 '\0' 而不是换行

find . -name "*.txt" -print0 | xargs -0 echo 
输出：
./2.txt ./3.txt ./1.txt

find . -name "*.txt" -print0 | xargs -d '\0' echo 
输出：
./2.txt ./3.txt ./1.txt

xargs的 -0 和 -d '\0' 表示其从标准输入中读取的内容使用 '\0' 来分割，`由于 find 的结果是使用 '\0' 分隔的`，所以xargs使用 '\0' 将 find的结果分隔之后得到3个参数： ./2.txt ./3.txt ./1.txt  注意中间是有空格的。上面的结果就等价于 echo ./2.txt ./3.txt ./1.txt

实际上使用xargs默认的空白分隔符也是可以的  find . -name "*.txt"  | xargs  echo   因为换行符也是xargs的默认空白符的一种。find命令如果不加-print0其搜索结果的每一条字符串后面实际上是加了换行

## 参考

1. https://www.cnblogs.com/wangqiguo/p/6464234.html