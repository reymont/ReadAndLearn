

https://archive.apache.org/dist/hadoop/common/hadoop-1.2.1/hadoop-1.2.1.tar.gz

实验环境：
Hadoop-1.2.1
Mahout0.6
Pig0.12.1
Ubuntu12
Jdk1.7

http://172.20.62.34:50070/dfshealth.jsp
http://172.20.62.34:50075/browseDirectory.jsp?namenodeInfoPort=50070&dir=/

### https://blog.csdn.net/sofuzi/article/details/80439400
### 1. 上传文件
# sport文件夹：
    # 用于训练文本分类器
    # 包含了多个子文件夹，每个子文件夹都是一个分类的文章
    # 在现实项目中，该原始数据需要人工收集
# user-sport：
    # 待分类的文本
hadoop dfs -put sport /dataguru/week8
hadoop dfs -put user-sport/ /dataguru/week8


hadoop jar MRTokenize.jar tokenize.TokenizeDriver /dataguru/week8/sport /dataguru/week8/fenciout