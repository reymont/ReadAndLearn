#%%
#1  文本中获取特征
#coding:utf-8
from numpy import *
import sys
# sys.path.append("E:\....")

##从文本中构建向量
def loadDataSet():
    postingList=[['my', 'dog', 'has', 'flea', 'problems', 'help', 'please'],
                 ['maybe', 'not', 'take', 'him', 'to', 'dog', 'park', 'stupid'],
                 ['my', 'dalmation', 'is', 'so', 'cute', 'I', 'love', 'him'],
                 ['stop', 'posting', 'stupid', 'worthless', 'garbage'],
                 ['mr', 'licks', 'ate', 'my', 'steak', 'how', 'to', 'stop', 'him'],
                 ['quit', 'buying', 'worthless', 'dog', 'food', 'stupid']]
    classVec = [0,1,0,1,0,1]    ##分别表示标签
    return postingList,classVec ##返回输入数据和标签向量
                 
def createVocabList(dataSet):
    vocabSet = set([])
    for document in dataSet:
        vocabSet = vocabSet | set(document) # 两个集合的并集
    return list(vocabSet)##输出不重复的元素

def setOfWords2Vec(vocabList, inputSet):###判断了一个词是否出现在一个文档当中。
    returnVec = [0]*len(vocabList)
    for word in inputSet:
        if word in vocabList:
            returnVec[vocabList.index(word)] = 1
        else: print ("the word: %s is not in my Vocabulary!" % word)
    return returnVec###输入中的元素在词汇表时，词汇表相应位置为1，否则为0

#测试
dataSet,classes = loadDataSet()
print(dataSet)
vocabList = createVocabList(dataSet)
print(vocabList)
setWordsVec = setOfWords2Vec(vocabList,dataSet[0])
print(setWordsVec)
#%%
#1.2  得到每个特征的条件概率
#原始的计算需要多项相乘，这样如果其中一项为0 ，则影响整体，因此初始化数据分子为1分母为2
#令一种情况为下溢出问题，即一些很小的数据相乘四舍五入会得到0结果，因此一种处理方法为取对数
def trainNB0(trainMatrix,trainCategory):
   numTrainDocs = len(trainMatrix)#取行6
   numWords = len(trainMatrix[0])#取列32
   pAbusive = sum(trainCategory)/float(numTrainDocs)#出现侮辱性文档的概率，包含侮辱性句子/所有句子
   p0Num = zeros(numWords)#生成一个包含单词个数的列表，值均为0
   p1Num = zeros(numWords)  #生成一个包含单词个数的列表，值均为0    #change to ones() 
   p0Denom = 0.0
   p1Denom = 0.0                      #change to 2.0
   for i in range(numTrainDocs):
       if trainCategory[i] == 1:#类别为1
           p1Num += trainMatrix[i]#各变量均增加1
           p1Denom += sum(trainMatrix[i])#每次变量中发生的次数
       else:
           p0Num += trainMatrix[i]
           p0Denom += sum(trainMatrix[i])
   p1Vect = p1Num/p1Denom        #change to log()
   p0Vect = p0Num/p0Denom         #change to log()
   return p0Vect,p1Vect,pAbusive

dataSet,classes = loadDataSet()
vocabList = createVocabList(dataSet)
trainMat = []
for item in dataSet:
    print(item)
    trainMat.append(setOfWords2Vec(vocabList,item))

#%%
print (trainMat[0])
print (sum(trainMat[0]))

print (trainMat)
print (classes)
p0v,p1v,pAb = trainNB0(trainMat,classes)
print(p0v)
print(p1v)
print(pAb)

#%%
