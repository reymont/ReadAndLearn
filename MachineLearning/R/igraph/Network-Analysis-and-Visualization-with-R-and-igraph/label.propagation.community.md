
# LPA标签传播算法

<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [LPA标签传播算法](#lpa标签传播算法)
* [python](#python)
* [java](#java)
	* [公式](#公式)
		* [欧拉距离](#欧拉距离)
		* [sigma](#sigma)
		* [欧拉常数 Euler's constant](#欧拉常数-eulers-constant)
* [标签传播的非重叠社区发现算法LPA](#标签传播的非重叠社区发现算法lpa)
* [多线程标签传递算法](#多线程标签传递算法)
* [图形解析](#图形解析)
* [scikit-learn](#scikit-learn)

<!-- /code_chunk_output -->

[label.propagation.community function | R Documentation ](https://www.rdocumentation.org/packages/igraph/versions/0.7.1/topics/label.propagation.community)
[标签传播(LPA)算法及python基于igraph包的实现 - 郑少强 - CSDN博客 ](http://blog.csdn.net/qq_31878083/article/details/51861078)
[数据挖掘 - peghoty - CSDN博客 ](http://blog.csdn.net/peghoty/article/category/1451019/1)
[Community Detection 算法 - peghoty - CSDN博客 ](http://blog.csdn.net/itplus/article/details/9286905)
[融入节点重要性和标签影响力的标签传播社区发现算法 ](http://xwxt.sict.ac.cn/CN/abstract/abstract2843.shtml)

LPA标签传播算法是由Usha Nandini Raghavan等人在2007年提出的。是一种半监督聚类算法；它在聚类算法中的特点是聚类速度快，但聚类结果随机。   
其算法的过程如下：


```R
#社群发现方法五：标签传播社群发现  
member<-label.propagation.community(g.undir,weights=V(g.undir)$weight)  
V(g.undir)$member  
member<-label.propagation.community(g.undir,weights = E(g.undir)$weight,initial = c(1,1,-1,-1,2,-1,1))  
V(g.undir)$member  
member<-label.propagation.community(g.undir,weights = E(g.undir)$weight,  
                                    initial = c(1,1,-1,-1,2,-1,1),fixed=c(T,F,F,F,F,F,T))  
```

```R
g <- erdos.renyi.game(10, 5/10) %du% erdos.renyi.game(9, 5/9)
g <- add.edges(g, c(1, 12))
label.propagation.community(g)
```

[lpa 半监督学习 之--标签传播算法-博客-云栖社区-阿里云 ](https://yq.aliyun.com/articles/69945)

LP算法是基于Graph的，因此我们需要先构建一个图。我们为所有的数据构建一个图，图的节点就是一个数据点，包含labeled和unlabeled的数据。节点i和节点j的边表示他们的相似度。这个图的构建方法有很多，这里我们假设这个图是全连接的


# python

[Label Propagation Algorithm - Wikipedia ](https://en.wikipedia.org/wiki/Label_Propagation_Algorithm)
[Label Propagation Algorithm(LPA) - 八刀一闪的专栏 - CSDN博客 ](http://blog.csdn.net/zzz24512653/article/details/26151669)

基本思想：
    每个结点的标签应该和其大多数邻居的标签相同

算法描述：
    1）初始化所有结点，为每个结点分配唯一的标签
    2）随机选择一个结点，令其及其所属社区的结点标签更换为它的大多数邻居所属的标签，若有几个这样的标签随机选择一个
    3）若每个结点的标签都已和其大多数邻居的相同则停止算法，否则重复2)

引用：【Near linear time algorithm to detect community structures in large-scale networks】

```python
import networkx as nx
import random


def getMaxNeighborLabel(G,node_index):
    dict = {}
    for neighbor_index in G.neighbors(node_index):
        neighbor_label = G.node[neighbor_index]["label"]
        if(dict.has_key(neighbor_label)):
            dict[neighbor_label] += 1
        else:
            dict[neighbor_label] = 1
    max = 0
    for k,v in dict.items():
        if(v>max):
            max = v
    for k,v in dict.items():
        if(v != max):
            dict.pop(k)
    return dict


def canStop(G):
    for i in range(len(G.node)):
        node = G.node[i]
        label = node["label"]
        dict = getMaxNeighborLabel(G, i)
        
        if(not dict.has_key(label)):
            return False
    
    return True
    
'''asynchronous update'''
def populateLabel(G):
    #random visit
    visitSequence = random.sample(G.nodes(),len(G.nodes()))
    for i in visitSequence:
        node = G.node[i]
        label = node["label"]
        dict = getMaxNeighborLabel(G, i)
        
        if(not dict.has_key(label)):
            newLabel = dict.keys()[random.randrange(len(dict.keys()))]
            node["label"] = newLabel
        
def generateCommunity(G):
    dict = {}
    for node in G.nodes(True):
        label = node[1]["label"]
        if(dict.has_key(label)):
            dict.get(label).append(node[0]+1)
        else:
            l = []
            l.append(node[0]+1)
            dict[label] = l
    
    for k,v in dict.items():
        print("label: " + str(k) +" size: "+str(len(v))+" "+ str(v))


def run():
    G = nx.karate_club_graph()
    #initial label
    for i in range(len(G.node)):
        G.node[i]["label"] = i
    
    while(not canStop(G)):
        populateLabel(G)
        
    generateCommunity(G)
    
    
if __name__ == '__main__':
    run()
```


# java

[lpa标签传播算法讲解及代码实现 - - CSDN博客 ](http://blog.csdn.net/nwpuwyk/article/details/47426909)


```java
package lpa;  
  
import java.util.Arrays;  
import java.util.HashMap;  
import java.util.Map;  
  
public class LPA {  
  
    public static float sigma = 1;  
    public static int tag_num = 2;  
      
    public static void main(String[] args) {  
          
        float[][] data = {  
                {1,1},  
                {1,2},  
                {2,1},  
                {2,2},  
                {4,4},  
                {6,6},  
                {6,7},  
                {7,6},  
                {7,7}  
        };  
          
        Map<Integer, Integer> tag_map = new HashMap<Integer, Integer>();  
        tag_map.put(1, 1);  
        tag_map.put(6, 0);  
          
        float[][] weight = new float[data.length][data.length];  
          
        for(int i = 0; i < weight.length; i++) {  
            float sum = 0f;  
            for(int j = 0; j < weight[i].length; j++) {  
                weight[i][j] = (float) Math.exp( - distance(data[i], data[j]) / Math.pow(sigma, 2));  
                sum += weight[i][j];  
            }  
            for(int j = 0; j < weight[i].length; j++) {  
                weight[i][j] /= sum;  
            }  
        }  
          
        System.out.println("=============");  
        for(int i = 0; i < weight.length; i++) {  
            System.out.println(Arrays.toString(weight[i]));  
        }  
        System.out.println("=============");  
          
        float[][] tag_matrix = new float[data.length][tag_num];  
        for(int i = 0; i < tag_matrix.length; i++) {  
            if(tag_map.get(i) != null) {  
                tag_matrix[i][tag_map.get(i)] = 1;  
            } else {  
                float sum = 0;  
                for(int j = 0; j < tag_matrix[i].length; j++) {  
                    tag_matrix[i][j] = (float) Math.random();  
                    sum += tag_matrix[i][j];  
                }  
                for(int j = 0; j < tag_matrix[i].length; j++) {  
                    tag_matrix[i][j] /= sum;  
                }  
            }  
        }  
          
        for(int it = 0; it < 100; it++) {  
            for(int i = 0; i < tag_matrix.length; i++) {  
                if(tag_map.get(i) != null) {  
                    continue;  
                }  
                float all_sum = 0;  
                for(int j = 0; j < tag_matrix[i].length; j++) {  
                    float sum = 0;  
                    for(int k = 0; k < weight.length; k++) {  
                        sum += weight[i][k] * tag_matrix[k][j];  
                    }  
                    tag_matrix[i][j] = sum;  
                    all_sum += sum;  
                }  
                for(int j = 0; j < tag_matrix[i].length; j++) {  
                    tag_matrix[i][j] /= all_sum;  
                }  
            }  
            System.out.println("=============");  
            for(int i = 0; i < tag_matrix.length; i++) {  
                System.out.println(Arrays.toString(tag_matrix[i]));  
            }  
            System.out.println("=============");  
        }  
    }  
      
    public static float distance(float[] a, float[] b) {  
          
        float dis = 0;  
        for(int i = 0; i < a.length; i++) {  
            dis += (float) Math.pow(b[i] - a[i], 2);  
        }  
        return dis;  
    }  
}  
```

## 公式

$w_{ij}=exp(-\frac{d_{ij}}{\sigma^2})$

### 欧拉距离

[Euclidean distance - Wikipedia ](https://en.wikipedia.org/wiki/Euclidean_distance)
[Math (Java Platform SE 7 ) ](https://docs.oracle.com/javase/7/docs/api/java/lang/Math.html)
$(a-b)^2$

注意要`dis += (float) Math.pow(b[i] - a[i], 2);`
```java
public static float distance(float[] a, float[] b) {  
    
    float dis = 0;  
    for(int i = 0; i < a.length; i++) {  
        dis += (float) Math.pow(b[i] - a[i], 2);  
    }  
    return dis;  
} 
```
[R语言:计算各种距离 - 求知：数据科学家之路 - CSDN博客 ](http://blog.csdn.net/xxzhangx/article/details/53153821)
```R
a <- c(3,4)
b <- c(1,2)
plot(rbind(a,b))
dist(rbind(a,b))
```
![r-Euclidean.png](img/r-Euclidean.png)

### sigma

本文中的sigma为1，那么$\sigma^2$=1
```java
public static float sigma = 1;
Math.pow(sigma, 2)
```

### 欧拉常数 Euler's constant

[Euler–Mascheroni constant - Wikipedia ](https://en.wikipedia.org/wiki/Euler%E2%80%93Mascheroni_constant)
[Math.exp() - JavaScript | MDN ](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Math/exp)

e ≈ 2.718...
Math.exp() 函数返回 ex，x 表示参数，e是欧拉常数（Euler's constant），自然对数的底数

$w_{ij}=exp(-\frac{d_{ij}}{\sigma^2})$

```java
for(int i = 0; i < weight.length; i++) {  
    float sum = 0f;  
    for(int j = 0; j < weight[i].length; j++) {  
        weight[i][j] = (float) Math.exp( - distance(data[i], data[j]) / Math.pow(sigma, 2));  
        sum += weight[i][j];  
    }  
    for(int j = 0; j < weight[i].length; j++) {  
        weight[i][j] /= sum;  
    }  
} 
```


[机器学习人群扩散（LPA算法） R实现 - IT届的小学生 - CSDN博客 ](http://blog.csdn.net/HHTNAN/article/details/54571943)
[标签传播算法（Label Propagation）及Python实现 - zouxy09的专栏 - CSDN博客 ](http://blog.csdn.net/zouxy09/article/details/49105265)
[社区发现SLPA算法 - lim1208 - 博客园 ](http://www.cnblogs.com/limin12891/p/5660350.html)

# 标签传播的非重叠社区发现算法LPA

[社区发现算法（四） - I am not a quitter. - CSDN博客 ](http://blog.csdn.net/aspirinvagrant/article/details/46127965)

```r
library('igraph')  
karate  <-  graph.famous("Zachary")  
community <- label.propagation.community(karate)  
modularity(community)  
membership(community)  
plot(community,karate)  
```

![igraph-fast.greedy.png](img/igraph-fast.greedy.png)
![igraph-lpa.png](img/igraph-lpa.png)


# 多线程标签传递算法

* [rrsharma/Code-Sample: Community Detection Algorithm using Label Propagation (Multithreading with Java) ](https://github.com/rrsharma/Code-Sample)

Community Detection Algorithm using Label Propagation (Multithreading with Java)

I have implemented the algorithm mentioned in the paper "Near linear time algorithm to detect community structures in large-scale networks", by Usha Nandini Raghavan, Reka Albert, Soundar Kumara. I have also added the modification suggested by Kishore Kothapalli, Sriram V. Pemmaraju, and Vivek Sardeshmukh, in the paper "On the Analysis of a Label Propagation Algorithm for Community Detection"; which prevents epidemic spread of communities.

PRE-COMPILE : Save Enron email dataset in a .txt file and change the input file name in main of LP.java.

COMPILE: javac findDominantLabel.java javac LP.java

RUN: java LP

引用

1. Harenberg S, Bello G, Gjeltema L, et al. Community detection in large‐scale networks: a survey and empirical evaluation[J]. Wiley Interdisciplinary Reviews Computational Statistics, 2015, 6(6):426-439.
2. Kothapalli K, Pemmaraju S V, Sardeshmukh V. On the Analysis of a Label Propagation Algorithm for Community Detection[J]. Computer Science, 2012, 7730(4):255-269.



# 图形解析

[Label Propagation Algorithms ](http://www.opcoast.com/demos/label_propagation/index.html)

References
1. X. Liu, T. Murata, "Advanced modularity-specialized label propagation algorithm for detecting communities in networks," Physica A: Statistical Mechanics and its Applications, Volume 389, Issue 7, 1 April 2010, Pages 1493-150
2. Usha Nandini Raghavan, Reka Albert, Soundar Kumara, "Near linear time algorithm to detect community structures in large-scale networks," Physical Review E 76, 036106 (2007)
3. M. E. J. Newman, M. Girvan, "Finding and evaluating community structure in networks," Phys. Rev. E 69, 026113 (2004)
4. D. Lusseau, K. Schneider, O. J. Boisseau, P. Haase, E. Slooten, S. M. Dawson, "The bottlenose dolphin community of Doubtful Sound features a large proportion of long-lasting associations," Behavioral Ecology and Sociobiology 54 (2003) pp 396-405.
5. M. Girvan and M. E. J. Newman, Proc. Natl. Acad. Sci. USA 99, 7821-7826 (2002)
6. W. W. Zachary, "An information flow model for conflict and fission in small groups," Journal of Anthropological Research 33, 452-473 (1977).


# scikit-learn

[1.14. Semi-Supervised — scikit-learn 0.18.2 documentation ](http://scikit-learn.org/stable/modules/label_propagation.html)

[Decision boundary of label propagation versus SVM on the Iris dataset — scikit-learn 0.18.2 documentation ](http://scikit-learn.org/stable/auto_examples/semi_supervised/plot_label_propagation_versus_svm_iris.html#sphx-glr-auto-examples-semi-supervised-plot-label-propagation-versus-svm-iris-py)
[Label Propagation learning a complex structure — scikit-learn 0.18.2 documentation ](http://scikit-learn.org/stable/auto_examples/semi_supervised/plot_label_propagation_structure.html#sphx-glr-auto-examples-semi-supervised-plot-label-propagation-structure-py)
[Label Propagation digits active learning — scikit-learn 0.18.2 documentation ](http://scikit-learn.org/stable/auto_examples/semi_supervised/plot_label_propagation_digits_active_learning.html#sphx-glr-auto-examples-semi-supervised-plot-label-propagation-digits-active-learning-py)