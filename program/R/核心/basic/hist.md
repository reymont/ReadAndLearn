* [直方图的一天--周的如何和有字符串标签 - 广瓜网 ](http://www.guanggua.com/question/6923223-how-to-histogram-day-of-week-and-have-string-labels.html)


```r
dat <- as.Date( c("2010-04-02", "2010-04-06", "2010-04-09", "2010-04-10", "2010-04-14", 
       "2010-04-15", "2010-04-19",   "2010-04-21", "2010-04-22", "2010-04-23","2010-04-24", 
        "2010-04-25", "2010-04-26", "2010-04-28", "2010-04-29", "2010-04-30"))
 dwka <- format(dat , "%a")
 dwka
# [1] "Fri" "Tue" "Fri" "Sat" "Wed" "Thu" "Mon"
#  [8] "Wed" "Thu" "Fri" "Sat" "Sun" "Mon" "Wed"
# [15] "Thu" "Fri"
dwkn <- as.numeric( format(dat , "%w") ) # numeric version
hist( dwkn , breaks= -.5+0:7, labels= unique(dwka[order(dwkn)]))
```