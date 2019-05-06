## axis

* [R语言 - 标签 - 庐州月光 - 博客园 ](http://www.cnblogs.com/xudongliang/tag/R%E8%AF%AD%E8%A8%80/default.html?page=2)
* [Quick-R: Axes and Text ](http://www.statmethods.net/advgraphs/axes.html)
* [R语言低级绘图函数-axis - 庐州月光 - 博客园 ](http://www.cnblogs.com/xudongliang/p/6762618.html)



# Quick-R: Axes and Text

* [Quick-R: Axes and Text ](http://www.statmethods.net/advgraphs/axes.html)

```
# Example of labeling points
attach(mtcars)
plot(wt, mpg, main="Milage vs. Car Weight", 
  	xlab="Weight", ylab="Mileage", pch=18, col="blue")
text(wt, mpg, row.names(mtcars), cex=0.6, pos=4, col="red")
```


## R语言如何画出x轴为字符型，y轴数值型的图形

* [请教，R语言如何画出x轴为字符型，y轴数值型的图形啊？ - R语言论坛 - 经管之家(原人大经济论坛) ](http://bbs.pinggu.org/thread-1308506-1-1.html)

```R
plot(1:7, rnorm(7), main = "axis() examples",
      type = "s", xaxt = "n", frame = FALSE, col = "red")
 axis(1, 1:7, LETTERS[1:7], col.axis = "blue")
```