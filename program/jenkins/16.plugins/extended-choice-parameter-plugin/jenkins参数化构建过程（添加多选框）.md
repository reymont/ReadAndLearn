

jenkins参数化构建过程（添加多选框） - 起个名字好难啊 - CSDN博客 
http://blog.csdn.net/e295166319/article/details/54017231?locationNum=9&fps=1


1.首先增加Jenkisn插件
https://wiki.jenkins-ci.org/display/JENKINS/Extended+Choice+Parameter+plugin 

需要安装插件“Extended Choice Parameter plugin”,它可以扩展参数化构建过程，直接在管理界面增加。 
比如一个工程下面有多个服务的时候需要参数部署，比如maven下面有多个soa服务。需要增量部署，而不是全部部署。

2.配置jenkins
\

在配置value的时候可以选择默认值。 
\
配置执行脚本，打印出DEMO_PARMS的值。这个时候jenkins直接把参数传递过去，所以配置参数的name必须是个英文字母，用$DEMO_PARMS打印。 
\
这个时候默认就变成参数构建了。可以使用checkbox进行任意选择了。 
\
打印的结果是按照checkbox选择的值。 
\



3.使用参数构建

点击左侧的Build with Parameters，填写右侧的参数（和配置里的一致）。然后点击开始构建即可


查看构建的历史记录，会有一个Parameters来显示此次构建使用的参数，方便查看


4.总结
jenkins可以通过参数化构建，使用checkbox进行界面选择。极大方便了开发部署。参数是一次传递过去的。而且是用逗号进行分割的。后续需要使用shell脚本或Python进行处理。 
可以直接使用sed命令进行字符串替换。

[java] view plain copy
<code class=" hljs bash">DEMO_PARMS=`echo $DEMO_PARMS | sed -r 's/"//g'`  
DEMO_PARMS=`echo $DEMO_PARMS | sed -r 's/,/ /g'`</code>  
首先替换引号，然后替换逗号成空格。方便shell进行循环。