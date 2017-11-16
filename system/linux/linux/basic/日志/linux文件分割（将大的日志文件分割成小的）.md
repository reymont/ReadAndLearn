

linux文件分割（将大的日志文件分割成小的） - waynechen - 博客园 
http://www.cnblogs.com/waynechen/archive/2010/07/26/1785097.html

linux下文件分割可以通过split命令来实现，可以指定按行数分割和安大小分割两种模式。Linux下文件合并可以通过cat命令来实现，非常简单。

　　在Linux下用split进行文件分割：
　　模式一：指定分割后文件行数
　　对与txt文本文件，可以通过指定分割后文件的行数来进行文件分割。
　　命令：split -l 300 large_file.txt new_file_prefix
　　模式二：指定分割后文件大小
 split -b 10m server.log waynelog

对二进制文件我们同样也可以按文件大小来分隔。

 

在Linux下用cat进行文件合并：

　　命令：cat small_files* > large_file