Apache Camel框架入门示例 - CSDN博客 http://blog.csdn.net/kkdelta/article/details/7231640
交换一个思想，能得到俩思想 - CSDN博客 http://blog.csdn.net/kkdelta/article/category/1071275

Apache Camel是Apache基金会下的一个开源项目,它是一个基于规则路由和处理的引擎，提供企业集成模式的Java对象的实现，通过应用程序接口 或称为陈述式的Java领域特定语言(DSL)来配置路由和处理的规则。其核心的思想就是从一个from源头得到数据,通过processor处理,再发到一个to目的的.
这个from和to可以是我们在项目集成中经常碰到的类型:一个FTP文件夹中的文件,一个MQ的queue,一个HTTP request/response,一个webservice等等.
Camel可以很容易集成到standalone的应用,在容器中运行的Web应用,以及和Spring一起集成.
下面用一个示例,介绍怎么开发一个最简单的Camel应用.
1,从http://camel.apache.org/download.html下载Jar包.在本文写作的时候最新版本是2.9. 本文用的是2.7,从2.7开始要求需要JRE1.6的环境.
下载的zip包含了Camel各种特性要用到的jar包.
在本文入门示例用到的Jar包只需要:camel-core-2.7.5.jar,commons-management-1.0.jar,slf4j-api-1.6.1.jar.
2,新建一个Eclipse工程,将上面列出的jar包设定到工程的Classpath.
新建一个如下的类:运行后完成的工作是将d:/temp/inbox/下的所有文件移到d:/temp/outbox
[java] view plain copy
public class FileMoveWithCamel {  
    public static void main(String args[]) throws Exception {  
        CamelContext context = new DefaultCamelContext();  
        context.addRoutes(new RouteBuilder() {  
        public void configure() {  
        //from("file:d:/temp/inbox?noop=true").to("file:d:/temp/outbox");   
        from("file:d:/temp/inbox/?delay=30000").to("file:d:/temp/outbox");  
        }  
        });  
        context.start();  
        boolean loop =true;  
        while(loop){  
            Thread.sleep(25000);  
        }          
        context.stop();  
        }  
}  
上面的例子体现了一个最简单的路由功能,比如d:/temp/inbox/是某一个系统FTP到Camel所在的系统的一个接收目录.
d:/temp/outbox为Camel要发送的另一个系统的接收目录.
from/to可以是如下别的形式,读者是否可以看出Camel是可以用于系统集成中做路由,流程控制一个非常好的框架了呢?
from("file:d:/temp/inbox/?delay=30000").to("jms:queue:order");//delay=30000是每隔30秒轮询一次文件夹中是否有文件.
3,再给出一个从from到to有中间流程process处理的例子:
[java] view plain copy
public class FileProcessWithCamel {  
    public static void main(String args[]) throws Exception {  
        CamelContext context = new DefaultCamelContext();      
        context.addRoutes(new RouteBuilder() {  
              
        public void configure() {  
        FileConvertProcessor processor = new FileConvertProcessor();  
        from("file:d:/temp/inbox?noop=true").process(processor).to("file:d:/temp/outbox");  
        }  
        });  
          
        context.start();  
        boolean loop =true;  
        while(loop){  
            Thread.sleep(25000);  
        }  
        context.stop();  
        }  
}  
这里的处理只是简单的把接收到的文件多行转成一行
[java] view plain copy
public class FileConvertProcessor implements Processor{  
    @Override  
    public void process(Exchange exchange) throws Exception {      
        try {  
            InputStream body = exchange.getIn().getBody(InputStream.class);  
            BufferedReader in = new BufferedReader(new InputStreamReader(body));  
            StringBuffer strbf = new StringBuffer("");  
            String str = null;  
            str = in.readLine();  
            while (str != null) {                  
                System.out.println(str);  
                strbf.append(str + " ");  
                str = in.readLine();                  
            }  
            exchange.getOut().setHeader(Exchange.FILE_NAME, "converted.txt");  
            // set the output to the file  
            exchange.getOut().setBody(strbf.toString());  
        } catch (IOException e) {  
            e.printStackTrace();  
        }  
    }  
}  
在Eclipse里运行的时候,Camel默认不会把log信息打印到控制台,这样出错的话，异常是看不到的,需要把log4j配置到项目中.
[java] view plain copy
log4j.appender.stdout = org.apache.log4j.ConsoleAppender  
log4j.appender.stdout.Target = System.out  
log4j.appender.stdout.layout = org.apache.log4j.PatternLayout  
log4j.appender.stdout.layout.ConversionPattern = %-5p %d [%t] %c: %m%n  
log4j.rootLogger = debug,stdout  