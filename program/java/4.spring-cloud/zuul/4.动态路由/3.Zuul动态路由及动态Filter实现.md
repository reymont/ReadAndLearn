Zuul动态路由及动态Filter实现 - 写个代码 扯个闲淡 - CSDN博客 http://blog.csdn.net/u014091123/article/details/75433656

一， Zuul动态路由实现
动态路由需要达到可持久化配置，动态刷新的效果。不仅要能满足从spring的配置文件properties加载路由信息，还需要从Redis加载我们的配置。另外一点是，路由信息在容器启动时就已经加载进入了内存，我们希望配置完成后，实施发布，动态刷新内存中的路由信息，达到不停机维护路由信息的效果。
为了避免Eureka的侵入性设计，这里没有使用spring-cloud的服务的注册与发现的Eureka，而直接使用了Zuul。
需要配置如下属性使Zuul不依赖Eureka：
Icon
#关闭zuul的eureka注册
eureka.client.enabled=false
这里采取的方式修改路由定位器，借鉴DiscoveryClientRouteLocator去改造SimpleRouteLocator使其具备刷新能力。
DiscoveryClientRouteLocator比SimpleRouteLocator多了两个功能，第一是从DiscoveryClient（如Eureka）发现路由信息，我们不想使用eureka这种侵入式的网关模块，所以忽略它，第二是实现了RefreshableRouteLocator接口，能够实现动态刷新。
路由定位器的实现：
路由定位器的实现

@Override
public void refresh() {
    doRefresh();
}
 
@Override
protected Map<String, ZuulRoute> locateRoutes() {
    LinkedHashMap<String, ZuulRoute> routesMap = new LinkedHashMap<String, ZuulRoute>();
    //从application.properties中加载路由信息
    routesMap.putAll(super.locateRoutes());
    //从redis中加载路由信息
    routesMap.putAll(locateRoutesFromRedis());
    //优化一下配置
    LinkedHashMap<String, ZuulRoute> values = new LinkedHashMap<>();
    for (Map.Entry<String, ZuulRoute> entry : routesMap.entrySet()) {
        String path = entry.getKey();
        // Prepend with slash if not already present.
        if (!path.startsWith("/")) {
            path = "/" + path;
        }
        if (StringUtils.hasText(this.properties.getPrefix())) {
            path = this.properties.getPrefix() + path;
            if (!path.startsWith("/")) {
                path = "/" + path;
            }
        }
        values.put(path, entry.getValue());
    }
    return values;
}
locateRoutesFromRedis方法，则是从Redis中获取路由信息。
然后通过调用路由定位器的doRefresh方法，刷新路由。
刷新路由

@Service
public class RefreshRouteService {
 
    @Autowired
    ApplicationEventPublisher publisher;
 
    @Autowired
    RouteLocator routeLocator;
 
    public void refreshRoute() {
        RoutesRefreshedEvent routesRefreshedEvent = new RoutesRefreshedEvent(routeLocator);
        publisher.publishEvent(routesRefreshedEvent);
    }
 
}
二， Zuul动态Filter实现
Zuul提供了一个框架，可以对过滤器进行动态的加载，编译，运行。过滤器之间没有直接的相互通信。他们是通过一个RequestContext的静态类来进行数据传递的。RequestContext类中有ThreadLocal变量来记录每个Request所需要传递的数据。
过滤器是由Groovy写成。这些过滤器文件被放在Zuul Server上的特定目录下面。Zuul会定期轮询这些目录。修改过的过滤器会动态的加载到Zuul Server中以便于request使用。
需要在启动方法中追加如下代码，动态载入Groovy脚本：
动态载入Groovy

// 启动时加载groovy filter
@Component
public static class GroovyLoadLineRunner implements CommandLineRunner {
    private Logger logger = LoggerFactory.getLogger(getClass());
 
    @Value("${ecej.groovy.path}")
    private String groovyPath;
 
    @Override
    public void run(String... args) throws Exception {
        MonitoringHelper.initMocks();
        FilterLoader.getInstance().setCompiler(new GroovyCompiler());
        try {
            FilterFileManager.setFilenameFilter(new GroovyFileFilter());
            logger.info(groovyPath);
            FilterFileManager.init(1, groovyPath + "pre", groovyPath + "post");
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
FilterFileManager会根据设定的pollingIntervalSeconds，去扫描指定目录的文件到内存中。
在指定目录放入如下的脚本，即可以实现动态Filter的功能。
Groovy脚本

1

2

3

4

5

6

7

8

9

10

11

12

13

14

15

16

17

18

19

20

21

22

23

24

25

26

27

28

29

30

31

32

33

34

35

36

37

38

39

40
package com.ecej.zuul.filter.pre
 
import org.slf4j.Logger
import org.slf4j.LoggerFactory;
 
import javax.servlet.http.HttpServletRequest;
 
import com.netflix.zuul.ZuulFilter;
import com.netflix.zuul.context.RequestContext;
 
class PreRequest extends ZuulFilter {
    private Logger logger = LoggerFactory.getLogger(getClass());
    @Override
    String filterType() {
        return "pre"
    }
 
    @Override
    int filterOrder() {
        return 1000
    }
 
    @Override
    boolean shouldFilter() {
        return true
    }
 
    @Override
    Object run() {
        try {
            RequestContext ctx = RequestContext.getCurrentContext();
            HttpServletRequest request = ctx.getRequest();
            logger.info(String.format("#####Groovy Pre Filter#####send %s request to %s", request.getMethod(), request.getRequestURL().toString()));
        } catch (Exception e) {
            logger.error("",e);
        }
 
        return null
    }
}