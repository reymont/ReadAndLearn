library(igraph)
library(ape)
swords<-read.csv('stormofswords.csv',header=TRUE)
g <- graph.data.frame(swords,directed = F)
is.directed(g)
fc <- fastgreedy.community(g)
plot(fc,g)

############################
#“特征向量中心性”和“中间性”#
############################
degree(g)
# Closeness (inverse of average dist)
closeness(g)
betweenness(g)
# Local cluster coefficient
transitivity(g, type="local")
# Eigenvector centrality
evcent(g)$vector
order(degree(g))
order(closeness(g))
order(betweenness(g))
order(evcent(g)$vector)
######
#绘图#
######
lay <- layout.fruchterman.reingold(g)
# Plot the eigevector and betweenness centrality
plot(evcent(g)$vector, betweenness(g))
text(evcent(g)$vector, betweenness(g), 0:100, cex=0.6, pos=4)
#V(g)[32]$color <- 'red'
#V(g)[54]$color <- 'green'
V(g)[32]$color <- rainbow(7)[1]
V(g)[54]$color <- rainbow(7)[2]
V(g)[64]$color <- rainbow(7)[3]
V(g)[17]$color <- rainbow(7)[4]
V(g)[53]$color <- rainbow(7)[5]
V(g)[59]$color <- rainbow(7)[6]
V(g)[62]$color <- rainbow(7)[7]
plot(g, layout=lay, vertex.size=8, vertex.label.cex=0.6)
###


#图表中最长的两点之间距离
diameter(g)
#################
#出/入“度”的分布#
#################
degree.distribution(g)
#[1] 0.135 0.280 0.315 0.110 0.095 0.050 0.005 0.010
plot(degree.distribution(g), xlab="node degree")
lines(degree.distribution(g))
#节点的度
degree(g,v=V(g)["Tyrion"])
degree(g,v=V(g)["Jon"])
degree(g,v=V(g)["Sansa"])

############
#最小生成树#
############
g <- graph.data.frame(swords,directed = F)
plot(g, layout=layout.fruchterman.reingold, edge.label=E(g)$Weight)
mst <- minimum.spanning.tree(g)
plot(mst, layout=layout.reingold.tilford,  edge.label=E(mst)$Weight)


##########
#最短路径#
##########
g <- graph.data.frame(swords,directed = F)
plot(g, layout=layout.fruchterman.reingold)
E(g)["Illyrio|Belwas"]
#pa <- get.shortest.paths(g, 5, 9)[[1]];pa
pa <- get.shortest.paths(g, "Davos", "Val")[[1]];pa
#[[1]]
#+ 4/107 vertices, named:
#[1] Davos      Melisandre Jon        Val  
# V(g)[pa]$color <- 'green'
V(g)["Davos"]$color <- 'green'
V(g)["Melisandre"]$color <- 'green'
V(g)["Jon"]$color <- 'green'
V(g)["Val"]$color <- 'green'
E(g)$color <- 'grey'
#E(g, path=pa)$color <- 'red'
#E(g, path=pa)$width <- 3
E(g, path=c("Davos","Melisandre","Jon","Val"))$color <- 'red'
E(g, path=c("Davos","Melisandre","Jon","Val"))$width <- 3
plot(g, layout=layout.fruchterman.reingold)


#################
#最短路径 as_ids#
#################
g <- graph.data.frame(swords,directed = F)
plot(g, layout=layout.fruchterman.reingold)
E(g)["Illyrio|Belwas"]
pa <- get.shortest.paths(g, "Karl", "Amory")[[1]];pa
mat <- sapply(pa, as_ids);mat
V(g)[mat]$color <- 'green'
E(g)$color <- 'grey'
E(g, path=mat)$color <- 'red'
E(g, path=mat)$width <- 3
plot(g, layout=layout.fruchterman.reingold)


d <- degree(g)
t <- table(d)
#d
#1  2  3  4  5  6  7  8  9 10 12 13 14 15 18 19 20 22 24 25 26 36 
#16 12  8 20 11  9  6  4  1  1  3  1  3  1  3  1  1  1  1  1  2  1
#直接取大于20的d
d[d>20]
#Jaime    Jon   Robb  Sansa Tyrion  Tywin 
#24     26     25     26     36     22
#将d转换为两行
l <- as.list(d)
max(d)
l$Tyrion
#先转为list，再转为data.frame
f <- as.data.frame(d)
f$Tyrion
#编辑data.frame
fnew <- edit(f)

#将d转换为两列，可以使用subset提取值
fd <- as.data.frame(d)
subset(fd,d>10)


#建议breaks
hist(degree(g),breaks= 100)
#精确breaks
d <- degree(g)
length(d)
max(d)
boxplot(d)
plot(d)
#axis轴上显示值
#axis(1, 1:107, attr(d,"names"), col.axis = "blue")
text(d, attr(d,"names"), cex=0.6, pos=4, col="red")
hist(d,breaks=seq(0,50,by=0.5))
hist(d,breaks=seq(0,50,by=0.5),labels=(attr(d,"names")))

b <- betweenness(g)
text(b, attr(b,"names"), cex=0.6, pos=4, col="red")


source("http://michael.hahsler.net/SMU/ScientificCompR/code/map.R")
E(g)$curved <- 0.2 #将连线设成弧线，数值越大弧线越弯
layout=layout.fruchterman.reingold
plot(g, layout=layout, 
     vertex.size=map(degree(g),c(1,20)), 
     vertex.color=map(degree(g),c(1,20))
)


sg1 <- cluster_spinglass(g, spins=3, gamma=1.0)
jpeg(filename='dolphins_commu10.jpg',width=800,height=800,units='px')
layout=layout.circle
plot(g, layout=layout, vertex.size=5, vertex.color= rainbow(10, .8, .8, alpha=.8)[sg1$membership],)
dev.off()