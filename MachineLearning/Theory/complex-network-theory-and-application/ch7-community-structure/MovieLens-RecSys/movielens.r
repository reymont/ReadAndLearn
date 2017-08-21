#http://grouplens.org/datasets/movielens/100k/
library(recommenderlab)
ml100k <- read.table("u.data", header = F, stringsAsFactors = T)
head(ml100k)
ml100k <- ml100k[, -4]
ml100k[,3]
table(ml100k[,3])
prop.table(table(ml100k[,3]))
summary(ml100k[, 3])
ml100k

library(reshape)
ml.useritem <- cast(ml100k, V1 ~ V2, value = "V3")
ml.useritem[1:3, 1:6]

# 在用 recommenderlab 处理数据之前，需将数据转换为 realRatingMatrix 类型，
# 这是 recommenderlab 包中专门针对 1-5 star 的一个新类，需要从 matrix 转换得到。
# 上文获得的 ml.useritem 有两个类属性，其中 cast_df 是不能直接转换为 matrix 的，
# 因此需要去掉这个类属性，只保留 data.frame
class(ml.useritem)
class(ml.useritem) <- "data.frame"    ##只保留data.frame的类属性
ml.useritem <- as.matrix(ml.useritem)
ml.ratingMatrix <- as(ml.useritem, "realRatingMatrix")  ##转换为realRatingMatrix
ml.ratingMatrix

#ml.ratingMatrix 是可以用 recommenderlab 进行处理的 realRatingMatrix，
#943 是 user 数，1682 指的是 item 数, realRatingMatrix 
# 可以很方便地转换为 matrix 和 list
as(ml.ratingMatrix , "matrix")[1:3, 1:10]
as(ml.ratingMatrix , "list")[[1]][1:10]

# 建立推荐模型
ml.recommModel <- Recommender(ml.ratingMatrix[1:800], method = "IBCF")
ml.recommModel
##TopN推荐，n = 5 表示Top5推荐
ml.predict1 <- predict(ml.recommModel, ml.ratingMatrix[801:803], n = 5)
ml.predict1
#Recommendations as ‘topNList’ with n = 5 for 3 users.
as( ml.predict1, "list")  ##显示三个用户的Top5推荐列表
##用户对item的评分预测
ml.predict2 <- predict(ml.recommModel, ml.ratingMatrix[801:803], type = "ratings")
ml.predict2
## 查看三个用于对M1-6的预测评分
## 注意：实际的预测评分还要在此基础上加上用户的平均评分
as(ml.predict2, "matrix")[1:3, 2:7]

################
#recommenderlab#
################
library("recommenderlab")
data("MovieLense")
### use only users with more than 100 ratings
MovieLense100 <- MovieLense[rowCounts(MovieLense) >100,]
MovieLense100

train <- MovieLense100[1:50]
rec <- Recommender(train, method = "UBCF")
rec

pre <- predict(rec, MovieLense100[101:102], n = 10)
pre

as(pre, "list")
