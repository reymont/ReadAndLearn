


支持 Grafana 视图展现 | Open-Falcon 
https://book.open-falcon.org/zh/dev/support_grafana.html

支持 Grafana 视图展现
相较于 Open-Falcon 内建的 Dashboard，Grafana 可以很有弹性的自定义图表，并且可以针对 Dashboard 做权限控管、上标签以及查询，图表的展示选项也更多样化。本篇教学帮助您 做好 Open-Falcon 的面子工程！
开始之前
Open-Falcon 跟 Grafana 目前并不互相支持，所以您需要下面的PR
•	Grafana PR#3787 (支持到 v2.6 版)
•	Query PR#5（已合并到最新的query代码中了，请检查您是否使用的是最新版)
详细可以参考优酷同学写的教程
设定 Datasource
当您取得包含上述 PR 的 Grafana 源代码之后，按照官方教学安装后依下述步骤编译：
1.	编译前端代码 go run build.go build
2.	编译后端代码 grunt
3.	执行 grafana-server
启动 Grafana 后，依照下图添加新的 Open-Falcon Datasource，需要注意的是我们这里使用的 URL 是在 falcon-query 中新增的 API。
 
新增 Templating 变量
当 Open-Falcon 中已经有上百台机器时，一个个新增监控项到图表中是不切实际的，所以 Grafana 提供了一个 Templating 的变量让我们可以动态地选择想要关注的机器。
1.	上方设定点击 Templating  
2.	新增 Templating 变量  
新增圖表
有了 Templating 变量之后，我们就可以以它来代替 Endpoint 名称，选择我们关注的监控项，完成图表的新增。
 



Open-falcon上搭建Grafana - blueswind8306 - ITeye技术网站 
http://blueswind8306.iteye.com/blog/2287561

背景需求 
Open-falcon本身自带的dashboard感觉功能不够强大，希望能够接入Grafana做更加丰富、灵活的图形展现。整个安装过程由于在公司服务器上安装，一些依赖包被墙，弄的比较折腾，所以把整个安装过程记录下来。希望对更多的人有帮助。 

系统环境及软件版本 

•	操作系统：CentOS 6.6
•	内核版本：2.6.32-504.el6.x86_64
•	Open-falcon版本：0.1.0
•	Grafana版本：PR#3787的patch版本，基于Grafana-2.6


参考资料 

•	Open-falcon支持Grafana的帮助文档
•	Grafana官方安装文档


Go的安装 
在以下地址可以下载到Go，注意Grafana-2.6需要的Go最低版本是1.5，我安装的版本是Go1.5.3 
http://golangtc.com/download 

我将go安装到/opt/gohome/go目录下，并且指一个软链/opt/gohome/default到这个目录，方便未来升级go版本： 
Shell代码   
1.	ln -s /opt/gohome/go /opt/gohome/default  


创建工作目录： 
Shell代码   
1.	mkdir /opt/gohome/workspace  


增加环境变量： 
Shell代码   
1.	vi /etc/profile：  
2.	export GOROOT=/opt/gohome/default  
3.	export GOPATH=/opt/gohome/workspace  
4.	export PATH=$GOROOT/bin:$GOPATH/bin:$PATH  
5.	  
6.	source /etc/profile  


检查安装好以后的go版本： 
Shell代码   
1.	$ go version  
2.	go version go1.5.3 linux/amd64  



nodejs的安装 
nodejs安装很简单，直接通过官网下载二进制包，解压并指一下环境变量就好了 


Grafana的安装 
由于需要安装的Grafana必须是PR#3787的patch才能支持open-falcon，所以我直接通过github下载了这个PR提交者fork的分支代码（因为这个分支的merge请求被拒绝了）。 
zip包下载地址： 
https://github.com/hitripod/grafana/archive/feature-openfalcon.zip 
下载成功后，将zip文件放到以下目录并解压： 
Shell代码   
1.	cd /opt/gohome/workspace/src/github.com/grafana  
2.	unzip grafana-feature-openfalcon.zip  
3.	mv grafana-feature-openfalcon.zip grafana  


由于下载的zip包的Godeps目录下已经包含了所有的依赖包，所以不需要下载依赖包，可以直接build： 
Shell代码   
1.	cd /opt/gohome/workspace/src/github.com/grafana/grafana  
2.	go run build.go setup  
3.	go run build.go build  


后续build前端代码的过程和Grafana官网安装文档基本一致就不再赘述了，注意npm install可能由于网络问题依赖下载不完整，可以多试几遍就好了 

装好后，启动grafana-server，浏览器访问3000端口，默认管理员账号admin,admin就可以登陆了，之后按照open-falcon相关文档接入数据源就好了 







