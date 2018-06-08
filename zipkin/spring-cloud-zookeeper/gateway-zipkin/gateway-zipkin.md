
* https://github.com/spring-cloud/spring-cloud-sleuth/issues/470
* https://github.com/ajayaks/gateway-service

```java
    @Bean
    public AlwaysSampler defaultSampler() {
        return new AlwaysSampler();
    }
```

application.properties
```conf
spring.zipkin.baseUrl=http://172.20.62.42:9411
```

build.gradle
```groovy
compile('com.github.jessyZu:dubbo-zipkin-spring-starter:1.0.2')
compile('org.springframework.cloud:spring-cloud-sleuth-zipkin')
```