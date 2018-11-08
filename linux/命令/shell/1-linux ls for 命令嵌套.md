
# https://my.oschina.net/ois/blog/496916?p={{currentPage+1}}

for i in  `ls` ;do echo $i;done

简单，妙，组合了 ls  和 for ，还可以继续组合......

批量解压： for i in  `ls` ;do tar -xzvf  $i;done

# https://www.cnblogs.com/nizuimeiabc1/p/5593637.html
for i in `ps -e | grep java | awk '{print $1}'`;do echo $i;pstree -p $i|wc -l; done
pstree -p |wc -l