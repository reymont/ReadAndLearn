
Linux之shred命令彻底粉碎删除文件 - 老徐的私房菜 - 51CTO技术博客 
http://laoxu.blog.51cto.com/4120547/1299931

在linux系统中使用rm删除命令去删除一个文件只是将文件的inode回收，并不是说将block彻底清除，具体可以参考我之前的博文“深入理解linux文件系统”。
rm命令的删除我们是可以在被删除文件的分区没有被重写入新数据前，用类似ext3grep、photorec等工具恢复的，那么如果想彻底删除一个文件呢？
使用shred命令，在ext3/ext4的data=ordered(default)anddata=writeback模式下，shred同样适用。
#shred-f-u-v-z文件名

-f change permissions to allow writing if necessary
-u truncate and remove file after overwriting
-v be verbose(detailed) and show progress
-z add a final overwrite with zeros to hide shredding
#shred-f-u-z-vtest.txt
095301553.jpg
虽然shred命令可以安全的从硬盘上擦除数据，但是注意它不能用在坏的扇区上，另外shred命令接一个完整的分区路径比接一个文件名更保险，因为有些类型的文件系统会保留备份，而往往shred命令是不会去删除这些备份文件的。
#shred/dev/sda1
本文出自 “老徐的私房菜” 博客，谢绝转载！