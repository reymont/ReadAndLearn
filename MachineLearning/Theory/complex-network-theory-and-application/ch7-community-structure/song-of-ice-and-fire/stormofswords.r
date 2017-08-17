library(igraph)
library(ape)
swords<-read.csv('stormofswords.csv',header=TRUE)
g <- graph.data.frame(swords,directed = F)
is.directed(g)
fc <- fastgreedy.community(g)

source("http://michael.hahsler.net/SMU/ScientificCompR/code/map.R")
E(g)$curved <- 0.2 #将连线设成弧线，数值越大弧线越弯
layout=layout.fruchterman.reingold
plot(g, layout=layout, 
     vertex.size=map(degree(g),c(1,20)), 
     vertex.color=map(degree(g),c(1,20))
)
