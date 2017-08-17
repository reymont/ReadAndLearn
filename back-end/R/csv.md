
* [R—读取数据（导入csv,txt,excel文件） - 记忆的稻草人 - 博客园 ](http://www.cnblogs.com/zhangduo/p/4440314.html)

read.table读取数据非常方便，通常只需要文件路径、URL或连接对象就可以了，也接受非常丰富的参数设置：

file参数：这是必须的，可以是相对路径或者绝对路径（注意：Windows下路径要用斜杠'/'或者双反斜杠'\\'）。
header参数：默认为FALSE即数据框的列名为V1,V2...,设置为TRUE时第一行作为列名。
```r
data1<-read.table('item.csv')#默认header=FALSE
data2<-read.table('item.csv',header=TRUE)
```
sep参数：分隔符，默认为空格。可以设置为逗号(comma)sep=','，分号(semicolon)sep=';'和制表符(tab)。
read.csv、read.csv2、read.delim是read.table函数的包装，分隔符分别对应逗号，分号，制表符，同样接受read.table所有参数。
read.csv函数header参数默认为TRUE，不同于read.table。
```r
data3<-read.csv('item.csv',sep=',',header=TRUE)
data4<-read.table('item.csv')
```

下文示例采用read.csv函数，两种写法效果相同
字符型数据读入时自动转换为因子，因子是R中的变量，它只能取有限的几个不同值，将数据保存为因子可确保模型函数能够正确处理。But当变量作为简单字符串使用时可能出错。要想防止转换为因子：1.令参数stringAsFactors=FALSE,防止导入的数据任何的因子转换。2.更改系统选项options(stringsAsFactors=FALSE)3.指定抑制转换的列：as.is=参数。通过一个索引向量指定，或者一个逻辑向量，需要转换的列取值FALSE,不需要转换的列取值TRUE。
```r
data5<-read.csv('item.csv',stringAsFactors=FALSE)
```
如果数据集中含有中文，直接导入很有可能不识别中文，这时加上参数fileEncoding='utf-8'
```r
read.csv('data.csv',fileEncoding='utf-8')
```