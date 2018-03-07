Jenkins 修改时区 - CSDN博客 http://blog.csdn.net/Jasonliujintao/article/details/70796620

Jenkins 修改时区

最近配置jenkins 碰到了，时区的问题。
上网找了一下，其实官网上有几种办法可以解决。
jenkins 修改时区
这里说一种更简单的直接办法肯定都会生效的： 
vim ~/.bashrc 
添加以下三种配置之一

export JAVA_ARGS="-Dorg.apache.commons.jelly.tags.fmt.timeZone=Asia/Shanghai"
JENKINS_JAVA_OPTIONS="-Dorg.apache.commons.jelly.tags.fmt.timeZone=Asia/Shanghai"
JENKINS_JAVA_OPTIONS="-Duser.timezone=Asia/Shanghai"
上面三个任选一种都可以，然后保存退出

source ~/.bashrc
重启 Jenkins 之后就生效了
版权声明：本文为博主原创文章，未经博主允许不得转载。 http://blog.csdn.net/Jasonliujintao/article/details/70796620