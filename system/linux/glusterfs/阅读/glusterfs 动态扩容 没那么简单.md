

glusterfs 动态扩容 没那么简单 - CSDN博客 
http://blog.csdn.net/baidu_17173809/article/details/49805309

glusterfs 号称 是不中断业务扩容，意思是在后台做扩容操作的时候不影响客户端的访问。原来一直没有细看这一块代码，最近同事在afr层修改一些代码的时候，遇到问题就是按glusterfs架构思路写的代码，把一些需要记录的信息存放在inode 的ctx里面，然而一做扩容或者其他需要改变graph 树的时候就会出问题，发现设置在inode 里面的ctx 没了，父目录也没有做lookup操作，导致原有的处理逻辑乱了。
后来研究了一下客户端收到扩容后的操作，简单的说就是，服务端扩容后会给客户端发送卷配置文件有改变，然后客户端会重新向服务的getspec 获取volfile，然后进行重新生成graph ，和旧的graph进行对比，如果graph结构没变，就只reconfigure 就ok，这流程很简单，如果比较 graph 结构变化，则要重新init graph ，意味着以后发下去的操作就要走新的graph树流程了。但是原来client 缓存的fd table 和inode table 信息呢，这些缓存信息该怎么处理呢？据代码看 inode 是新申请了一个inodetable，fd table 会去同步原来的fd table ，由于 fd 关系着客户端正在操作，读写文件啊，和readdir 啊，由于做了同步fd ，所以不会影响那些操作。然而由于全部废掉了原来缓存的inode信息，再根据fuse 的特性，是肯定会影响客户端的元数据操作的。例如在扩容前，cd 到一个目录，扩容后在那目录ls 原来的文件，会发现找不到那个目录，由于他不会从/目录开始发lookup，fuse以为还缓存着这文件的父目录，所以 这之间的矛盾会引起客户端访问文件元数据失败。
值得思考的是 为什么没有重新缓存node 呢？由于缓存太多的inode 的时候 重新发 lookup 时间长 影响客户端阻塞。还是glusterfs 团队没考虑到 上面那点问题。 