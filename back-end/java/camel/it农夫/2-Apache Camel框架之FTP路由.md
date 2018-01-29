Apache Camel框架之FTP路由 - CSDN博客 http://blog.csdn.net/kkdelta/article/details/7236997


在做项目集成类型的项目的时候,经常会有这样的需求,用户或者别的系统将文件传到一个FTP server,然后系统从FTP server取文件进行相应的处理.
本文简单的介绍和示例一个用Camel实现这样的需求:监听FTPserver是否有文件,取到文件做相应处理传到另外一个系统. (图片来源于Camel in Action)

1,搭建一个FTP server,从http://sourceforge.net/projects/filezilla/files/ 下载FileZilla安装,设置一个用户yorker/123456.
可以参照这个网址 http://xbeta.info/filezilla-server.htm
2,在Camel里实现路由:
[java] view plain copy
CamelContext context = new DefaultCamelContext();  
context.addRoutes(new RouteBuilder() {  
    public void configure() {                            
        from("ftp://localhost/inbox?username=yorker&password=123456").to(  
        "file:d:/temp/outbox");  
    }  
});  
context.start();  
boolean loop = true;  
while (loop) {  
    Thread.sleep(25000);  
}  
  
context.stop();  
这里主要是为了示例Camel对FTP的支持,没有加入processor的处理,downstream system也仅仅是用放到本地文件夹做示例.不过真正做项目的时候,在to里可以是别的类型,如JMS的queue,别的系统的FTB inbound文件夹,Web service等等.如将上面的from里面的uri写到to,则为上传到ftp文件夹.
运行时除了Camel要用到的jar包,还需要﻿﻿﻿﻿﻿﻿﻿﻿http://commons.apache.org/net/download_net.cgi 下载commons-net.jar
如何在流程的中间加入processor处理可以参见 http://blog.csdn.net/kkdelta/article/details/7231640