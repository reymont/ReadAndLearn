(4条消息)python中numpy模块下函数array()和mat()的区别 - Build_Tiger的博客 - CSDN博客 https://blog.csdn.net/Build_Tiger/article/details/79848808

1. mat()函数与array()函数生成矩阵所需的数据格式有区别

(1) mat()函数中数据可以为字符串以分号(；)分割，或者为列表形式以逗号（，）分割。而array()函数中数据只能为后者形式。

如mat()函数生成矩阵时一下两种方式都正确。

  和   

(2) 而array()函数生成矩阵时数据只能为列表形式。



2. mat()函数与array()函数生成的矩阵计算方式不同

(1) mat()函数中矩阵的乘积可以使用（星号） *  或 .dot()函数，其结果相同。而矩阵对应位置元素相乘需调用numpy.multiply()函数。

(2) array()函数中矩阵的乘积只能使用 .dot()函数。而星号乘 （*）则表示矩阵对应位置元素相乘，与numpy.multiply()函数结果相同。

如生成以下矩阵：

a = numpy.mat([[1, 3], [5, 7]])
b = numpy.mat([[2, 4], [6, 8]])
c = numpy.array([[1, 3], [5, 7]])

d = numpy.array([[2, 4], [6, 8]])

则 a * b = a.dot(b) = c.dot(d) ，其表示矩阵相乘。

而 numpy.multiply(a, b) = c * d = numpy.multiply(c, d) ，其表示矩阵对应位置元素相乘。
--------------------- 
作者：Build_Tiger 
来源：CSDN 
原文：https://blog.csdn.net/Build_Tiger/article/details/79848808 
版权声明：本文为博主原创文章，转载请附上博文链接！