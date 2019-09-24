linux 下 xargs 命令的 n1 参数

今天碰到个小问题：想批量解压 *.tar.gz 文件。 
一开始，尝试了这些：

tar -zxvf *.tar.gz                ## 报错
ls *.tar.gz | xargs tar -zxvf     ## 报错
后来，查了资料，xargs 命令加上 n1 参数后，成功。

ls *.tar.gz | xargs -n1 tar -zxvf

## -n1 ：表示每次只传递一个参数
借用网上的例子，一目了然：

echo 1 2 3 4 | xargs -n1
##output:
1
2
3
4

echo 1 2 3 4 | xargs -n2
##output:
1 2
3 4

echo 1 2 3 4 | xargs -n3
##output:
1 2 3
4

 转载至链接:https://my.oschina.net/u/3314358/blog/2231231。
