#相异矩阵计算


<!-- @import "[TOC]" {cmd:"toc", depthFrom:1, depthTo:6, orderedList:false} -->
<!-- code_chunk_output -->

* [相异矩阵计算](#相异矩阵计算)
* [简介](#简介)
* [算法](#算法)
* [R的实现](#r的实现)
	* [Usage](#usage)
	* [Arguments](#arguments)
	* [Return](#return)
* [可视化](#可视化)
* [案例分析](#案例分析)
	* [场景](#场景)
	* [输入参数](#输入参数)
	* [执行](#执行)
	* [输出](#输出)
	* [分析](#分析)
* [参考](#参考)

<!-- /code_chunk_output -->


原文：[Data Mining Algorithms In R/Clustering/Dissimilarity Matrix Calculation - Wikibooks, open books for an open world](https://en.wikibooks.org/wiki/Data_Mining_Algorithms_In_R/Clustering/Dissimilarity_Matrix_Calculation)

#简介
Dissimilarity may be defined as the distance between two samples under some criterion, in other words, how different these samples are. Considering the Cartesian Plane, one could say that the euclidean distance between two points is the measure of their dissimilarity. The Dissimilarity index can also be defined as the percentage of a group that would have to move to another group so the samples to achieve an even distribution.
**相异（Dissimilarity）**可以被定义为以某种标准计算两个样本之间的距离。换句话说，这些样本有多不同。依据[笛卡儿平面](https://en.wikipedia.org/wiki/Cartesian_coordinate_system "Cartesian Plane")，可以说，两个点之间的欧氏距离就是它们**dissimilarity**的度量。[相异指数](https://en.wikipedia.org/wiki/Index_of_dissimilarity "Dissimilarity index")也可以被定义为一个组的百分比必须移动到另一个组这样样本才能达到均匀分布。

The Dissimilarity matrix is a matrix that express the similarity pair to pair between to sets. It's square, and symmetric. The diagonal members are defined as zero, meaning that zero is the measure of dissimilarity between an element and itself. Thus, the information the matrix holds can be seen as a triangular matrix. MARCHIORO et al. (2003) [1] used the matrix of dissimilarity to determine the differences between oat specimens and discover good generators for the future generations.
**相异矩阵（Dissimilarity Matrix）**是一个矩阵，它表达了对集合之间的相似性对。它是正方形的、对称的。对角元素被定义为0，意味着元素和自身之间的不相似性的度量为0。因此，矩阵所包含的信息可以被看作是一个三角形矩。

The concept of Dissimilarity may be used in a more general way, to determine the pairwise difference between samples. As an example, this was used by da Silveira and Hanashiro (2009)[2] to study the impact of similarity and dissimilarity between superior and subordinate in the quality of their relationship. The similarity notion is a key concept for Clustering, in the way to decide which clusters should be combined or divided when observing sets. An appropriate metric use is strategic in order to achieve the best clustering, because it directly influences the shape of clusters. The Dissimilarity Matrix (or Distance matrix) is used in many algorithms of Density-based and Hierarchical clustering, like LSDBC.
**相异**的概念可以用在更一般的方法上，比如确定样本对之间的差异。作为一个例子，这是da Silveira和Hanashiro(2009)【2】使用的，目的是研究在他们的关系质量中，上级和下级之间的相似性和不同的影响。相似性概念是聚类的一个关键概念，以确定在观察集合时应该组合或划分哪个集群。适当的度量使用是战略性的，以实现最佳的集群，因为它直接影响集群的形状。**相异矩阵（Dissimilarity Matrix）**(或距离矩阵)被用于许多基于密度和分层的聚类算法中，比如LSDBC【7】。


The Dissimilarity Matrix Calculation is used, for example, to find Genetic Dissimilarity among oat genotypes[1]. The way of arranging the sequences of protein, RNA and DNA to identify regions of similarity that may be a consequence of relationships between the sequences, in bioinformatics, is defined as sequence alignment. Sequence alignment is part of genome assembly, where sequences are aligned to find overlaps so that long sequences can be formed.

#算法
The matrix may be calculated by iterating over each element and calculating its dissimilarity to every other element. Let A be a Dissimilarity Matrix of size NxN, and B a set of N elements. Aij is the dissimilarity between elements Bi and Bj.


```java
   for i = 0 to N do
       for j = 0 to N do
           Aij = Dissimilarity(Bi,Bj)
       end-for
   end-for
```
where the function Dissimilarity is defined as follows:
```java
Dissimilarity(a,b) =
    0, if a = b
    ApplyDissimilarityCriterion(a,b), otherwise
```
ApplyDissimilarityCriterion是一个函数，基于某种算法计算不同元素之间的距离。下面是一些算法的清单【8】：

- Euclidean Distance欧拉距离
- Squared Euclidean Distance平方欧拉距离【9】
- Manhattan Distance曼哈顿距离
- Maximum Distance最大距离
- Mahalanobis Distance马氏距离
- Cosine Similarity夹角余弦距离


#R的实现
Cluster Analysis, extended original from Peter Rousseeuw, Anja Struyf and Mia Hubert.

```R
Package: cluster
Version: 1.12.1
Priority: recommended
Depends: R (>= 2.5.0), stats, graphics, utils
Published: 2009-10-06
Author: Martin Maechler, based on S original by Peter Rousseeuw, Anja.Struyf@uia.ua.ac.be and Mia.Hubert@uia.ua.ac.be, and initial R port by Kurt.Hornik@R-project.org
Maintainer: Martin Maechler <maechler at stat.math.ethz.ch>
License: GPL (>= 2)
Citation: cluster citation info
In views: Cluster, Environmetrics, Multivariate
CRAN checks: cluster results
```

The package can be downloaded from the [CRAN](http://cran.r-project.org/) website. It can be installed using the install.packages() function, directly in R environment. The function daisy is used to calculate the dissimilarity matrix. It can be found in the cluster package.

The Dissimilarity Object is the representation of the Dissimilarity Matrix. The matrix is symmetric and the diagonal is not interesting, thus the lower triangle is represented by a vector to save storage space. To generate the dissimilarity matrix one must use the daisy function as follows:

##Usage
```R
daisy(x, metric = c("euclidean", "manhattan", "gower"), stand = FALSE, type = list())
```

##Arguments

- x:numeric matrix or data frame. The dissimilarities will be computed between the rows of x.
- metric: character string specifying the metric to be used. The currently available options are "euclidian", which is the default, "manhattan" and "gower".
- stand: logical flag: If the value is true, then the measurements in x are standardized before calculating the dissimilarities.
- type: list specifying some or all of the types of the variables(columns) in x. The options are: "ordratio" (ratio scaled variables treated like ordinary variables), "logicalratio" (ratio scaled variables that must be logarithmically transformed), "asymm" (asymmetric binary variables) and "symm" (symmetric binary variables). Each entry is a vector containing the names or numbers of the corresponding columns of x.
##Return

The function returns a dissimilarity object.

For further information, please refer to the daisy documentation.



#可视化
For the example, we will use the agriculture dataset available in R.

The dissimilarity matrix, using the euclidean metric, can be calculated with the command: daisy(agriculture, metric = "euclidean").

The result the of calculation will be displayed directly in the screen, and if you wanna reuse it you can simply assign it to an object: x <- daisy(agriculture, metric = "euclidean").

The object returned by the daisy function is a dissimilarity object, defined earlier in this text.

To visualize the matrix use the next command: as.matrix(x)

```R
> as.matrix(x)
            B        DK         D        GR         E         F       IRL
B    0.000000  5.408327  2.061553 22.339651  9.818350  3.448188 12.747549
DK   5.408327  0.000000  3.405877 22.570113 11.182576  3.512834 13.306014
D    2.061553  3.405877  0.000000 22.661200 10.394710  2.657066 13.080138
GR  22.339651 22.570113 22.661200  0.000000 12.567418 20.100995  9.604166
E    9.818350 11.182576 10.394710 12.567418  0.000000  8.060397  3.140064
F    3.448188  3.512834  2.657066 20.100995  8.060397  0.000000 10.564563
IRL 12.747549 13.306014 13.080138  9.604166  3.140064 10.564563  0.000000
I    5.803447  5.470832  5.423099 17.383325  5.727128  2.773085  7.920859
L    4.275512  2.220360  2.300000 24.035391 12.121056  4.060788 14.569145
NL   1.649242  5.096077  2.435159 20.752349  8.280097  2.202272 11.150785
P   17.236299 17.864490 17.664088  5.162364  7.430343 15.164432  4.601087
UK   2.828427  8.052950  4.850773 21.485344  8.984431  5.303772 12.103718
            I         L        NL         P        UK
B    5.803447  4.275512  1.649242 17.236299  2.828427
DK   5.470832  2.220360  5.096077 17.864490  8.052950
D    5.423099  2.300000  2.435159 17.664088  4.850773
GR  17.383325 24.035391 20.752349  5.162364 21.485344
E    5.727128 12.121056  8.280097  7.430343  8.984431
F    2.773085  4.060788  2.202272 15.164432  5.303772
IRL  7.920859 14.569145 11.150785  4.601087 12.103718
I    0.000000  6.660330  4.204759 12.515990  6.723095
L    6.660330  0.000000  4.669047 19.168985  7.102112
NL   4.204759  4.669047  0.000000 15.670673  3.124100
P   12.515990 19.168985 15.670673  0.000000 16.323296
UK   6.723095  7.102112  3.124100 16.323296  0.000000
```
To obtain a summary of the data stored in the matrix, you can use: summary(x)
```R
> summary(x)
66 dissimilarities, summarized :
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
 1.6492  4.3569  7.9869  9.5936 13.2500 24.0350
Metric :  euclidean
Number of objects : 12
```
You can also use the dissimilarity matrix in the print method to obtain the lower triangle (the one that matters and is stored) of the matrix:
```R
> print(x)
Dissimilarities :
            B        DK         D        GR         E         F       IRL
DK   5.408327                                                            
D    2.061553  3.405877                                                  
GR  22.339651 22.570113 22.661200                                        
E    9.818350 11.182576 10.394710 12.567418                              
F    3.448188  3.512834  2.657066 20.100995  8.060397                    
IRL 12.747549 13.306014 13.080138  9.604166  3.140064 10.564563          
I    5.803447  5.470832  5.423099 17.383325  5.727128  2.773085  7.920859
L    4.275512  2.220360  2.300000 24.035391 12.121056  4.060788 14.569145
NL   1.649242  5.096077  2.435159 20.752349  8.280097  2.202272 11.150785
P   17.236299 17.864490 17.664088  5.162364  7.430343 15.164432  4.601087
UK   2.828427  8.052950  4.850773 21.485344  8.984431  5.303772 12.103718
            I         L        NL         P
DK                                         
D                                          
GR                                         
E                                          
F                                          
IRL                                        
I                                          
L    6.660330                              
NL   4.204759  4.669047                    
P   12.515990 19.168985 15.670673          
UK   6.723095  7.102112  3.124100 16.323296

Metric :  euclidean
Number of objects : 12
```


#案例分析
To illustrate the Dissimilarity Matrix technique, a simple case study will be shown.



##场景
In the context of species enhancement programs, it is desirable to have very heterogeneous generations, so it is possible to induce the desired characteristics. When trying to induce a giving set of characteristics, it is necessary to choose a parent specimen that will result in the next generations.

Genetic dissimilarity measures have become the interest of many authors (Santos et al., 1997; Gaur et al., 1978; Casler,1995) in characterizing and identifying genetic contributions of different species. As dissimilarity measures to show the genetic variability intensity, the Euclidian distance and the Mahalanobis distance are the most used in plant genetic enhancement programs. The objective is to choose genetic constitutions that may result in superior combinations through their progeny.



##输入参数
The data used here was extracted from MARCHIORO et al. (2003). 18 oat genotypes were measured in many aspects to be later compared. Here we use the measure of days until flowering(DUF) for genotypes subject to fungicides.

```R
Genotype	DUF (days)
UPF 7.	104
UPF 15.	100
UPF 16.	97
UPF 17.	96
UPF 18.	102
UPF 19.	98
UFRGS 7.	95
UFRGS 14.	99
UFRGS 15.	101
UFRGS 16.	101
UFRGS 17.	100
UFRGS 18.	105
UFRGS 19.	92
URS 20.	97
URS 21.	93
IAC 7.	91
OR 2.	97
OR 3.	98
```
This data is the input for the daisy function to calculate the dissimilarity matrix. From the results it is possible to define the best parent to achieve very heterogeneous future generations.


Data construction in R:

DUF <- c(104,100, 97, 96, 102, 98, 95, 99, 101, 101, 100, 105, 92, 97, 93, 91, 97, 98)
Genotype <- c("UPF 7", "UPF 15", "UPF 16", "UPF 17", "UPF 18", "UPF 19", "UFRGS 7", "UFRGS 14", "UFRGS 15", "UFRGS 16", "UFRGS 17", "UFRGS 18", "UFRGS 19", "URS 20", "URS 21", "IAC 7", "OR 2", "OR 3")

myframe <- data.frame(DUF)

rownames(myframe) <- Genotype
##执行
To determine the dissimilarity matrix of the data selected in this case study, use the command below:

dis_mat <- daisy(myframe, metric = "euclidean", stand = FALSE)
##输出
The dissimilarity matrix stored in dis_mat can be visualized as showed below:

```R
> as.matrix(dis_mat)
         UPF 7 UPF 15 UPF 16 UPF 17 UPF 18 UPF 19 UFRGS 7 UFRGS 14 UFRGS 15 UFRGS 16 UFRGS 17 UFRGS 18 UFRGS 19 URS 20 URS 21 IAC 7 OR 2 OR 3
UPF 7        0      4      7      8      2      6       9        5        3        3        4        1       12      7     11    13    7    6
UPF 15       4      0      3      4      2      2       5        1        1        1        0        5        8      3      7     9    3    2
UPF 16       7      3      0      1      5      1       2        2        4        4        3        8        5      0      4     6    0    1
UPF 17       8      4      1      0      6      2       1        3        5        5        4        9        4      1      3     5    1    2
UPF 18       2      2      5      6      0      4       7        3        1        1        2        3       10      5      9    11    5    4
UPF 19       6      2      1      2      4      0       3        1        3        3        2        7        6      1      5     7    1    0
UFRGS 7      9      5      2      1      7      3       0        4        6        6        5       10        3      2      2     4    2    3
UFRGS 14     5      1      2      3      3      1       4        0        2        2        1        6        7      2      6     8    2    1
UFRGS 15     3      1      4      5      1      3       6        2        0        0        1        4        9      4      8    10    4    3
UFRGS 16     3      1      4      5      1      3       6        2        0        0        1        4        9      4      8    10    4    3
UFRGS 17     4      0      3      4      2      2       5        1        1        1        0        5        8      3      7     9    3    2
UFRGS 18     1      5      8      9      3      7      10        6        4        4        5        0       13      8     12    14    8    7
UFRGS 19    12      8      5      4     10      6       3        7        9        9        8       13        0      5      1     1    5    6
URS 20       7      3      0      1      5      1       2        2        4        4        3        8        5      0      4     6    0    1
URS 21      11      7      4      3      9      5       2        6        8        8        7       12        1      4      0     2    4    5
IAC 7       13      9      6      5     11      7       4        8       10        10       9       14        1      6      2     0    6    7
OR 2         7      3      0      1      5      1       2        2        4        4        3        8        5      0      4     6    0    1
OR 3         6      2      1      2      4      0       3        1        3        3        2        7        6      1      5     7    1    0
```
##分析
The output shows that there is a high dissimilarity between the genotypes. This is in agreement with the results in MARCHIORO et al. (2003)[1]. Cross breeding these genotypes, it is possible to achieve high dissimilarity in the next generations, which is very good, since the genetic enhancement program can have more genetic combinations to explore.

#参考
1. MARCHIORO, Volmir Sergio, DE CARVALHO, Fernando Irajá Félix, DE OLIVEIRA, Antônio Costa CRUZ, Pedro Jacinto, LORENCETTI, Claudir, BENIN, Giovani, DA SILVA, José Antônio Gonzales, SCHMIDT, Douglas A. M., GENETIC DISSIMILARITY AMONG OAT GENOTYPES, Ciênc. agrotec., Lavras. V.27, n.2, p.285-294, mar./abr., 2003
2. DA SILVEIRA, Nereida Salette Paulo, HANASHIRO, Darcy Mitiko Mori, Similarity and Dissimilarity between Superiors and Subordinates and Their Implications for Dyadic Relationship Qualit, RAC, Curitiba, v. 13, n. 1, art. 7, p. 117-135, Jan./Mar. 2009
3. [Data Mining Algorithms In R - Wikibooks, open books for an open world](https://en.wikibooks.org/wiki/Data_Mining_Algorithms_In_R)
4. [R Reference Card for Data Mining ](http://www.dainf.ct.utfpr.edu.br/~kaestner/Mineracao/RDataMining/R-refcard-data-mining.pdf)
5. [Data Mining Algorithms In R/Clustering/Dissimilarity Matrix Calculation - Wikibooks, open books for an open world](https://en.wikibooks.org/wiki/Data_Mining_Algorithms_In_R/Clustering/Dissimilarity_Matrix_Calculation)
6. [R: Dissimilarity Matrix Calculation](http://stat.ethz.ch/R-manual/R-patched/library/cluster/html/daisy.html)
[Structural similarity - Wikipedia](https://en.wikipedia.org/wiki/Structural_similarity#Structural_Dissimilarity)
7. [Biçici E, Yuret D. Locally scaled density based clustering[C]//International Conference on Adaptive and Natural Computing Algorithms. Springer, Berlin, Heidelberg, 2007: 739-748.](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.91.6240&rep=rep1&type=pdf)
8. [各种距离算法汇总 - mousever的专栏 - CSDN博客 ](http://blog.csdn.net/mousever/article/details/45967643)
9. [Euclidean distance - Wikipedia ](https://en.wikipedia.org/wiki/Euclidean_distance#Squared_Euclidean_distance)