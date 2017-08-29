

* [R：增加或删除列表元素 - 初心夢殇 - CSDN博客 ](http://blog.csdn.net/thoixy/article/details/40502895)

```r
#列表创建之后可以添加新的组件：
> z <- list( a="abc", b=12 )
> z$c <- "Add"
> z
#还可以直接使用索引添加组件： 
> z <- list( a="abc", b=12, c="Add" )
> z[ 4 ] <- 28
> z[ 5:6 ] <- c( FALSE, TRUE )
> z
#要删除列表元素何以直接把它的值设为NULL：
#注：删除z$b之后，它之后的元素索引全部减1。
> z <- list( a="abc", b=12, c="Add",28, FALSE, TRUE )
> z$b <- NULL
> z
#把多个列表拼接成一个：
> c( list( "Joe", 55000, T ), list( 3:5, "abc" ) )
```

# list用法、批量读取、写出数据时的用法


* [R语言︱list用法、批量读取、写出数据时的用法 - CSDN博客 ](http://blog.csdn.net/sinat_26917383/article/details/51123214)