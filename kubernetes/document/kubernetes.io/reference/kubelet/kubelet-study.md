


* [Kubernetes之kubectl常用命令 - 酱油蔡的酱油坛 - CSDN博客 ](http://blog.csdn.net/xingwangc2014/article/details/51204224)

# create

kubectl命令用于根据文件或输入创建集群resource。如果已经定义了相应resource的yaml或son文件，直接kubectl create -f filename即可创建文件内定义的resource。也可以直接只用子命令[namespace/secret/configmap/serviceaccount]等直接创建相应的resource。从追踪和维护的角度出发，建议使用json或yaml的方式定义资源。 

# apply

apply命令提供了比patch，edit等更严格的更新resource的方式。通过apply，用户可以将resource的configuration使用source control的方式维护在版本库中。每次有更新时，将配置文件push到server，然后使用kubectl apply将更新应用到resource。kubernetes会在引用更新前将当前配置文件中的配置同已经应用的配置做比较，并只更新更改的部分，而不会主动更改任何用户未指定的部分。 

apply命令的使用方式同replace相同，不同的是，apply不会删除原有resource，然后创建新的。apply直接在原有resource的基础上进行更新。同时kubectl apply还会resource中添加一条注释，标记当前的apply。类似于git操作。 
