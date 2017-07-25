

linkurious.js实现Louvain社区发现算法

原文：[Community Detection · Linkurious/linkurious.js Wiki ](https://github.com/Linkurious/linkurious.js/wiki/Community-Detection)

阅读：
* [五大常用算法：分治、动态规划、贪心、回溯、分支限界_搞怪的小丸子_新浪博客 ](http://blog.sina.com.cn/s/blog_9cbb6a210102v56z.html)
* [数据结构——图 贪婪方法 - ZDF19的博客 - CSDN博客 ](http://blog.csdn.net/ZDF19/article/details/53727010)

Louvain社区发现算法，多整个网络进行处理，将更密集的节点连接在一起。

[linkurious.js Louvain插件](https://github.com/Linkurious/linkurious.js/tree/linkurious-version/plugins/sigma.statistics.louvain)

形式上，社区发现的目的是在一个图中按子集划分节点，使得同一个子集，相对不同子集，节点之间有更多的边。本质上，社区组内联系紧密，组外关系疏松。在论文[1]中讨论了很多解决这个问题的算法。

Louvain是一个流行的社区发现算法，在[2]有描述。该算法通过在网络上尝试各种分组操作后，贪婪地`(当前看来是最好的选择)`优化模块化得分，从而在社区中分离网络。通过使用这种简单的贪婪方法，该算法在计算上非常高效。

[1] Fortunato, Santo. "[Community detection in graphs.](http://cs.ndsu.edu/~perrizo/saturday/Community%20Detection%20in%20Graphs%20Santo%20Fortunato.pdf)" Physics Reports 486, no. 3-5 (2010).

[2] V.D. Blondel, J.-L. Guillaume, R. Lambiotte, E. Lefebvre. "[Fast unfolding of communities in large networks.](https://arxiv.org/abs/0906.0612v2)" J. Stat. Mech., 2008: 1008.


<!--louvain-after-400.png-->
<!--louvain-before-400.png-->
![Before](https://github.com/Linkurious/linkurious.js/wiki/media/louvain-before-400.png) ![After](https://github.com/Linkurious/linkurious.js/wiki/media/louvain-after-400.png)


