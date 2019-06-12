Dubbo之——Dubbo Filter实战 - 刘亚壮的专栏 - CSDN博客 http://blog.csdn.net/l1028386804/article/details/74511445

转载请注明出处：http://blog.csdn.net/l1028386804/article/details/74511445
熟悉Dubbo的同学或朋友，都会知道，一般dubbo的service层都是一些通用的，无状态的服务。但是在某些特殊的需求下，我们又需要传递一些上下文环境,打个不恰当的比方，例如需要在每次调用dubbo的服务的时候，记录一下用户名或者需要知道sessionid等。
解决办法1
如果是在项目设计的时候就意识到这一点的话，就好办，把所有的dubbo服务请求的参数都封装一个公共的父类，把一些上下文环境在放在父类的属性中。

这样做的好处就是，dubbo接口的参数都统一的，在Dubbo中可以做一些统一的处理（例如把上下文环境取出来，放在ThreadLocal中）。

解决办法2
但是并不是所有的项目一开始就有这个需求的，但是突然有一天他猝不及防的出现了（比如本人就接到要使用多数据，每次前端请求的时候根据参数选择使用的数据库），如果项目已经基本定型的情况下，再改造成上面的解决办法，改动量太大（不怕麻烦的也可以，但是本人就比较懒）。
其实Dubbo的文档中已经有这个解决办法，就是隐式传参，dubbo的官方网址为:
http://dubbo.io/User+Guide-zh.htm#UserGuide-zh-%E9%9A%90%E5%BC%8F%E4%BC%A0%E5%8F%82

* http://dubbo.io/books/dubbo-user-book/


改造方案

"org.springframework.boot:spring-boot-starter-aop",

```xml
<dependency>  
    <groupId>org.springframework.boot</groupId>  
    <artifactId>spring-boot-starter-aop</artifactId>  
</dependency>  
```

只需要在调用方加一个切面，在服务方加一个filter
切面
代码如下
```java
/** 
 * 在调用service的接口之前，加入一些dubbo的隐式参数 
 * Created by hzlizhou on 2017/2/6. 
 */  
@Aspect  
@Component  
public class DubboServiceContextAop {  
  
    @Pointcut("execution(* com.打码.打码..service.api.*.*(..))")  
    public void serviceApi() {  
    }  
  
    @Before("serviceApi()")  
    public void dubboContext(JoinPoint jp) {  
        Map<String, String> context = new HashMap<>();  
        // todo you want do  
        RpcContext.getContext().setAttachments(context);  
    }   
}
```
本项目service的package命名都是 com.打码.打码.模块名.service.api  因此只需要一个execution就行了，这也是养成统一的包命名的好处
Dubbo Filter
代码如下，很简单
```java
public class DubboContextFilter implements Filter {  
  
    @Override  
    public Result invoke(Invoker<?> invoker, Invocation invocation) throws RpcException {  
        String var= RpcContext.getContext().getAttachment(从Aop中放入的);  
        //todo 其他相关处理  
        return invoker.invoke(invocation);  
    }  
}
```
怎么写Dubbo Filter
第一步：创建一个类实现Filter接口
如上面的DubboContextFilter
    注意是com.alibaba.dubbo.rpc.Filter
第二步：在resources中创建文件
[plain] view plain copy
META-INF/dubbo/com.alibaba.dubbo.rpc.Filter  
注意是 META-INF文件下的dubbo文件夹下的"com.alibaba.dubbo.rpc.Filter"文件

并在里面加入,也就是第一步中创建的类的路径
[java] view plain copy
dubboContextFilter=com.打码.打码.打码.打码.打码.DubboContextFilter  
第三步：在配置文件中加入
[html] view plain copy
<dubbo:provider filter="dubboContextFilter" />  
小结
其实dubbo内置了一些filter，我们可以自定义自己的filter来完成一些和业务流程无关的逻辑，例如可以写IP白名单等等