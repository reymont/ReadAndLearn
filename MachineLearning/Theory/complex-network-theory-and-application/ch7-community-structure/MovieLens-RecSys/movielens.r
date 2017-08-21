#http://grouplens.org/datasets/movielens/100k/

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
class(ml.useritem)
class(ml.useritem) <- "data.frame"    ##只保留data.frame的类属性
ml.useritem <- as.matrix(ml.useritem)
ml.ratingMatrix <- as(ml.useritem, "realRatingMatrix")  ##转换为realRatingMatrix
ml.ratingMatrix
as(ml.ratingMatrix , "matrix")[1:3, 1:10]


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
