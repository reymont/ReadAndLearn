Spring Dubbo 开发笔记 - atheva - 博客园 http://www.cnblogs.com/lizo/p/6701896.html

第一节:概述
Spring-Dubbo 是我自己写的一个基于spring-boot和dubbo，目的是使用Spring boot的风格来使用dubbo。（即可以了解Spring boot的启动过程又可以学习一下dubbo的框架）

项目介绍：

github: https://github.com/Athlizo/spring-dubbo-parent

码云:  https://git.oschina.net/null_584_3382/spring-dubbo-parent

声明：
 这个只是个人研究使用，spring boot 启动dubbo还有很多方法（@ImportResource）
2这个只是第一版，基本功能已实现（其实底层还是原来的，只是处理了在spring boot启动的时候怎么去加载一些东西），一些扩展和优化还会继续更新
你可以像配置springboot其他属性一样在application.yml中配置dubbo属性

1
2
3
4
5
6
7
8
dubbo:
  application:
    name: lizo
  registry:
    address: multicast://224.5.6.7:1234
  protocol:
    name: dubbo
    port: 20887　
@EnableDubbo
使用这个注解来开启dubbo服务

复制代码
@SpringBootApplication
@EnableDubbo(basePackages = "com.alibaba.dubbo")
public class Provider {

    public static void main(String[] args) throws InterruptedException {
        ApplicationContext ctx = new SpringApplicationBuilder()
                .sources(Provider.class)
                .web(false) 
                .run(args);
        new CountDownLatch(1).await();
    }
}
复制代码
 

这样就可以使用基于注解的dubbo的rpc调用

定义接口 :

public interface AddService {
    int add(int a, int b);
}
 

定义服务实现类：

这里就做一个简单加法

复制代码
@Service
public class AddServiceImpl implements AddService {
    @Override
    public int add(int a, int b) {
        return a + b;
    }
}
复制代码
配置消费bean

复制代码
@Component
public class ConsumerAction {

    @Reference
    private AddService addService;

    public void add(int a,int b){
        System.out.println("ret = " + addService.add(a,b));
    }
}
复制代码
快速定义Filter

可以像定义一般的spring bean 定义一个dubbo filter

复制代码
@Bean
ProviderFilter consumerFilter(){
    return new ProviderFilter();
}

static class ProviderFilter extends AbstractDubboProviderFilterSupport {

    public Result invoke(Invoker<?> invoker, Invocation invocation) {
        System.out.println("ProviderFilter");
        return invoker.invoke(invocation);
    }
}        
复制代码
 

 

当然如果你有跟定制化的需求，也可以使用dubbo原生的注解@Activate，只要继承AbstractDubboFilterSupport

复制代码
@Activate(group = Constants.PROVIDER)
static class CustomFilter extends AbstractDubboFilterSupport {
    public Result invoke(Invoker<?> invoker, Invocation invocation) throws RpcException {
        System.out.println("CustomFilter");
        return invoker.invoke(invocation);
    }

    public Filter getDefaultExtension() {
        return this;
    }
}
复制代码
 

第二节：在Spring boot启动中加载Dubbo服务
Dubbo启动的时候，是可以使用自己的Spring来启动dubbo服务，但是现在是需要把Dubbo启动SpringApplicationContest的逻辑放入到Spring Boot的启动逻辑中去。（主要是针对注解的方式）

常用的接口
按照调用的顺序来介绍

ApplicationContextInitializer

public interface ApplicationContextInitializer<C extends ConfigurableApplicationContext> {
    void initialize(C applicationContext);
}
Spring Boot启动的时候，会扫描classpath下的META-INF.spring.factories, 其中有一个配置名为org.springframework.context.ApplicationContextInitializer，配置项为一些实现了ApplicationContextInitializer接口的类的全路径名，这些类就是Spring Boot在启动的时候首先会进行实例化。

ApplicationListener

同ApplicationContextInitializer加载方式一样，META-INF.spring.factories中还有另外一个配置项org.springframework.context.ApplicationListener，定义在SpringBoot启动的时候会初始化的ApplicationListener。严格来说ApplicationListener在整个SpringApplicationContext启动的时候都会触发调用逻辑（通过各种不同事件触发）

BeanFactoryPostProcessor

public interface BeanFactoryPostProcessor {
    void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) throws BeansException;
}
从名字可以看出，这个接口的类主要是针对BeanFactory进行一些操作，和ApplicationContextInitializer实例化的方式不一样，这个接口必须在BeanFactory中存在才会在启动中生效，因此，ApplicationContextInitializer中常做的事情就是加入一些BeanFactoryPostProcessor 。

BeanPostProcessor

public interface BeanPostProcessor {
         // 先于afterPropertiesSet() 和init-method
    Object postProcessBeforeInitialization(Object bean, String beanName) throws BeansException;
    Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException;
}
如果BeanFactoryPostProcessor针对的是BeanFactory，那么BeanPostProcessor针对就是BeanFactory中的所有bean了。分别提供了Bean初始化之前和bean初始化之后的相关处理。和BeanFactoryPostProcessor一样，也需要在启动中注册到BeanFactory中才会生效，一般通过BeanFactoryPostProcessor 加入。

小结
从上面的分析可以看出

如果需要在SpringApplication初始化的时候需要做事情，使用ApplicationContextInitializer
如果在Spring启动的各个阶段有一些定制化的处理，使用ApplicationListener
如果需要对BeanFactory做一些处理，例如添加一些Bean，使用BeanFactoryPostProcessor
如果需要对BeanFactory中的bean做一些处理，使用BeanPostProcessor ，（个人理解是该接口主要针对bean批量处理，否则针对特定的bean就使用InitializeBean或者Init-method完成初始化逻辑）
SpringBoot接入Dubbo
注：这里的接入主要是对使用注解的方式。

Dubbo是中处理@Service和@Reference
关键类：com.alibaba.dubbo.config.spring.AnnotationBean 代码逻辑比较简单，这个类实现了BeanFactoryPostProcessor和BeanPostProcessor这2个接口，分别作用：

在BeanFactory处理结束以后，扫描Service注解的类，加入到BeanFactory中
在Bean初始化之前，对@Reference注解的set方法和属性创建远程调用代理类并注入
在Bean初始化之后，对@Service注解的类暴露远程调用服务（生成Exporter）
因此，SpringBoot接入dubbo的关键在于：在完成BeanFactoryPostProcessor调用之前，把AnnotationBean加入到BeanFactory中就可以了

接入方式

这里不直接使用AnnotationBean，而是另外定义一个类，新类的名字为AnnotationBeanProcessor（为了贴代码方便），作用是一样的，只是修改里面的部分处理逻辑。

方法1. 利用ApplicationContextInitializer

代码如下

复制代码
public class DubboContextInitializer implements ApplicationContextInitializer<ConfigurableApplicationContext> {
    public void initialize(ConfigurableApplicationContext applicationContext) {
        AnnotationBeanProcessor annotationBeanProcessor= new AnnotationBeanProcessor(${构造参数});
        annotationBeanProcessor.setApplicationContext(applicationContext);
        applicationContext.addBeanFactoryPostProcessor(annotationBeanProcessor);
    }
}
复制代码
特点——简单暴力

方法2 利用BeanFactoryPostProcessor

在ApplicationContextInitializer中加入其它的一个BeanFactoryPostProcessor，然后在这个BeanFactoryPostProcessor加入AnnotationBeanProcessor

复制代码
public class DubboContextInitializer implements ApplicationContextInitializer<ConfigurableApplicationContext> {
    public void initialize(ConfigurableApplicationContext applicationContext) {
        DubboBeanDefinitionRegistryPostProcessor dubboBeanDefinitionRegistryPostProcessor = new DubboBeanDefinitionRegistryPostProcessor();
        applicationContext.addBeanFactoryPostProcessor(dubboBeanDefinitionRegistryPostProcessor);
    }

    public class DubboBeanDefinitionRegistryPostProcessor implements BeanDefinitionRegistryPostProcessor {
        public void postProcessBeanDefinitionRegistry(BeanDefinitionRegistry registry) throws BeansException {
            GenericBeanDefinition beanDefinition = new GenericBeanDefinition();
            beanDefinition.setBeanClass(AnnotationBeanProcessor.class);
            beanDefinition.getConstructorArgumentValues()
                    .addGenericArgumentValue(${构造参数});
            beanDefinition.setRole(BeanDefinition.ROLE_INFRASTRUCTURE);
            registry.registerBeanDefinition("annotationBeanProcessor", beanDefinition);
        }   
    }
} 
复制代码
特点: 这样做虽然感觉有点绕，但是好处就是可以在其它的一些关键的BeanDefinitionRegistryPostProcessor 后再执行，这样就可以使用xxxAware接口，Spring会自动帮我们注入。可以利用Spring提供的一些便利功能。 虽然利用ApplicationListener也可以做到，但是不推荐

方法3 利用ImportBeanDefinitionRegistrar

@Import注解中加入ImportBeanDefinitionRegistrar的实现类，实现对bean definition 层面的开发。

复制代码
public class AnnotationBeanDefinitionRegistrar implements ImportBeanDefinitionRegistrar {
    private String BEAN_NAME = "annotationBeanProcessor";

    public void registerBeanDefinitions(AnnotationMetadata importingClassMetadata, BeanDefinitionRegistry registry) {
        List<String> basePackages = getPackagesToScan(importingClassMetadata);
        if (!registry.containsBeanDefinition(BEAN_NAME)) {
            addPostProcessor(registry, basePackages);
        }
    }

    // register annotationBeanProcessor.class
    private void addPostProcessor(BeanDefinitionRegistry registry, List<String> basePackages) {
        GenericBeanDefinition beanDefinition = new GenericBeanDefinition();
        beanDefinition.setBeanClass(AnnotationBeanProcessor.class);
        beanDefinition.getConstructorArgumentValues()
                .addGenericArgumentValue(basePackages);
        beanDefinition.setRole(BeanDefinition.ROLE_INFRASTRUCTURE);
        registry.registerBeanDefinition(BEAN_NAME, beanDefinition);
    }

    //获取扫描的包路径
    private List<String> getPackagesToScan(AnnotationMetadata metadata) {
        //EnableDubbo 是一个注解，用于开启扫描dubbo的bean，并且可以自己定义扫描basePackages
        AnnotationAttributes attributes = AnnotationAttributes.fromMap(
                metadata.getAnnotationAttributes(EnableDubbo.class.getName()));
        String[] basePackages = attributes.getStringArray("basePackages");
        return Arrays.asList(basePackages);
    }
}
复制代码
其中还使用到了EnableDubbo.class ，其实这个是一个注解，里面定义了basePackages的属性。 特点:1 通过注解使Dubbo是否生效，还可以自己配置basePackages的扫描包路径，而不用写死在代码里。2. 很Spring Boot Style

@Reference和@Service
@Reference注解的set方法和属性，Dubbo会创建ReferenceBean（代理类）然后注入进进。
@Service就是在bean初始化，会生成一个ServiceBean，然后exporter（监听远程调用请求）。
而这2个流程的理想处理方式就是在BeanPostProcessor 中，因为上面这2个处理逻辑不是针对某个特殊的bean，而是针对所有的bean，只要有@Reference或者@Service，并且满足basepackage限制就行。

dubbo现有的逻辑是分别在所有bean初始化之前进行@Reference相关流程，而在所有bean初始化之后调用@Service处理流程。（这2个流程我是修改在ApplicationContext初始化成功以后再进行，并且这样做还会带来一定的好处）

第三节 Spring 加载dubbo扩展
dubbo框架中，提供了多种扩展，比如Dubbo的过滤器扩展，路由扩展等等。并且dubbo已经提供了扩展的一些默认实现。本篇文章主要介绍：1）dubbo扩展原理，2）通过简单的改造，使dubbo让扩展的使用更方便。

dubbo扩展
怎么创建dubbo扩展

以拦截器作为例子说明，引用dubbo官方文档中的例子。

复制代码
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
复制代码
第一步是配置Dubbo Filter，有两种方法，第一种是在配置文件里面加入相关扩展配置，例如<dubbo:provider filter="xxx"/>。第二种方法是针对集合类扩展，比如：Filter, InvokerListener, ExportListener, TelnetHandler, StatusChecker等，可以同时加载多个实现，使用@Activate的方式自动激活来简化配置，如：    
复制代码
import com.alibaba.dubbo.common.extension.Activate;
import com.alibaba.dubbo.rpc.Filter;
 
@Activate(group = "provider", value = "xxx") // 只对提供方激活，group可选"provider"或"consumer"
public class XxxFilter implements Filter {
    // ...
} 
复制代码
第二步是创建配置文件，在resource/META-INF/dubbo/com.alibaba.dubbo.rpc.Filter文件里面写配置xxx=com.xxx.XxxFilter
第三步是创建对应的Class，在配置对应的包下面新建一个XxxFilter，实现Dubbo的Filter接口。
通过以上3步就可以自定义一个Filter

Dubbo是怎么加载扩展

 ExtensionLoader<T>

1) 创建:

这个类是用户管理所有的dubbo扩展，是一个泛型，根据不同的扩展类（例如Filter，Protocol等），保存该类扩展的所有实现类。

例如，要想获取每个具体的ExtensionLoader，使用getExtensionLoader（Class） 来获取，如果没有就创建，如果之前创建过就返回之前创建的，逻辑比较简单。

复制代码
public static <T> ExtensionLoader<T> getExtensionLoader(Class<T> type) {
    ... //省略参数校验
    ExtensionLoader<T> loader = (ExtensionLoader<T>) EXTENSION_LOADERS.get(type);
    if (loader == null) {
        //EXTENSION_LOADERS用于保存ExtensionLoader所有泛型实现子类
        EXTENSION_LOADERS.putIfAbsent(type, new ExtensionLoader<T>(type));
        loader = (ExtensionLoader<T>) EXTENSION_LOADERS.get(type);
    }
    return loader;
}
复制代码
2)获取：

获取有效的扩展类，是通过getActivateExtension方法。代码如下：

复制代码
public List<T> getActivateExtension(URL url, String[] values, String group) {
    List<T> exts = new ArrayList<T>();
    List<String> names = values == null ? new ArrayList<String>(0) : Arrays.asList(values);
    if (! names.contains(Constants.REMOVE_VALUE_PREFIX + Constants.DEFAULT_KEY)) {
        //加载扩展扩展的类
        getExtensionClasses();
        //加载@Activate注解的配置的扩展
        for (Map.Entry<String, Activate> entry : cachedActivates.entrySet()) {
            String name = entry.getKey();
            Activate activate = entry.getValue();
            if (isMatchGroup(group, activate.group())) {
                T ext = getExtension(name);
                if (! names.contains(name)
                        && ! names.contains(Constants.REMOVE_VALUE_PREFIX + name) 
                        && isActive(activate, url)) {
                    exts.add(ext);
                }
            }
        }
        Collections.sort(exts, ActivateComparator.COMPARATOR);
    }
    List<T> usrs = new ArrayList<T>();
    //加载 通过values传递过来的指定扩展
    for (int i = 0; i < names.size(); i ++) {
       String name = names.get(i);
        if (! name.startsWith(Constants.REMOVE_VALUE_PREFIX)
              && ! names.contains(Constants.REMOVE_VALUE_PREFIX + name)) {
           if (Constants.DEFAULT_KEY.equals(name)) {
              if (usrs.size() > 0) {
              exts.addAll(0, usrs);
              usrs.clear();
              }
           } else {
           T ext = getExtension(name);
           usrs.add(ext);
           }
        }
    }
    if (usrs.size() > 0) {
       exts.addAll(usrs);
    }
    return exts;
}
复制代码
传入的参数说明：

url-我们知道dubbo的RPC调用相关信息都是通过URL形式保存的，因此url参数即是当前的某个服务调用
values-用来指定加载某些特殊的扩展，例如通过<dubbo:provider filter="xxx"/>来配置的过滤器，则在url中会有相关信息（service.filter），然后加载指定过滤器
group-用来处理@Activate注解的方式配置扩展
其中有一个比较重要的方法，getExtensionClasses（），原理就是初始化扩展名字及其对应的Class，在往里面看

复制代码
private Map<String, Class<?>> getExtensionClasses() {
       Map<String, Class<?>> classes = cachedClasses.get();
       if (classes == null) {
           synchronized (cachedClasses) {
               classes = cachedClasses.get();
               if (classes == null) {
                   classes = loadExtensionClasses();
                   cachedClasses.set(classes);
               }
           }
       }
       return classes;
}
复制代码
其中loadExtensionClasses方法如下：这里看到了，为什么要配置在自定义过滤器的时候我们需要配置META-INFO.dubbo.com.alibaba.dubbo.rpc.Filter这个文件，原来就是在这里通过文件加载到ExtensionLoad中去的，并且路径写死在这里。

复制代码
private Map<String, Class<?>> loadExtensionClasses() {
    ...
    Map<String, Class<?>> extensionClasses = new HashMap<String, Class<?>>();
    // META-INF/dubbo/internal/
    loadFile(extensionClasses, DUBBO_INTERNAL_DIRECTORY);
    // META-INF/dubbo/
    loadFile(extensionClasses, DUBBO_DIRECTORY);
    // META-INF/services/
    loadFile(extensionClasses, SERVICES_DIRECTORY);
    return extensionClasses;
}
复制代码
3) 使用

还是以Filter为例子，在哪里调用Filter呢？首先要明白，dubbo的远程调用都是通过抽象接口Invoker为核心。ProtocolFilterWrapper的类中的buildInvokerChain方法用来创建Invoder的调用链。核心代码如下：

复制代码
private static <T> Invoker<T> buildInvokerChain(final Invoker<T> invoker, String key, String group) {
    Invoker<T> last = invoker;
    List<Filter> filters = ExtensionLoader.getExtensionLoader(Filter.class).getActivateExtension(invoker.getUrl(), key, group);
    if (filters.size() > 0) {
        for (int i = filters.size() - 1; i >= 0; i --) {
            final Filter filter = filters.get(i);
            final Invoker<T> next = last;
            last = new Invoker<T>() {
                ...
                public Result invoke(Invocation invocation) throws RpcException {
                    return filter.invoke(next, invocation);
                }
               ...
            };
        }
    }
    return last;
}
复制代码
这里就使用到了ExtensionLoader的getActivateExtension方法获取当前有效的Filter。

Spring Boot Style
在第二节中介绍了怎么使用Spring boot来加载dubbo的相关bean，那么就会想，对于dubbo的Filter，有没有更优雅的声明方式？例如Spring MVC中的声明一个Filter就是直接声明一个普通的Bean一样。

还是以Filter为例子（注意，下面分析Filter是针对全局的Filter，即Provider或者Consumer层面Filter）

首先，扩展是从ExtensionLoad<Filter>中获取，那么我们的目的就是在ExtensionLoad<Filter>中加入自己的Filter。上面说过，ExtensionLoad加载扩展有2种方式，一种是通过参数中Values来获取，另外一种是通过@Activate注解。简单分析一下：

使用Values参数的方式

需要在声明一个自己的Filter的时候，同时必须创建一个ProviderConfig或者ConsumerConfig（以代替<dubbo:provider filter="xxx"/>这样的配置）
需要手动往ExtensionLoad中加入我们自己的Filter(以代替通过读取com.alibaba.dubbo.rpc.Filter配置加入到ExtensionLoad)
使用@Activate方式

使用@Activate的话，也要往ExtensionLoad中加入我们自己的Filter，但是不用创建ProviderConfig或者ConsumerConfig。
必须要在自己的Filter上有@Activate注解。
这两种方式都能达成我们的需求，但是从开发难度来说使用@Activate注解相对简单，而且第二点可以通过其他方式（proxy代理）来解决。因此下下面介绍基于@Activate注解来快速创建一个Dubbo的Filter。

3.1 实现方式
    自定义一个BeanPostProcessor，对每一个Bean做以下处理：



3.2 完成以后的效果

这样就可以快速创建一个Dubbo Filter

复制代码
@Bean
ProviderFilter providerFilter(){
    return new ProviderFilter();
}

static class ProviderFilter extends AbstractDubboProviderFilterSupport {
    public Result invoke(Invoker<?> invoker, Invocation invocation) {
        System.out.println("ProviderFilter");
        return invoker.invoke(invocation);
    }
}
复制代码
如果有跟定制化的需求，可以使用@Activate注解。

复制代码
@Bean
CustomFilter customFilter(){
    return new CustomFilter();
}

@Activate(group = Constants.PROVIDER)
static class CustomFilter extends AbstractDubboFilterSupport {
    public Result invoke(Invoker<?> invoker, Invocation invocation) throws RpcException {
        System.out.println("CustomFilter");
        return invoker.invoke(invocation);
    }

    public Filter getDefaultExtension() {
        return this;
    }
}
复制代码
 

 总结
　　如果在不改动dubbo内部代码的情况下，只能在上层逻辑进行修改，因此能做的事还是比较有限。不过通过这个项目，既了解到了Spring boot启动的过程，也知道理解了dubbo框架思想。