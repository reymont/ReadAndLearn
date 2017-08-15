library(igraph)
library(ape)
g <- graph.formula(1-2, 1-3, 2-1, 2-3, 2-4, 3-1, 3-2, 4-2, 4-5, 4-6, 5-4, 5-6, 6-4, 6-5)
fc <- fastgreedy.community(g)
plot(fc,g)
dendPlot(fc, mode="hclust")
d <- as.dendrogram(fc)
str(d)

#边合并
fc$merges

#par(mfrow=c(2,3))
#colors <- rainbow(10)
#plot(g, vertex.color=colors[cutat(fc,2)],layout=layout.circle)
#plot(g, vertex.color=colors[cutat(fc,3)],layout=layout.circle)
#plot(g, vertex.color=colors[cutat(fc,4)],layout=layout.circle)
#plot(g, vertex.color=colors[cutat(fc,5)],layout=layout.circle)
#plot(g, vertex.color=colors[cutat(fc,6)],layout=layout.circle)
#plot(g, vertex.color=colors[cutat(fc,7)],layout=layout.circle)


#模拟计算
dg <- degree(g)
#(1-(dg[[1]]*dg[[2]]))/ecount(g)
#(0-(dg[[1]]*dg[[3]]))/ecount(g)
#(0-(dg[[1]]*dg[[4]]))/ecount(g)
#(0-(dg[[1]]*dg[[5]]))/ecount(g)
#(0-(dg[[1]]*dg[[6]]))/ecount(g)
#(0-(dg[[1]]*dg[[7]]))/ecount(g)
#(1-(dg[[2]]*dg[[3]]))/ecount(g)
#(1-(dg[[2]]*dg[[4]]))/ecount(g)

c <- 0
m <- c()
am <- get.adjacency(g)
mm <- as.matrix(am)
for(i in 1:6){
	for(j in 1:6){
		c <- c+1
		m[c] <- (mm[i,j]-(dg[[i]]*dg[[j]]))/ecount(g)
		print (paste(i," -> ",j,(1-(dg[[i]]*dg[[j]]))/ecount(g)," num[",c,"]"))
	}
}
m
matrix(m,nrow=6,ncol=6,byrow=T)