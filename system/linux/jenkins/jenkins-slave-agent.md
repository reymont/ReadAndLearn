

* [[原创] Jenkins slave agent 分布式构建 - H@H@ - 博客园 ](http://www.cnblogs.com/GGHHLL/p/3251524.html)

Jenkins 通过 manage nodes 实现了 分布式构建.

1. Add nodes 
      1).  ‘Remote FS root’ （在slave机器上腾出一个空文件夹，jenkins在分布构建时会remote并copy相应的文件至此）
      2). `并且为该slave指定lable，并在job配置页面设置运行的节点`
           

2.  slave和master的通信，jenkins提供了的四种途径：

 若slave为Unix/Mac, 果断通过 SSH，即上图的第一种方式。 也是最简单的方式，此处略。
 若slave为windows， 只能下面三种，不过我建议第二种，只要在windows机器上运行jnlp脚本（required java6++）连通jenkins，如下提示了3种运行方式：

 此处注意，确保你jenkins-system config中设置 jenkins URL 不是localhost，而是如上ip 或者 hostname，因slave运行jnlp时只认config中设置的URL。

若你使用前2种 launch agent，成功后会提示connected，此时点击 file-> Install as Windows Service

                                

你差不多猜到这么作为service的好处了，不用每次在windows重启后还要launch agent，这样作为服务可以开机自启动。

 