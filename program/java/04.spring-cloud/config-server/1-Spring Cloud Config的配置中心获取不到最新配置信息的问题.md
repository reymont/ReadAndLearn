Spring Cloud Config的配置中心获取不到最新配置信息的问题 | 程序猿DD http://blog.didispace.com/spring-cloud-tips-config-tmp-clear/

问题描述

之前有朋友提出Spring Cloud Config的配置中心在运行一段时间之后，发现修改了配置信息，但是微服务应用并拿不到新的配置内容。同时，发现配置中心存储配置的目录/tmp 的配置内容被清空了。

原因与解决

首先，分析一下上面的问题，其实已经有一定的线索。表面现象是微服务从配置中心获取配置信息的时候获取不到最新的配置，而其根本原因就是在/tmp目录下的缓存仓库已经被清空了，所以导致无法正常的通过Git获取到最新配置，那么自然各个微服务应用就无法获取最新配置了。

其实该问题在Spring Cloud的官方文档中也有对应的说明，原文如下：

With VCS based backends (git, svn) files are checked out or cloned to the local filesystem. By default they are put in the system temporary directory with a prefix of config-repo-. On linux, for example it could be /tmp/config-repo-<randomid>. Some operating systems routinely clean out temporary directories. This can lead to unexpected behaviour such as missing properties. To avoid this problem, change the directory Config Server uses, by setting spring.cloud.config.server.git.basedir or spring.cloud.config.server.svn.basedir to a directory that does not reside in the system temp structure.

根据上面的内容，我们可以知道在某些系统中，对于/tmp目录进行周期性的清理，所以也就有了上面所说的问题。

从文档中我们也已经知道如果去解决该问题，无非就是通过spring.cloud.config.server.git.basedir 或spring.cloud.config.server.svn.basedir参数来指定一个不会被定期清理的目录。比如，我们可以设置：

spring.cloud.config.server.git.basedir=config-repo
其他问题

这里需要注意一下，该参数的设置依然有一定的问题。按理解，如上配置的话，应该是在配置中心程序所在的目录下创建一个config-repo目录来进行存储。但是，在测试了Dalston SR1和SR2版本之后，发现该配置只会将内容存储到配置中心程序的同一级目录下，并不会创建一个config-repo目录。

但是，如果我们这样设置，就可以将配置的缓存内容存储在配置中心所在目录下的config-repo目录中了：

spring.cloud.config.server.git.basedir=config-repo/config-repo
