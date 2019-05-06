


setwd("E:/workspace/r/data")
#导入数据和数据清洗
creditcard_exp<-read.csv("creditcard_exp.csv")
creditcard_exp<-na.omit(creditcard_exp)

#5.3 两样本T检验
#tapply
#根据性别比较支出.
attach(creditcard_exp)

#5.5 相关分析
#散点图
plot(Income,avg_exp)

#相关性分析:“spearman”,“pearson” 和 "kendall",
cor.test(Income,avg_exp,method="pearson")
cor.test(Income,avg_exp,method="spearman")