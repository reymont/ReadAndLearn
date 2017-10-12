

* [深入kubernetes调度之Taints和Tolerations - VF@CSDN - CSDN博客 ](http://blog.csdn.net/tiger435/article/details/73650174 )


Master上定义一个污点A（Taints）禁止Pod调度，Dashboard的yaml里定义一个容忍（Tolerations）允许A污点，所以可以调度到Master节点上。