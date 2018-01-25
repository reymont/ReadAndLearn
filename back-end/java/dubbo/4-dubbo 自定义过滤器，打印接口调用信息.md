dubbo 自定义过滤器，打印接口调用信息 - Beaver - CSDN博客 http://blog.csdn.net/doctor_who2004/article/details/48877591

 dubbo提供了web filter类似的com.alibaba.dubbo.rpc.Filter，这样，我们可以在dubbo提供的服务提供方和消费方都可以自定义过滤器，从而可以获得方法调用的时间或参数、返回结果及异常信息。我们可以利用log打印出来。而且，这个过滤器机制，也是分布式跟踪系统的一部分。
      下面代码实例是一个自定义过滤器例子，获得方法调用的参数、返回结果、执行时间及异常信息的log功能。
[java] view plain copy
public class ElapsedTimeFilter implements Filter {  
  
    private static Logger log = LoggerFactory  
            .getLogger(ElapsedTimeFilter.class);  
  
    @Override  
    public Result invoke(Invoker<?> invoker, Invocation invocation) throws RpcException {  
        long start = System.currentTimeMillis();  
        Result result = invoker.invoke(invocation);  
        long elapsed = System.currentTimeMillis() - start;  
        if (invoker.getUrl() != null) {  
  
            // log.info("[" +invoker.getInterface() +"] [" + invocation.getMethodName() +"] [" + elapsed +"]" );  
            log.info("[{}], [{}], {}, [{}], [{}], [{}]   ", invoker.getInterface(), invocation.getMethodName(),   
                         Arrays.toString(invocation.getArguments()), result.getValue(),  
                       result.getException(), elapsed);  
  
        }  
        return result;  
    }  
  
}  

其实，dubbo内部，也有很多已经实现好的不同功能的过滤器，如：


我们自定义了过滤器，还的按照dubbo spi机制，还得需要配置：

在服务消费方或提供方还需要配上这个过滤器，消费方例子：
[html] view plain copy
<dubbo:consumer id="xx"  
                    
                    filter="elapsedTimeFilter"  
                     
                    retries="0"/>  
                   



具体详见官方文档。