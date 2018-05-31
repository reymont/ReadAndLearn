dubbo在controller中reference注解为空的问题深度解析 - CSDN博客 http://blog.csdn.net/zhou_java_hui/article/details/53039491

dubbo注解的使用

使用非常简单，下面贴出关键部分

//provider的配置文件
<?xml version="1.0" encoding="UTF-8"?>  
<beans xmlns="http://www.springframework.org/schema/beans"  
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
    xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"  
    xsi:schemaLocation="http://www.springframework.org/schema/beans          
    http://www.springframework.org/schema/beans/spring-beans.xsd          
    http://code.alibabatech.com/schema/dubbo          
    http://code.alibabatech.com/schema/dubbo/dubbo.xsd">  
    <!-- 提供方应用信息，用于计算依赖关系 -->  
    <dubbo:application name="provider-app"  />  
    <!-- 使用zookeeper注册中心暴露服务地址 -->  
    <dubbo:registry protocol="zookeeper" address="127.0.0.1:2181" />
    <!-- 用dubbo协议在20880端口暴露服务 -->  
    <dubbo:protocol name="dubbo" port="20880" />

    <dubbo:annotation package="com.i.springboot.controller" />
</beans>
//服务接口类
@com.alibaba.dubbo.config.annotation.Service
public class PostService {
    ………………省略……………………
}

//consumer端配置
<?xml version="1.0" encoding="UTF-8"?>  
<beans xmlns="http://www.springframework.org/schema/beans"  
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
    xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"  
    xsi:schemaLocation="http://www.springframework.org/schema/beans          
    http://www.springframework.org/schema/beans/spring-beans.xsd          
    http://code.alibabatech.com/schema/dubbo          
    http://code.alibabatech.com/schema/dubbo/dubbo.xsd">  
    <!-- 消费方应用名，用于计算依赖关系，不是匹配条件，不要与提供方一样 -->  
    <dubbo:application name="consumer-app"/>  
    <dubbo:registry address="zookeeper://127.0.0.1:2181" />
    <dubbo:annotation package="com.i.springboot.controller"/>
</beans>  

//服务引用
@Controller
@RequestMapping("/post")
@SessionAttributes("currentUser")
public class PostController {
    //注解使用dubbo服务端服务
    @Reference
    PostService postService;
    ……………省略……………
}
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
41
42
43
44
45
46
47
48
49
以上如果只是用spring的容器，而不使用springmvc进行结合使用时是不会出现引用为空的问题的；但是如果不了解spring和springmvc加载配置文件和初始化bean的流程，则极有可能出现postService为Null的情况，错误配置如下

我src/main/resources下面有spring-consumer.xml、spring-mvc.xm两个配置文件，spring-mvc.xml和web.xml配置部分如下

<?xml version="1.0" encoding="UTF-8"?>    
<beans xmlns="http://www.springframework.org/schema/beans"   
    xmlns:context="http://www.springframework.org/schema/context"   
    xmlns:mvc="http://www.springframework.org/schema/mvc"  
    xmlns:p="http://www.springframework.org/schema/p"  
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"    
    xsi:schemaLocation="http://www.springframework.org/schema/beans   
    http://www.springframework.org/schema/beans/spring-beans-3.0.xsd  
    http://www.springframework.org/schema/context  
    http://www.springframework.org/schema/context/spring-context.xsd  
    http://www.springframework.org/schema/mvc   
    http://www.springframework.org/schema/mvc/spring-mvc-3.0.xsd"> 

    <!-- 自动扫描controller包下的所有类，使其认为spring mvc的控制器 -->
    <context:component-scan base-package="com.i.springboot.controller" />
    ……………………省略…………………………
</beans>

<!DOCTYPE web-app PUBLIC
 "-//Sun Microsystems, Inc.//DTD Web Application 2.3//EN"
 "http://java.sun.com/dtd/web-app_2_3.dtd" >
<web-app>
  <display-name>Archetype Created Web Application</display-name>
  <context-param>
    <param-name>contextConfigLocation</param-name>
    <param-value>
        classpath*:/spring-*.xml
    </param-value>
    </context-param>
    <listener>
        <listener-class>org.springframework.web.context.ContextLoaderListener
        </listener-class>
    </listener>

    <servlet>
        <servlet-name>spring</servlet-name>
        <servlet-class>org.springframework.web.servlet.DispatcherServlet
        </servlet-class>
        <init-param>
            <param-name>contextConfigLocation</param-name>
            <param-value>classpath:spring-mvc.xml</param-value>
        </init-param>
        <load-on-startup>2</load-on-startup>
    </servlet>
    <servlet-mapping>
        <servlet-name>spring</servlet-name>
        <url-pattern>*.do</url-pattern>
    </servlet-mapping>
</web-app>
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
41
42
43
44
45
46
47
48
49
初步一看完全没有问题，spring启动的时候会扫描controller包，然后初始化我的postService服务类，一切想的都是那么美好，程序一运行，一个大大的空指针异常抛出，然后网上、qq上一堆乱问，终不得解，生无可恋，下面一步步解决问题 
开始之前提出如下疑问

spring是什么时候跟dubbo勾搭在一起的
为什么PostService上面加上dubbo的Service注解，服务类就会被加载
为什么dubbo官方文件所说的通过Reference引用服务却为NULL
dubbo和spring结合

到底dubbo是怎么和spring组合的呢，先看如下

<beans xmlns="http://www.springframework.org/schema/beans"  
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
    xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"  
    xsi:schemaLocation="http://www.springframework.org/schema/beans          
    http://www.springframework.org/schema/beans/spring-beans.xsd          

    http://code.alibabatech.com/schema/dubbo          
    http://code.alibabatech.com/schema/dubbo/dubbo.xsd">
1
2
3
4
5
6
7
8
注意到xmlns:dubbo=”http://code.alibabatech.com/schema/dubbo”了吗，仔细想想spring怎么解析xml配置文件的，NamespaceHandler、NamespaceHandlerSupport、BeanDefinitionParser，spring提供的一种SPI规范，dubbo定义了自己的schema、namespacehandler、beandefinitionparser

/**
 * DubboNamespaceHandler
 * 
 * @author william.liangf
 * @export
 */
public class DubboNamespaceHandler extends NamespaceHandlerSupport {

    static {
        Version.checkDuplicate(DubboNamespaceHandler.class);
    }

    public void init() {
        registerBeanDefinitionParser("application", new DubboBeanDefinitionParser(ApplicationConfig.class, true));
        registerBeanDefinitionParser("module", new DubboBeanDefinitionParser(ModuleConfig.class, true));
        registerBeanDefinitionParser("registry", new DubboBeanDefinitionParser(RegistryConfig.class, true));
        registerBeanDefinitionParser("monitor", new DubboBeanDefinitionParser(MonitorConfig.class, true));
        registerBeanDefinitionParser("provider", new DubboBeanDefinitionParser(ProviderConfig.class, true));
        registerBeanDefinitionParser("consumer", new DubboBeanDefinitionParser(ConsumerConfig.class, true));
        registerBeanDefinitionParser("protocol", new DubboBeanDefinitionParser(ProtocolConfig.class, true));
        registerBeanDefinitionParser("service", new DubboBeanDefinitionParser(ServiceBean.class, true));
        registerBeanDefinitionParser("reference", new DubboBeanDefinitionParser(ReferenceBean.class, false));
        registerBeanDefinitionParser("annotation", new DubboBeanDefinitionParser(AnnotationBean.class, true));
    }

}
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
结合
DefaultBeanDefinitionDocumentReader.doRegisterBeanDefinitions，xml配置文件就这样开始解析，具体不做描述，主要看dubbo是如何搭上spring的车的，解析过程咱们重点看AnnotationsBean的解析，也就是dubbo的DubboBeanDefinitionParser类

dubbo的service、reference是如何初始化的

DubboBeanDefinitionParser的parse方法被调用后，dubbo定义的几个大的标签application、registry、provider、consumer、annotation等都会被初始化，并包装成RootBeanDefinition在spring的bean容器中

@SuppressWarnings("unchecked")
    private static BeanDefinition parse(Element element, ParserContext parserContext, Class<?> beanClass, boolean required) {
        RootBeanDefinition beanDefinition = new RootBeanDefinition();
        beanDefinition.setBeanClass(beanClass);
        beanDefinition.setLazyInit(false);
       ……………………………省略具体解析代码…………………………………
        return beanDefinition;
    }
1
2
3
4
5
6
7
8
重点看annotation实例化过程，也是dubbo注解的关键，进入此类，看到一长串的类

public class AnnotationBean extends AbstractConfig implements DisposableBean, BeanFactoryPostProcessor, BeanPostProcessor, ApplicationContextAware {
1
不得不提下spring的processer和aware两个SPI点，设计的非常巧妙，完全符合设计六大原则之一的开闭原则

//任选一种都支持process和aware两种方式
<context:annotation-config/>
<context:component-scan base-package="xx.xx.xx" />
1
2
3
dubbo充分利用了spring提供的机制进行service的初始化和reference的实例化的

service的实例化过程

第一步

public void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory)
            throws BeansException {
        if (annotationPackage == null || annotationPackage.length() == 0) {
            return;
        }
        if (beanFactory instanceof BeanDefinitionRegistry) {
            try {
                // init scanner
                Class<?> scannerClass = ReflectUtils.forName("org.springframework.context.annotation.ClassPathBeanDefinitionScanner");
                Object scanner = scannerClass.getConstructor(new Class<?>[] {BeanDefinitionRegistry.class, boolean.class}).newInstance(new Object[] {(BeanDefinitionRegistry) beanFactory, true});
                // add filter
                Class<?> filterClass = ReflectUtils.forName("org.springframework.core.type.filter.AnnotationTypeFilter");
                Object filter = filterClass.getConstructor(Class.class).newInstance(Service.class);
                Method addIncludeFilter = scannerClass.getMethod("addIncludeFilter", ReflectUtils.forName("org.springframework.core.type.filter.TypeFilter"));
                addIncludeFilter.invoke(scanner, filter);
                // scan packages
                String[] packages = Constants.COMMA_SPLIT_PATTERN.split(annotationPackage);
                Method scan = scannerClass.getMethod("scan", new Class<?>[]{String[].class});
                scan.invoke(scanner, new Object[] {packages});
            } catch (Throwable e) {
                // spring 2.0
            }
        }
    }
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
实例化一个ClassPathBeanDefinitionScanner类，通过反射实现有参构造的初始化，将注册bean的(BeanDefinitionRegistry) beanFactory作为参数传递给实例，最后反射调用scanner的scan方法，将service注解的实例增加至spring容器中 
第二步

public Object postProcessAfterInitialization(Object bean, String beanName)
            throws BeansException {
        //判断是不是dubbo需要处理的bean类，如果是则继续进行处理，不是则不做任何处理
        if (! isMatchPackage(bean)) {
            return bean;
        }
        Service service = bean.getClass().getAnnotation(Service.class);
        if (service != null) {
            ServiceBean<Object> serviceConfig = new ServiceBean<Object>(service);
            if (void.class.equals(service.interfaceClass())
                    && "".equals(service.interfaceName())) {
                if (bean.getClass().getInterfaces().length > 0) {
                    serviceConfig.setInterface(bean.getClass().getInterfaces()[0]);
                } else {
                    throw new IllegalStateException("Failed to export remote service class " + bean.getClass().getName() + ", cause: The @Service undefined interfaceClass or interfaceName, and the service class unimplemented any interfaces.");
                }
            }
            if (applicationContext != null) {
                serviceConfig.setApplicationContext(applicationContext);
                if (service.registry() != null && service.registry().length > 0) {
                    List<RegistryConfig> registryConfigs = new ArrayList<RegistryConfig>();
                    for (String registryId : service.registry()) {
                        if (registryId != null && registryId.length() > 0) {
                            registryConfigs.add((RegistryConfig)applicationContext.getBean(registryId, RegistryConfig.class));
                        }
                    }
                    serviceConfig.setRegistries(registryConfigs);
                }
                if (service.provider() != null && service.provider().length() > 0) {
                    serviceConfig.setProvider((ProviderConfig)applicationContext.getBean(service.provider(),ProviderConfig.class));
                }
                if (service.monitor() != null && service.monitor().length() > 0) {
                    serviceConfig.setMonitor((MonitorConfig)applicationContext.getBean(service.monitor(), MonitorConfig.class));
                }
                if (service.application() != null && service.application().length() > 0) {
                    serviceConfig.setApplication((ApplicationConfig)applicationContext.getBean(service.application(), ApplicationConfig.class));
                }
                if (service.module() != null && service.module().length() > 0) {
                    serviceConfig.setModule((ModuleConfig)applicationContext.getBean(service.module(), ModuleConfig.class));
                }
                if (service.provider() != null && service.provider().length() > 0) {
                    serviceConfig.setProvider((ProviderConfig)applicationContext.getBean(service.provider(), ProviderConfig.class));
                } else {

                }
                if (service.protocol() != null && service.protocol().length > 0) {
                    List<ProtocolConfig> protocolConfigs = new ArrayList<ProtocolConfig>();
                    for (String protocolId : service.registry()) {
                        if (protocolId != null && protocolId.length() > 0) {
                            protocolConfigs.add((ProtocolConfig)applicationContext.getBean(protocolId, ProtocolConfig.class));
                        }
                    }
                    serviceConfig.setProtocols(protocolConfigs);
                }
                try {
                    serviceConfig.afterPropertiesSet();
                } catch (RuntimeException e) {
                    throw (RuntimeException) e;
                } catch (Exception e) {
                    throw new IllegalStateException(e.getMessage(), e);
                }
            }
            //
            serviceConfig.setRef(bean);
            serviceConfigs.add(serviceConfig);
            //通过注册中心暴露dubbo的服务
            serviceConfig.export();
        }
        //返还spring容器，有点类似于装饰
        return bean;
    }
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
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
71
至此，dubbo通过service注解实现spring容器管理完毕

reference实例过程

reference和service最大的不同是，reference注解生成的实例就没有交给spring容器去管理，而只是作为spring管理bean的一个属性赋值操作，通过反射来实现，代码如下

public Object postProcessBeforeInitialization(Object bean, String beanName)
            throws BeansException {
        //和service一样
        if (! isMatchPackage(bean)) {
            return bean;
        }
        Method[] methods = bean.getClass().getMethods();
        for (Method method : methods) {
            String name = method.getName();
            if (name.length() > 3 && name.startsWith("set")
                    && method.getParameterTypes().length == 1
                    && Modifier.isPublic(method.getModifiers())
                    && ! Modifier.isStatic(method.getModifiers())) {
                try {
                    Reference reference = method.getAnnotation(Reference.class);
                    if (reference != null) {
                        Object value = refer(reference, method.getParameterTypes()[0]);
                        if (value != null) {
                            method.invoke(bean, new Object[] {  });
                        }
                    }
                } catch (Throwable e) {
                    logger.error("Failed to init remote service reference at method " + name + " in class " + bean.getClass().getName() + ", cause: " + e.getMessage(), e);
                }
            }
        }
        Field[] fields = bean.getClass().getDeclaredFields();
        for (Field field : fields) {
            try {
                if (! field.isAccessible()) {
                    field.setAccessible(true);
                }
                //本项目使用的是PostController，field就是controller中的postService，refer方法则是通过连接注册中心，检测服务是否存在，当然如果配置中check为false就不会现在进行检测
                Reference reference = field.getAnnotation(Reference.class);
                if (reference != null) {
                    //refer方法有兴趣可以自己看，牵扯到zk和netty
                    Object value = refer(reference, field.getType());
                    if (value != null) {
                        field.set(bean, value);
                    }
                }
            } catch (Throwable e) {
                logger.error("Failed to init remote service reference at filed " + field.getName() + " in class " + bean.getClass().getName() + ", cause: " + e.getMessage(), e);
            }
        }
        //将controller中有reference标示的字段赋值后返回，并没有将字段类实例注入spring容器，确实也没有必要
        return bean;
    }

    private Object refer(Reference reference, Class<?> referenceClass) { //method.getParameterTypes()[0]
        String interfaceName;
        if (! "".equals(reference.interfaceName())) {
            interfaceName = reference.interfaceName();
        ……………………省略……………………
        return referenceConfig.get();
    }
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
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
至此reference标注的实例也初始化完成，service和referece返回的都是dubbo的代理类com.alibaba.dubbo.common.bytecode.Proxy，用到了jdk的Proxy、InvocationHandler来生成代理类（没有javassist的情况），再次声明，reference标注的对象不会被spring容器管理，是无法通过factory.getBean获取的

Null出现的原因

首先得知道spring容器初始化过程

public class ContextLoaderListener extends ContextLoader implements ServletContextListener

/**
 * Initialize the root web application context.
 */
@Override
public void contextInitialized(ServletContextEvent event) {
    initWebApplicationContext(event.getServletContext());
}
1
2
3
4
5
6
7
8
9
我配置了监听，会读取spring-*.xml配置文件，会初始化一个xmlwebapplicationcontext也就是应用的rootContext顶级容器，这个容器在serverletcontext上下文中，等监听初始化完毕后，我们配置的dispatcherservlet开始初始化

/**
     * Overridden method of {@link HttpServletBean}, invoked after any bean properties
     * have been set. Creates this servlet's WebApplicationContext.
     */
    @Override
    protected final void initServletBean() throws ServletException {
        try {
            //初始化mvc的容器
            this.webApplicationContext = initWebApplicationContext();
            initFrameworkServlet();
        }
    }

protected WebApplicationContext initWebApplicationContext() {
        //获取监听初始化的顶级容器
        WebApplicationContext rootContext =
                WebApplicationContextUtils.getWebApplicationContext(getServletContext());
        WebApplicationContext wac = null;

        if (this.webApplicationContext != null) {
            // A context instance was injected at construction time -> use it
            wac = this.webApplicationContext;
            if (wac instanceof ConfigurableWebApplicationContext) {
                ConfigurableWebApplicationContext cwac = (ConfigurableWebApplicationContext) wac;
                if (!cwac.isActive()) {
                    // The context has not yet been refreshed -> provide services such as
                    // setting the parent context, setting the application context id, etc
                    if (cwac.getParent() == null) {
                        // The context instance was injected without an explicit parent -> set
                        // the root application context (if any; may be null) as the parent
                        cwac.setParent(rootContext);
                    }
                    configureAndRefreshWebApplicationContext(cwac);
                }
            }
        }
        if (wac == null) {
            // No context instance was injected at construction time -> see if one
            // has been registered in the servlet context. If one exists, it is assumed
            // that the parent context (if any) has already been set and that the
            // user has performed any initialization such as setting the context id
            wac = findWebApplicationContext();
        }
        if (wac == null) {
            // No context instance is defined for this servlet -> create a local one
            //初始化XmlWebApplicationContext开始，它会读取配置文件spring-mvc.xml
            wac = createWebApplicationContext(rootContext);
        }

        if (!this.refreshEventReceived) {
            // Either the context is not a ConfigurableApplicationContext with refresh
            // support or the context injected at construction time had already been
            // refreshed -> trigger initial onRefresh manually here.
            onRefresh(wac);
        }

        if (this.publishContext) {
            // Publish the context as a servlet context attribute.
            String attrName = getServletContextAttributeName();
            //将mvc容器放入servletcontext上下文中
            getServletContext().setAttribute(attrName, wac);
            if (this.logger.isDebugEnabled()) {
                this.logger.debug("Published WebApplicationContext of servlet '" + getServletName() +
                        "' as ServletContext attribute with name [" + attrName + "]");
            }
        }

        return wac;
    }
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
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
监听初始化的容器读取了所有的配置文件，并初始化了controller类，同时将dubbo注解reference的实例set给了controller，而后servlet初始化过程中又再一次读取了spring-mvc.xml配置文件，同时也对controller进行了初始化，但是与顶级容器初始化不同的是，它没有加载dubbo实现的DubboNamespaceHandler，也就是说reference实例化的过程都没有进行，因此在mvc容器中的controller是没有注入reference标注的实例的，因此出现NULL的情况

总结

遇到这样的问题是一种幸运，也是一种不幸，幸运的是通过debug看源码的过程增加了对spring的了解以及框架的优秀设计，不幸的是对于spring一些细节的地方还不够了解；遇到问题不放弃、不抛弃，加油