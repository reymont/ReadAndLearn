

echo "djdkfalfjakfjak dfdfdf   doioio  111 doioio"|sed 's/.*doioio/doioio/'

#删除ibuyitemid之前的数据，删除ibuyitemtype之后的数据
tail 1|sed 's/.*+ibuyitemid://'|sed 's/+ibuyitemtype.*//'
#去重
cat 1|sed 's/.*+ibuyitemid://'|sed 's/+ibuyitemtype.*//'|uniq