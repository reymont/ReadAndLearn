
http://blog.csdn.net/ppby2002/article/details/38843445

http://blog.chinaunix.net/uid-7242899-id-2060739.html

find和xargs是最好的组合，可以说是linux shell下的瑞士军刀，用xargs配合find，比直接用find的-exec参数，速度更快，用法也更直观。
基本的用法比如：
find ./ -name '*.bak' | xargs rm -rf

一般情况，上面这个命令运行的很好，但是如果找到的文件名代空格上面的命令运行就可能会出问题了有一个参数-print0，于默认的-print相比，`输出的序列不是以空格分隔，而是以null字符分隔`。而xargs也有一个参数-0，可以`接受以null而非空格间隔的输入流`。所以说xargs简直就是为find而生的。上面的问题就很好解决了：

 `find ./ -name '*.bak' -print0 | xargs -0 rm -rf`