

使用Hystrix对Dubbo消费者提供线程隔离保护 - 杨少凯 
https://my.oschina.net/yangshaokai/blog/674685

摘要: 在dubbo中对于消费者的保护提供了actives进行并发控制保护，但是功能相对薄弱，下面我们探讨下如何使用Netflix提供的服务容错组件Hystrix对dubo消费者提供线程隔离保护
在dubbo中对于消费者的保护提供了actives进行并发控制保护，但是功能相对薄弱，下面我们探讨下如何使用Netflix提供的服务容错组件Hystrix对dubo消费者提供线程隔离保护

# 为什么需要Hystrix?

在大中型分布式系统中，通常我们需要依赖很多dubbo服务，如下图:

在高并发访问下，这些依赖的稳定性与否对系统的影响非常大,但是依赖有很多不可控问题:如网络连接缓慢、资源繁忙、暂时不可用、服务脱机等。

如下图：QPS为50的依赖 "I" 出现不可用、但是其他依赖仍然可用。

当依赖I 阻塞时，大多数服务器的线程池就出现阻塞，影响整个线上服务的稳定性。如下图：

当高并发的依赖失败时如果没有隔离措施，当前应用服务就有被拖垮的风险！

例如：一个依赖30个SOA服务的系统,每个服务99.99%可用。  

99.99%的30次方 ≈ 99.7%  

0.3% 意味着一亿次请求 会有 3,000,00次失败  

换算成时间大约每月有2个小时服务不稳定

随着服务依赖数量的变多，服务不稳定的概率会成指数性提高。

解决问题方案：对依赖做隔离，Hystrix就是处理依赖隔离的框架，同时也是可以帮我们做依赖服务的治理和监控。

 

# Hystrix如何解决依赖隔离

Hystrix使用命令模式HystrixCommand(Command)包装依赖调用逻辑，每个命令在单独线程中/信号授权下执行。
可配置依赖调用超时时间，当调用超时时，直接返回或执行fallback逻辑。
为每个依赖提供一个小的线程池（或信号），如果线程池已满调用将被立即拒绝，默认不采用排队，加速失败判定时间。
请求失败(异常，拒绝，超时，短路)时执行fallback(降级)逻辑。
提供熔断器组件,可以自动运行或手动调用,停止当前依赖一段时间(10秒)，熔断器默认错误率阈值为50%,超过将自动运行。
提供近实时依赖的统计和监控

Hystrix依赖的隔离架构，如下图：

Hystrix实时依赖统计、监控如下：

Dubbo消费者引入

dubbo可以通过扩展Filter的方式引入Hystrix，具体代码如下：

```java
package com.netease.hystrix.dubbo.rpc.filter;

import com.alibaba.dubbo.common.Constants;
import com.alibaba.dubbo.common.extension.Activate;
import com.alibaba.dubbo.rpc.Filter;
import com.alibaba.dubbo.rpc.Invocation;
import com.alibaba.dubbo.rpc.Invoker;
import com.alibaba.dubbo.rpc.Result;
import com.alibaba.dubbo.rpc.RpcException;

@Activate(group = Constants.CONSUMER)
public class HystrixFilter implements Filter {

    @Override
    public Result invoke(Invoker invoker, Invocation invocation) throws RpcException {
        DubboHystrixCommand command = new DubboHystrixCommand(invoker, invocation);
        return command.execute();
    }

}
```
DubboHystrixCommand代码如下：

```java
package com.netease.hystrix.dubbo.rpc.filter;

import org.apache.log4j.Logger;

import com.alibaba.dubbo.common.URL;
import com.alibaba.dubbo.rpc.Invocation;
import com.alibaba.dubbo.rpc.Invoker;
import com.alibaba.dubbo.rpc.Result;
import com.netflix.hystrix.HystrixCommand;
import com.netflix.hystrix.HystrixCommandGroupKey;
import com.netflix.hystrix.HystrixCommandKey;
import com.netflix.hystrix.HystrixCommandProperties;
import com.netflix.hystrix.HystrixThreadPoolProperties;

public class DubboHystrixCommand extends HystrixCommand {

    private static Logger    logger                       = Logger.getLogger(DubboHystrixCommand.class);
    private static final int DEFAULT_THREADPOOL_CORE_SIZE = 30;
    private Invoker       invoker;
    private Invocation       invocation;
    
    public DubboHystrixCommand(Invoker invoker,Invocation invocation){
        super(Setter.withGroupKey(HystrixCommandGroupKey.Factory.asKey(invoker.getInterface().getName()))
                    .andCommandKey(HystrixCommandKey.Factory.asKey(String.format("%s_%d", invocation.getMethodName(),
                                                                                 invocation.getArguments() == null ? 0 : invocation.getArguments().length)))
              .andCommandPropertiesDefaults(HystrixCommandProperties.Setter()
                                            .withCircuitBreakerRequestVolumeThreshold(20)//10秒钟内至少19此请求失败，熔断器才发挥起作用
                                            .withCircuitBreakerSleepWindowInMilliseconds(30000)//熔断器中断请求30秒后会进入半打开状态,放部分流量过去重试
                                            .withCircuitBreakerErrorThresholdPercentage(50)//错误率达到50开启熔断保护
                                            .withExecutionTimeoutEnabled(false))//使用dubbo的超时，禁用这里的超时
              .andThreadPoolPropertiesDefaults(HystrixThreadPoolProperties.Setter().withCoreSize(getThreadPoolCoreSize(invoker.getUrl()))));//线程池为30
       
        
        this.invoker=invoker;
        this.invocation=invocation;
    }
    
    /**
     * 获取线程池大小
     * 
     * @param url
     * @return
     */
    private static int getThreadPoolCoreSize(URL url) {
        if (url != null) {
            int size = url.getParameter("ThreadPoolCoreSize", DEFAULT_THREADPOOL_CORE_SIZE);
            if (logger.isDebugEnabled()) {
                logger.debug("ThreadPoolCoreSize:" + size);
            }
            return size;
        }

        return DEFAULT_THREADPOOL_CORE_SIZE;

    }

    @Override
    protected Result run() throws Exception {
        return invoker.invoke(invocation);
    }
}
```

线程池大小可以通过dubbo参数进行控制，当前其他的参数也可以通过类似的方式进行配置

<dubbo:parameter key="ThreadPoolCoreSize" value="20" />
代码添加好后在，resource添加加载文本

|-resources
        |-META-INF
            |-dubbo
                |-com.alibaba.dubbo.rpc.Filter (纯文本文件，内容为：hystrix=com.netease.hystrix.dubbo.rpc.filter.HystrixFilter
由于Filter定义为自动激活的，所以启动代码所有消费者都被隔离起来啦！

项目地址：https://github.com/yskgood/dubbo-hystrix-support.git