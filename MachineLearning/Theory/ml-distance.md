## 距离

- [距离计算方法总结 - Bin的专栏 - 博客园](http://www.cnblogs.com/xbinworld/archive/2012/09/24/2700572.html)
- [各种距离算法汇总 - mousever的专栏 - 博客频道 - CSDN.NET](http://blog.csdn.net/mousever/article/details/45967643)
- [几种常见距离算法小结 - 数据挖掘专栏 - 博客频道 - CSDN.NET](http://blog.csdn.net/codyshi/article/details/21412029)
- [18种和“距离(distance)”、“相似度(similarity)”相关的量的小结 - Solomon的博客 - 博客频道 - CSDN.NET](http://blog.csdn.net/solomonlangrui/article/details/47454805)
- [常见的距离算法和相似度（相关系数）计算方法 - 混沌战神阿瑞斯 - 博客园](http://www.cnblogs.com/arachis/p/Similarity.html)
- [Jaccard系数 - 搜狗百科](http://baike.sogou.com/v76619503.htm?fromTitle=Jaccard%E7%B3%BB%E6%95%B0)
- [R语言:计算各种距离 - 求知：数据科学家之路 - CSDN博客 ](http://blog.csdn.net/xxzhangx/article/details/53153821)
- [余弦距离、欧氏距离和杰卡德相似性度量的对比分析 - ChaoSimple - 博客园 ](http://www.cnblogs.com/chaosimple/archive/2013/06/28/3160839.html)
- [R语言 三种聚类 - 插肩美女不屑看，三千码友在身旁 ](https://my.oschina.net/u/1047640/blog/202714#OSC_h4_2)



# R语言:计算各种距离

* [R语言:计算各种距离 - 求知：数据科学家之路 - CSDN博客 ](http://blog.csdn.net/xxzhangx/article/details/53153821)

## 余弦距离


a,b的坐标为(x1,y1), (x2,y2)
$cos\theta = \frac{x_1 \times x_2 + y_1 \times y_2}
             {\sqrt{x^2_1+y^2_1} \times \sqrt{x^2_2+y^2_2}}
$

$cos\theta = \frac{a^Tb}{|a||b|}$



```r
> aa=matrix(rnorm(15,0,1),c(3,5))
> aa
          [,1]       [,2]       [,3]       [,4]       [,5]
[1,]  1.390935  0.2061215 -0.4412572 -0.1490162 -0.6332618
[2,] -1.404099  1.7485971  1.0966853  0.7876016  1.0543667
[3,]  1.571527 -0.5391710  0.1622600  0.6927980 -1.1825320
> bb <- matrix(rep(0,9),3,3)
> bb
     [,1] [,2] [,3]
[1,]    0    0    0
[2,]    0    0    0
[3,]    0    0    0
> for (i in 1:3)
+   for (j in 1:3)
+     if (i < j)
+       bb[i,j] = sum(t(aa[i,])*aa[j,])/sqrt((sum(aa[i,]^2))*sum(aa[j,]^2))
> bb
     [,1]       [,2]       [,3]
[1,]    0 -0.6294542  0.7612659
[2,]    0  0.0000000 -0.6025365
[3,]    0  0.0000000  0.0000000
```