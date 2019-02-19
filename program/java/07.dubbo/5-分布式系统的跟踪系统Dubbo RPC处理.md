分布式系统的跟踪系统Dubbo RPC处理 - Beaver - CSDN博客 http://blog.csdn.net/doctor_who2004/article/details/49020311

分布式系统的跟踪系统Dubbo RPC处理
   接着前一篇博文http://blog.csdn.net/doctor_who2004/article/details/46974695      
    上篇只是提供了一个思想，今天具体给出dubbo rpc 处理细节。
   dubbo prc处理部分，那就是dubbo 的filter 扩展。dubbo 的filter 接口：
[java] view plain copy
/* 
 * Copyright 1999-2011 Alibaba Group. 
 *   
 * Licensed under the Apache License, Version 2.0 (the "License"); 
 * you may not use this file except in compliance with the License. 
 * You may obtain a copy of the License at 
 *   
 *      http://www.apache.org/licenses/LICENSE-2.0 
 *   
 * Unless required by applicable law or agreed to in writing, software 
 * distributed under the License is distributed on an "AS IS" BASIS, 
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
 * See the License for the specific language governing permissions and 
 * limitations under the License. 
 */  
package com.alibaba.dubbo.rpc;  
  
import com.alibaba.dubbo.common.extension.SPI;  
  
/** 
 * Filter. (SPI, Singleton, ThreadSafe) 
 *  
 * @author william.liangf 
 */  
@SPI  
public interface Filter {  
  
    /** 
     * do invoke filter. 
     *  
     * <code> 
     * // before filter 
     * Result result = invoker.invoke(invocation); 
     * // after filter 
     * return result; 
     * </code> 
     *  
     * @see com.alibaba.dubbo.rpc.Invoker#invoke(Invocation) 
     * @param invoker service 
     * @param invocation invocation. 
     * @return invoke result. 
     * @throws RpcException 
     */  
    Result invoke(Invoker<?> invoker, Invocation invocation) throws RpcException;  
  
}  

因为，这个过滤器里面只有一个方法，所以，我们如何在prc通信中，传递我们需要的东西呢，那就是看这个方法了。

可以参看dubbo 官方文档，我们要看的就是com.alibaba.dubbo.rpc.Invocation:

[java] view plain copy
/* 
 * Copyright 1999-2011 Alibaba Group. 
 *   
 * Licensed under the Apache License, Version 2.0 (the "License"); 
 * you may not use this file except in compliance with the License. 
 * You may obtain a copy of the License at 
 *   
 *      http://www.apache.org/licenses/LICENSE-2.0 
 *   
 * Unless required by applicable law or agreed to in writing, software 
 * distributed under the License is distributed on an "AS IS" BASIS, 
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
 * See the License for the specific language governing permissions and 
 * limitations under the License. 
 */  
package com.alibaba.dubbo.rpc;  
  
import java.util.Map;  
  
/** 
 * Invocation. (API, Prototype, NonThreadSafe) 
 *  
 * @serial Don't change the class name and package name. 
 * @see com.alibaba.dubbo.rpc.Invoker#invoke(Invocation) 
 * @see com.alibaba.dubbo.rpc.RpcInvocation 
 * @author qian.lei 
 * @author william.liangf 
 */  
public interface Invocation {  
  
    /** 
     * get method name. 
     *  
     * @serial 
     * @return method name. 
     */  
    String getMethodName();  
  
    /** 
     * get parameter types. 
     *  
     * @serial 
     * @return parameter types. 
     */  
    Class<?>[] getParameterTypes();  
  
    /** 
     * get arguments. 
     *  
     * @serial 
     * @return arguments. 
     */  
    Object[] getArguments();  
  
    /** 
     * get attachments. 
     *  
     * @serial 
     * @return attachments. 
     */  
    Map<String, String> getAttachments();  
      
    /** 
     * get attachment by key. 
     *  
     * @serial 
     * @return attachment value. 
     */  
    String getAttachment(String key);  
      
    /** 
     * get attachment by key with default value. 
     *  
     * @serial 
     * @return attachment value. 
     */  
    String getAttachment(String key, String defaultValue);  
  
    /** 
     * get the invoker in current context. 
     *  
     * @transient 
     * @return invoker. 
     */  
    Invoker<?> getInvoker();  
  
}  

我们看一下这个接口的实现类：com.alibaba.dubbo.rpc.RpcInvocation:

这个类里面有几个方法：setAttachment、getAttachment等，是我们自定义传递RPC参数的地方。


所以，利用好这几个方法，我们就可以在Dubbo prc 网络通信中，传递我们需要传递的信息，当然，在本文中，指的是跟踪用的对象结构（能把调用链还原成树形结构的数据结构）。
当然，我们可以利用filter保存或打印出一些信息，比如方法名、传递参数名、prc返回结果及异常信息：例如
[html] view plain copy
            log.info("[{}] , [{}], [{}], {}, [{}], [{}], [{}ms]   ", uuid, invoker.getInterface(),   
invocation.getMethodName(),  
 Arrays.toString(invocation.getArguments()),  
 result.getValue(),   
result.getException(), elapsed);  

具体实现就不贴代码了。
