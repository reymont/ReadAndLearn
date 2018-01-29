Apache Camel框架之HTTP路由 - CSDN博客 http://blog.csdn.net/kkdelta/article/details/7242112

继介绍完Camel如何处理FTP,JMS接口之后,今天介绍一下系统集成的时候经常遇到的另一个接口,HTTP,一个示例需求如下图所示:(图片来源于Camel in Action)

本文给出一个简单的代码示例如何用Camel来实现这样一个应用:
1,在一个JAVA类里配置如下路由:这里只示例了HTTP的部分,其他功能实现可以参见Apache Camel框架系列的其他博客.
[java] view plain copy
public class HttpPollWithQuartzCamel {  
    public static void main(String args[]) throws Exception {  
        CamelContext context = new DefaultCamelContext();  
        context.addRoutes(new RouteBuilder() {  
            public void configure() {                  
                from("quartz://report?cron=10 * * * * ?&stateful=true")  
                .to("http://localhost:8080/prjWeb/test.camelreq")  
                .to("file:d:/temp/outbox?fileName=http.csv");  
                );  
            }  
        });  
        context.start();  
        boolean loop = true;  
        while (loop) {  
            Thread.sleep(25000);  
        }  
        context.stop();  
    }  
}  
对上面代码的简单解释: from("quartz://report?cron=10 * * * * ?&stateful=true"),配置一个quartz Job,每隔10秒发送一个HTTP request,将收到的内容保存为文件.
这里的http url可以是任何可以访问的http url,如果在http访问时候需要代理可以这么配置:"http://www.baidu.com?proxyHost=proxy.xxx.com&proxyPort=8080"
这个例子需要用到quartz,和httpclient等jar包,可以从这里下载: http://download.csdn.net/detail/kkdelta/4051072

