&emsp;&emsp;Newman快速算法实际上是基于贪婪算法思想的一种凝聚算法【1】。贪婪算法是一种在每一步选择中都采取在当前状态下最好或最优（即最有利）的选择，从而希望导致结果是最好或最优的算法【2】。社区发现（Community Detection）算法用来发现网络中的社区结构，也可以视为一种广义的聚类算法【4】。基于模块度优化的社团发现算法是目前研究最多的一类算法，由Newman等首先提出模块度Q 值是目前使用最广泛的优化目标【3】。Newman算法可以用于分析节点数达100万的复杂网络【1】
 
&emsp;&emsp;Newman快速算法将每个节点看作是一个社团，每次迭代选择产生最大Q值的两个社团合并，直至整个网络融合成一个社团。整个过程可表示成一个树状图，从中选择Ｑ值最大的层次划分得到最终的社团结构。该算法的总体时间复杂度为Ｏ（ｍ（ｍ＋ｎ））【3】。

\{1/2m,2
$$ x = \dfrac{-b \pm \sqrt{b^2 - 4ac}}{2a} $$
$\Gamma(n) = (n-1)!\quad\forall n\in\mathbb N$

$$ \$\frac{a}{b}\ $$

参考
1. [汪小帆. 复杂网络理论及其应用[M]. 清华大学出版社, 2006. P184 ~185](books.google.com.hk/books?id=IMzxW0XiuDQC&pg=PA185&lpg=PA185&dq=Newman%E5%BF%AB%E9%80%9F%E7%AE%97%E6%B3%95&source=bl&ots=fvl3jgHdIz&sig=hGR-_8bH0ZklUkWWbtLra8geFDY&hl=zh-CN&sa=X&ved=0ahUKEwizjebkvYLVAhVGUZQKHWneCUUQ6AEILDAB#v=onepage&q=Newman%E5%BF%AB%E9%80%9F%E7%AE%97%E6%B3%95&f=false)
2. [贪心法 - 维基百科，自由的百科全书](zh.wikipedia.org/wiki/%E8%B4%AA%E5%BF%83%E6%B3%95)
3. [骆志刚, 丁凡, 蒋晓舟,等. 复杂网络社团发现算法研究新进展[J]. 国防科技大学学报, 2011, 33(1):47-52.
](journal.nudt.edu.cn/publish_article/2011/1/201101011.pdf)
4. [Community Detection 算法 - peghoty - CSDN博客 ](http://blog.csdn.net/itplus/article/details/9286905)
5. [模块度(Modularity)与Fast Newman算法讲解与代码实现 - 博客频道 - CSDN.NET ](blog.csdn.net/marywbrown/article/details/62059231)
6. [科学网—Girvan-Newman社群发现算法 - 毛进的博文 ](http://blog.sciencenet.cn/blog-563898-750516.html)
7. [模块度 - 维基百科，自由的百科全书 ](https://zh.wikipedia.org/wiki/%E6%A8%A1%E5%9D%97%E5%BA%A6)
8. [Markdown中插入数学公式的方法 - xiahouzuoxin - CSDN博客](http://blog.csdn.net/xiahouzuoxin/article/details/26478179) 
9. [Kumar R, Moseley B, Vassilvitskii S, et al. Fast greedy algorithms in mapreduce and streaming[C]// ACM Symposium on Parallelism in Algorithms and Architectures. ACM, 2013:1-10.](http://cseweb.ucsd.edu/~avattani/papers/mrgreedy.pdf)