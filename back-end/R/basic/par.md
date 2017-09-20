

* [用R画并列的图形_百度经验 ](http://jingyan.baidu.com/article/c85b7a645e33a4003bac9594.html)

使用函数par()可以实现在同一个窗口中画多个图形，下面我们用一个事例，对此进行介绍。把窗口分为2部分：
```r
windows(width=8,height=4)
par(mfrow=c(1,2))
x<-c(1,3,5,7,9,12,14,16)
y<-c(2,4,6,8,14,16,18,19)
z<-c(3,6,9,13,17,19,22,25)
plot(x,y)
title("x and y")
plot(x,z)
title("x and z")
```

把窗口分为四部分：
windows(width=8,height=4)
x<-c(1,3,5,7,9,12,14,16)
y<-c(2,4,6,8,14,16,18,19)
z<-c(3,6,9,13,17,19,22,25)
layout(matrix(1:4,2,2))
plot(x,y)
title(x and y)
plot(x,z)
title(x and z)
plot(y,z)
title(y and z)
plot(z,z)
title(z and z)