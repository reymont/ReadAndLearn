


fastgreedy算法

```R
library(sand)
library(igraph)
data(karate)
kc <- fastgreedy.community(karate)
plot(kc,karate)
```

- [R: Hierarchical Clustering ](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/hclust.html)

```R
require(graphics)

### Example 1: Violent crime rates by US state

hc <- hclust(dist(USArrests), "ave")
plot(hc)
plot(hc, hang = -1)

## Do the same with centroid clustering and *squared* Euclidean distance,
## cut the tree into ten clusters and reconstruct the upper part of the
## tree from the cluster centers.
hc <- hclust(dist(USArrests)^2, "cen")
memb <- cutree(hc, k = 10)
cent <- NULL
for(k in 1:10){
  cent <- rbind(cent, colMeans(USArrests[memb == k, , drop = FALSE]))
}
hc1 <- hclust(dist(cent)^2, method = "cen", members = table(memb))
opar <- par(mfrow = c(1, 2))
plot(hc,  labels = FALSE, hang = -1, main = "Original Tree")
plot(hc1, labels = FALSE, hang = -1, main = "Re-start from 10 clusters")
par(opar)

### Example 2: Straight-line distances among 10 US cities
##  Compare the results of algorithms "ward.D" and "ward.D2"

data(UScitiesD)

mds2 <- -cmdscale(UScitiesD)
plot(mds2, type="n", axes=FALSE, ann=FALSE)
text(mds2, labels=rownames(mds2), xpd = NA)

hcity.D  <- hclust(UScitiesD, "ward.D") # "wrong"
hcity.D2 <- hclust(UScitiesD, "ward.D2")
opar <- par(mfrow = c(1, 2))
plot(hcity.D,  hang=-1)
plot(hcity.D2, hang=-1)
par(opar)
```


- [R：数据分析之聚类分析hclust_余鲲涛_新浪博客 ](http://blog.sina.com.cn/s/blog_615770bd01018dnj.html)
- [R: Cut a Tree into Groups of Data ](https://stat.ethz.ch/R-manual/R-patched/library/stats/html/cutree.html)

- [communities | igraph R manual pages ](http://igraph.org/r/doc/communities.html)

```R
A <- get.adjacency(karate, sparse=FALSE)
```


- [cluster_fast_greedy | igraph R manual pages ](http://igraph.org/r/doc/cluster_fast_greedy.html)


- [Hierarchical Clustering in R | R-bloggers ](https://www.r-bloggers.com/hierarchical-clustering-in-r-2/)

```R
clusters <- hclust(dist(iris[, 3:4]))
plot(clusters)
clusterCut <- cutree(clusters, 3)
table(clusterCut, iris$Species)

clusters <- hclust(dist(iris[, 3:4]), method = 'average')
plot(clusters)
clusterCut <- cutree(clusters, 3)
table(clusterCut, iris$Species)

library(ggplot2)
ggplot(iris, aes(Petal.Length, Petal.Width, color = iris$Species)) + 
     geom_point(alpha = 0.4, size = 3.5) + geom_point(col = clusterCut) + 
     scale_color_manual(values = c('black', 'red', 'green'))
```


- [Using R — Calling C Code ‘Hello World!’ | Working With Data ](http://mazamascience.com/WorkingWithData/?p=1067)

- [c++中__declspec用法总结 - hollyhock13的专栏 - CSDN博客 ](http://blog.csdn.net/hollyhock13/article/details/2776276)
“__declspec”是Microsoft c++中专用的关键字，它配合着一些属性可以对标准C++进行扩充。这些属性有：align、allocate、deprecated、 dllexport、dllimport、 naked、noinline、noreturn、nothrow、novtable、selectany、thread、property和uuid。

- [c++ 中__declspec 的用法 - ylclass - 博客园 ](http://www.cnblogs.com/ylhome/archive/2010/07/10/1774770.html)

dllimport 和dllexport 

用__declspec(dllexport)，__declspec(dllimport)显式的定义dll接口给调用它的exe或dll文件，用 dllexport定义的函数不再需要（.def）文件声明这些函数接口了。注意：若在dll中定义了模板类那它已经隐式的进行了这两种声明，我们只需在 调用的时候实例化即可

- [extern C的作用详解 - 疯狂算法~ - CSDN博客 ](http://blog.csdn.net/jiqiren007/article/details/5933599)

 extern "C"的主要作用就是为了能够正确实现C++代码调用其他C语言代码。加上extern "C"后，会指示编译器这部分代码按c语言的进行编译，而不是C++的。由于C++支持函数重载，因此编译器编译函数的过程中会将函数的参数类型也加到编译后的代码中，而不仅仅是函数名；而C语言并不支持函数重载，因此编译C语言代码的函数时不会带上函数的参数类型，一般之包括函数名。

     这个功能十分有用处，因为在C++出现以前，很多代码都是C语言写的，而且很底层的库也是C语言写的，为了更好的支持原来的C代码和已经写好的C语言库，需要在C++中尽可能的支持C，而extern "C"就是其中的一个策略。

- [Rcpp的前世今生 - R语言-炼数成金-Dataguru专业数据分析社区 ](http://www.dataguru.cn/article-3762-1.html)

其中SEXP是pointer to S expression type，这个是指向R各种类型的一个指针。

- [Advanced R ](http://adv-r.hadley.nz/)
- [R for Data Science ](http://r4ds.had.co.nz/)
- [Welcome · R packages ](http://r-pkgs.had.co.nz/)
- [hadley/devtools: Tools to make an R developer's life easier ](https://github.com/hadley/devtools)
- [hadley/r4ds: R for data science ](https://github.com/hadley/r4ds)
- [R's C interface · Advanced R. ](http://adv-r.had.co.nz/C-interface.html)

At the C-level, all R objects are stored in a common datatype, the SEXP, or S-expression. All R objects are S-expressions so every C function that you create must return a SEXP as output and take SEXPs as inputs. (Technically, this is a pointer to a structure with typedef SEXPREC.) A SEXP is a variant type, with subtypes for all R’s data structures. The most important types are:

There’s no built-in R function to easily access these names, but pryr provides sexp_type():
```R
library(pryr)

sexp_type(10L)
sexp_type(10L)
## [1] "INTSXP"
sexp_type("a")
## [1] "STRSXP"
sexp_type(T)
## [1] "LGLSXP"
sexp_type(list(a = 1))
## [1] "VECSXP"
sexp_type(pairlist(a = 1))
## [1] "LISTSXP"
```

- [编写R包C扩展的核心指引 - R语言-炼数成金-Dataguru专业数据分析社区 ](http://www.dataguru.cn/article-1178-1.html)

R的头文件在$RHOME/include，对于用C写R扩展这个应用场景来说，有用的是R.h，Rdefines.h和Rinternals.h这几个文件。
R.h是每一个为R作接口的C扩展里必须包含的。
Rinternals.h是最核心的定义文件，它定义了最基本也是唯一的R结构SEXP（详见这里）及其它的一些数据类型与结构、常量、以及所有你会用得到的接口函数。
Rdefines.h中include了Rinternals.h，并且为了方便使用，定义了一大批的宏，对Rinternals.h中的函数进行了封装，虽然还不是完全的封装，但已经很够用，语义上也好理解得多。

- [[译] 深入对比数据科学工具箱：Python 和 R 的 C/C++ 实现 - FinanceR - SegmentFault ](https://segmentfault.com/a/1190000006722144)


- [Writing R Extensions ](https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Linking-to-native-routines-in-other-packages)

R_ext/Rdynload.h	needed to register compiled code in packages

- [R-devel: Rdynload.h Source File ](http://docs.rexamine.com/R-devel/Rdynload_8h_source.html)

- [r-source/R.h at trunk · wch/r-source ](https://github.com/wch/r-source/blob/trunk/src/include/R.h)
- [r-source/libextern.h at 8a55192af9a65291afffb64c22b29801ea9151a6 · wch/r-source ](https://github.com/wch/r-source/blob/8a55192af9a65291afffb64c22b29801ea9151a6/src/include/R_ext/libextern.h)