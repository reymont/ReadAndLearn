

* [R语言：matrix常用fuctions_行走在他处_新浪博客 ](http://blog.sina.com.cn/s/blog_908bba500101axv8.html)

```r
> z <- 1:1500
> dim(z) <- c(3, 5, 100)
> z <- array(1:1500, dim=c(3,5,100))
> b <- matrix(1:12, ncol=4, byrow=T)
> b
     [,1] [,2] [,3] [,4]
[1,]    1    2    3    4
[2,]    5    6    7    8
[3,]    9   10   11   12
> b <- matrix(0, nrow=3, ncol=4)
> b <- matrix(c(1,1,1, 2,2,3, 1,3,4, 2,1,4), ncol=3, byrow=T)
> b
     [,1] [,2] [,3]
[1,]    1    1    1
[2,]    2    2    3
[3,]    1    3    4
[4,]    2    1    4
> a[b]
[1]  1 16 23 20
```