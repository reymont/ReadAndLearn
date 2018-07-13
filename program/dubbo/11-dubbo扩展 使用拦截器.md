dubbo扩展 使用拦截器 - CSDN博客 http://blog.csdn.net/eagle199012/article/details/78353883

参考：http://www.cnblogs.com/lizo/p/6701896.html

http://wely.iteye.com/blog/2304718

以拦截器作为例子说明

[html] view plain copy
<!-- 在xml配置文件中设置 -->  
<dubbo:reference filter="xxx,yyy" /> <!-- 消费方调用过程拦截 -->  
<dubbo:consumer filter="xxx,yyy"/> <!-- 消费方调用过程缺省拦截器，将拦截所有reference -->  
<dubbo:service filter="xxx,yyy" /> <!-- 提供方调用过程拦截 -->  
<dubbo:provider filter="xxx,yyy"/> <!-- 提供方调用过程缺省拦截器，将拦截所有service -->  
dubbo扩展配置文件  
src  
 |-main  
    |-java  
        |-com  
            |-xxx  
                |-XxxFilter.java (实现Filter接口)  
    |-resources  
        |-META-INF  
            |-dubbo  
                |-com.alibaba.dubbo.rpc.Filter (纯文本文件，内容为：xxx=com.xxx.XxxFilter)  
//扩展类  
package com.xxx;  
   
import com.alibaba.dubbo.rpc.Filter;  
import com.alibaba.dubbo.rpc.Invoker;  
import com.alibaba.dubbo.rpc.Invocation;  
import com.alibaba.dubbo.rpc.Result;  
import com.alibaba.dubbo.rpc.RpcException;  
   
   
public class XxxFilter implements Filter {  
    public Result invoke(Invoker<?> invoker, Invocation invocation) throws RpcException {  
        // before filter ...  
        Result result = invoker.invoke(invocation);  
        // after filter ...  
        return result;  
    }  
}  