https://blog.csdn.net/cnyyx/article/details/43836343

OpenStack本身提供两种调用的方式 
一、Command Line：如nova create，nova start 等各种命令 
二、Restful Webservice：供OpenStack各个组件之间的调用，也可供外部调用。

本文主要介绍如何通过rest webservice工具调用OpenStack的接口 
一、浏览器安装rest工具，由于现在google被封，所以推荐使用firefox，通过firefox的扩展组件安装restclient

二、获取token，调用OpenStack的各种命令都需要有token来进行认证。当然第一步获取token就必须使用用户名和密码，在接一下的一段时间内（token的有效期内）就可以使用token来认证。 
Postclient调用OpenStack Keyston
通过上述方式就可以获取token(上例中的token是e198f2fda932439fa97ba00f0793c66a)

三、通过token认证来调用OpenStack其他接口 
获取token的接口同时会显示其他服务的访问URL 
本文通过虚拟机暂停接口来演示其他接口的调用 
通过nova list命令查看虚拟机信息 
这里写图片描述

通过restclient调用接口来pause虚拟机 
这里写图片描述

查看虚拟机状态 
这里写图片描述

总结：OpenStack的其他接口都可以通过上述类似的方式来调用，通过调用restful webservice接口，可以定制自己的dashboard，现在很多宣称使用OpenStack的厂商都是这么做的。