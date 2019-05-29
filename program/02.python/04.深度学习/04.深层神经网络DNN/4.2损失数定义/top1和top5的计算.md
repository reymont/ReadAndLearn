

1. top1 和top5的计算
    1. top1就是你预测的label取最后概率向量里面最大的那一个作为预测结果，如过你的预测结果中概率最大的那个分类正确，则预测正确。否则预测错误
    2. top5就是最后概率向量最大的前五名中，只要出现了正确概率即为预测正确。否则预测错误。

## 参考

1. [深度学习：混淆矩阵，准确率，top1，top5，每一类的准确率](https://blog.csdn.net/shanshangyouzhiyangM/article/details/84943011)