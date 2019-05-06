

* [R语言：recommenderlab包的总结与应用案例（1） ](https://www.douban.com/note/426945916/)

```r
library(recommenderlab)
library(ggplot2)

##数据处理与数据探索性分析

data(MovieLense)
image(MovieLense)
# 获取评分
ratings.movie <- data.frame(ratings = getRatings(MovieLense))
summary(ratings.movie$ratings)
## Min. 1st Qu. Median Mean 3rd Qu. Max. 
## 1.00 3.00 4.00 3.53 4.00 5.00

ggplot(ratings.movie, aes(x = ratings)) + geom_histogram(fill = "beige", color = "black", 
    binwidth = 1, alpha = 0.7) + xlab("rating") + ylab("count")


# 标准化
ratings.movie1 <- data.frame(ratings = getRatings(normalize(MovieLense, method = "Z-score")))
summary(ratings.movie1$ratings)
## Min. 1st Qu. Median Mean 3rd Qu. Max. 
## -4.850 -0.647 0.108 0.000 0.751 4.130
ggplot(ratings.movie1, aes(x = ratings)) + geom_histogram(fill = "beige", color = "black", 
    alpha = 0.7) + xlab("rating") + ylab("count")


# 用户的电影点评数
movie.count <- data.frame(count = rowCounts(MovieLense))
ggplot(movie.count, aes(x = count)) + geom_histogram(fill = "beige", color = "black", 
    alpha = 0.7) + xlab("counts of users") + ylab("counts of movies rated")


rating.mean <- data.frame(rating = colMeans(MovieLense))
ggplot(rating.mean, aes(x = rating)) + geom_histogram(fill = "beige", color = "black", 
    alpha = 0.7) + xlab("rating") + ylab("counts of movies ")


##推荐算法的情况

# 先看可以使用的方法
recommenderRegistry$get_entries(dataType = "realRatingMatrix")
#对于realRatingMatrix有六种方法：IBCF(基于物品的推荐)、UBCF（基于用户的推荐）、SVD（矩阵因子化）、PCA（主成分分析）、 RANDOM（随机推荐）、POPULAR（基于流行度的推荐）
#利用前940位用户建立推荐模型 

m.recomm <- Recommender(MovieLense[1:940], method = "IBCF")
m.recomm


#对后三位用户进行推荐预测，使用predict()函数，默认是topN推荐，这里取n=3。预测后得到的一个topNList对象，可以把它转化为列表，看预测结果。
(ml.predict <- predict(m.recomm, MovieLense[941:943], n = 3))
str(ml.predict)
as(ml.predict, "list")#预测结果


#代码示例

library(recommenderlab)
data(MovieLense)
scheme <- evaluationScheme(MovieLense, method = "split", train = 0.9, k = 1, 
    given = 10, goodRating = 4)
algorithms <- list(popular = list(name = "POPULAR", param = list(normalize = "Z-score")), 
    ubcf = list(name = "UBCF", param = list(normalize = "Z-score", method = "Cosine", 
        nn = 25, minRating = 3)), ibcf = list(name = "IBCF", param = list(normalize = "Z-score")))
results <- evaluate(scheme, algorithms, n = c(1, 3, 5, 10, 15, 20))
plot(results, annotate = 1:3, legend = "topleft") #ROC
plot(results, "prec/rec", annotate = 3)#precision-recall

# 按照评价方案建立推荐模型
model.popular <- Recommender(getData(scheme, "train"), method = "POPULAR")
model.ibcf <- Recommender(getData(scheme, "train"), method = "IBCF")
model.ubcf <- Recommender(getData(scheme, "train"), method = "UBCF")
# 对推荐模型进行预测
predict.popular <- predict(model.popular, getData(scheme, "known"), type = "ratings")
predict.ibcf <- predict(model.ibcf, getData(scheme, "known"), type = "ratings")
predict.ubcf <- predict(model.ubcf, getData(scheme, "known"), type = "ratings")
# 做误差的计算
predict.err <- rbind(calcPredictionError(predict.popular, getData(scheme, "unknown")), 
    calcPredictionError(predict.ubcf, getData(scheme, "unknown")), calcPredictionError(predict.ibcf, 
        getData(scheme, "unknown")))
rownames(predict.err) <- c("POPULAR, "UBCF", "IBCF")
predict.err

#calcPredictionError（）的参数“know”和“unknow”表示对测试集的进一步划分：“know”表示用户已经评分的，要用来预测的items；“unknow”表示用户已经评分，要被预测以便于进行模型评价的items。
```


* [R语言：recommenderlab包评估代码解读（2） ](https://www.douban.com/note/435041153/)