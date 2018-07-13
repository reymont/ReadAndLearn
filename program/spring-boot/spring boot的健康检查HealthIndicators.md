

spring boot的健康检查HealthIndicators - 南北雪树的专栏 - CSDN博客 
http://blog.csdn.net/u010963948/article/details/77573635

想提供自定义健康信息， 你可以注册实现了HealthIndicator接口的Spring beans。 你需要提供一个health()方法的实现， 并返
回一个Health响应。 Health响应需要包含一个status和可选的用于展示的详情。
```java
import org.springframework.boot.actuate.health.HealthIndicator;  
import org.springframework.stereotype.Component;  
@Component  
public class MyHealth implements HealthIndicator {  
    @Override  
    public Health health() {  
        int errorCode = check(); // perform some specific health check  
        if (errorCode != 0) {  
            return Health.down().withDetail("Error Code", errorCode).build();  
        }   
        return Health.up().build();  
    }  
}
```

`除了Spring Boot预定义的Status类型， Health也可以返回一个代表新的系统状态的自定义Status`。 在这种情况下， 需要提供
一个HealthAggregator接口的自定义实现， 或使用management.health.status.order属性配置默认的实现。
例如， 假设一个新的， 代码为FATAL的Status被用于你的一个HealthIndicator实现中。 为了配置严重程度， 你需要将下面的配
置添加到application属性文件中：
management.health.status.order: `DOWN, OUT_OF_SERVICE, UNKNOWN, UP`
如果使用HTTP访问health端点， 你可能想要注册自定义的status， 并使用HealthMvcEndpoint进行映射。 例如， 你可以将
FATAL映射为HttpStatus.SERVICE_UNAVAILABLE。 


```java
management.health.status.order: DOWN, OUT_OF_SERVICE, UNKNOWN, UP
spring boot health 状态
curl 172.20.8.48:12010/health|python -m json.tool
```