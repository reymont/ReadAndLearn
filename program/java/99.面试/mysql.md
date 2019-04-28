# 1. mysql的Join原理以及索引数据结构和实现原理
https://www.deanwangpro.com/2017/01/31/ali-interview/

只知道mysql innoDB join只支持Nested Loop，不支持Hash Join，就是确定一个驱动表后不断Join得到结果集，再继续往下Join。所以Join的顺序很重要。

索引只知道数据结构是B+Tree，其实就真悲催了。所以检讨一下，搜到一篇不错的文章。

# 2. MySQL索引背后的数据结构及算法原理 
http://blog.codinglabs.org/articles/theory-of-mysql-index.html