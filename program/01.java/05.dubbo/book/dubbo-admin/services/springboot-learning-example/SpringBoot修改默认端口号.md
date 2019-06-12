
# http://blog.csdn.net/zknxx/article/details/53433592

application.properties中加这样的一句话就可以了：server.port=8004

使用命令行参数

如果你只是想在启动的时候修改一次端口号的话，可以用命令行参数来修改端口号。配置如下：java -jar 打包之后的SpringBoot.jar  --server.port=8000
使用虚拟机参数

你同样也可以把修改端口号的配置放到JVM参数里。配置如下：-Dserver.port=8009。 这样启动的端口号就被修改为8009了。