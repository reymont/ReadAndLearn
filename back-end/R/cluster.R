#层次聚类
x=runif(10)
y=runif(10)
S=cbind(x,y);S                                #得到2维的数组
rownames(S)=paste("Name",1:10,"")             #赋予名称，便于识别分类
out.dist=dist(S,method="euclidean")           #数值变距离
out.hclust=hclust(out.dist,method="complete") #根据距离聚类
plclust(out.hclust)                           #对结果画图
rect.hclust(out.hclust,k=3)                   #用矩形画出分为3类的区域
out.id=cutree(out.hclust,k=3)                 #得到分为3类的数值