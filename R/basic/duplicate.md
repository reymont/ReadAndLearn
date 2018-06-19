

* [R语言中，unique和duplicate的区别是什么_百度知道 ](https://zhidao.baidu.com/question/1962070431542733580.html)

unique返回对象的不同取值，如unique(c(1,1,2,3)) 返回1 2 3
duplicated 判断对象的每个取值是否重复，如duplicated(c(1,1,2,3)) 返回 FALSE  TRUE FALSE FALSE ，其中T对应的为重复的值

* [R中如何判断并删除重复行？ - R语言论坛 - 经管之家(原人大经济论坛) ](http://bbs.pinggu.org/thread-2791276-1-1.html)

```r
test[!duplicated(test$x), ] 
#一行搞定啊
base::unique(data) 
#dplyr
data <- data.frame(id1 = c(1, 1, 1, 2, 2),
                   id2 = c(2, 2, 3, 2, 2))

library(dplyr)

data %>%
  group_by(id1, id2) %>%
  filter(row_number() == 1) %>%
  ungroup()
```
