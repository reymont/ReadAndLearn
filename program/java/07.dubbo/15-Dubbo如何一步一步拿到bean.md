

Dubbo如何一步一步拿到bean | kazaff's blog | 种一棵树最佳时间是十年前，其次是现在 
http://blog.kazaff.me/2015/01/26/dubbo如何一步一步拿到bean/#beanDefinition-gt-bean

dubbo依赖了spring提供的现成机制完成了bean的创建，我们来看一下这其中的汰渍。

配置

关于dubbo的配置相关细节，官方已经给了一个无比详细的文档，文档2。不过由于dubbo可供配置的参数非常多，这也是让我们新手一开始感到最为头疼的，这也是SOA复杂的表象之一。

xml -> beanDefinition

对于我这种小学生，需要先补习一个基础知识点：基于Spring可扩展Schema提供自定义配置支持。dubbo是依赖spring提供的这种机制来处理配置文件解析的，理解起来没什么难度。

看一下dubbo-congfig的目录结构：


我们来看一下dubbo是如何按照spring提供的机制来处理配置文件的：

#spring.handlers
http\://code.alibabatech.com/schema/dubbo=com.alibaba.dubbo.config.spring.schema.DubboNamespaceHandler

#spring.schemas
http\://code.alibabatech.com/schema/dubbo/dubbo.xsd=META-INF/dubbo.xsd
这样我们就锁定了要分析的类：

package com.alibaba.dubbo.config.spring.schema;

public class DubboNamespaceHandler extends NamespaceHandlerSupport {

    static {
        Version.checkDuplicate(DubboNamespaceHandler.class); //确保系统中只存在一份解析处理器类定义
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
按照spring提供的机制，dubbo把每个自定义的可使用配置元素和对应的解析器绑定到一起。而真正负责把配置文件中声明的内容解析成对应的BeanDefinition（可以想象为Bean的模子）是靠DubboBeanDefinitionParser.parse类完成，我们就来严肃的分析一下这个方法。

/**
 * AbstractBeanDefinitionParser
 * 
 * @author william.liangf
 * @export
 */
public class DubboBeanDefinitionParser implements BeanDefinitionParser {

    private static final Logger logger = LoggerFactory.getLogger(DubboBeanDefinitionParser.class);

    private final Class<?> beanClass;

    private final boolean required;

    public DubboBeanDefinitionParser(Class<?> beanClass, boolean required) {
        this.beanClass = beanClass;
        this.required = required;
    }

    public BeanDefinition parse(Element element, ParserContext parserContext) {
        return parse(element, parserContext, beanClass, required);
    }

    @SuppressWarnings("unchecked")
    private static BeanDefinition parse(Element element, ParserContext parserContext, Class<?> beanClass, boolean required) {
        //初始化BeanDefiniion
        RootBeanDefinition beanDefinition = new RootBeanDefinition();
        beanDefinition.setBeanClass(beanClass);
        beanDefinition.setLazyInit(false);

        String id = element.getAttribute("id");
        if ((id == null || id.length() == 0) && required) {
            String generatedBeanName = element.getAttribute("name");
            if (generatedBeanName == null || generatedBeanName.length() == 0) {
                if (ProtocolConfig.class.equals(beanClass)) {   //如果当前解析的类型是ProtocolConfig，则设置默认id为dubbo
                    generatedBeanName = "dubbo";
                } else {
                    generatedBeanName = element.getAttribute("interface");  //其他情况，默认id为接口类型
                }
            }
            if (generatedBeanName == null || generatedBeanName.length() == 0) {
                generatedBeanName = beanClass.getName();    //如果该节点没有interface属性（包含：registry,monitor,provider,consumer），则使用该节点的类型为id值
            }
            id = generatedBeanName; 
            int counter = 2;
            while(parserContext.getRegistry().containsBeanDefinition(id)) { //生成不重复的id
                id = generatedBeanName + (counter ++);
            }
        }
        if (id != null && id.length() > 0) {    //目前这个判断不知道啥意义，目测必定会返回true
            if (parserContext.getRegistry().containsBeanDefinition(id))  {  //这个判断应该用于防止并发
                throw new IllegalStateException("Duplicate spring bean id " + id);
            }
            //注册beanDefinition，BeanDefinitionRegistry相当于一张注册表
            parserContext.getRegistry().registerBeanDefinition(id, beanDefinition);
            beanDefinition.getPropertyValues().addPropertyValue("id", id);
        }
        //下面这几个if-else分别针对不同类型做特殊处理
        if (ProtocolConfig.class.equals(beanClass)) {
            //这段代码的逻辑是用来适配：当<dubbo:protocol>声明出现在配置文件中使用该协议的bean声明的后面时，解决它们之间的依赖关系的。
            for (String name : parserContext.getRegistry().getBeanDefinitionNames()) {
                BeanDefinition definition = parserContext.getRegistry().getBeanDefinition(name);
                PropertyValue property = definition.getPropertyValues().getPropertyValue("protocol");
                if (property != null) {
                    Object value = property.getValue();
                    //如果被检查的bean确实使用当前协议，则建立它们之间的依赖关系
                    if (value instanceof ProtocolConfig && id.equals(((ProtocolConfig) value).getName())) {
                        definition.getPropertyValues().addPropertyValue("protocol", new RuntimeBeanReference(id));
                    }
                }
            }
        } else if (ServiceBean.class.equals(beanClass)) {
            String className = element.getAttribute("class");   //虽然文档上没有标注该配置支持class参数，但是在dubbo.xsd上却能看到这个属性的定义，类似这样的情况还有很多。
            if(className != null && className.length() > 0) {   //下面的处理方式应该算是语法糖吧，它支持直接把定义bean和创建serviceConfig压缩成一行
                RootBeanDefinition classDefinition = new RootBeanDefinition();
                classDefinition.setBeanClass(ReflectUtils.forName(className));
                classDefinition.setLazyInit(false);
                parseProperties(element.getChildNodes(), classDefinition);  //完成bean的初始化工作（注入等）
                beanDefinition.getPropertyValues().addPropertyValue("ref", new BeanDefinitionHolder(classDefinition, id + "Impl")); //关联bean和serviceConfig
            }
        } else if (ProviderConfig.class.equals(beanClass)) {    //按照providerConfig的定义解析并关联其影响的相关serviceConfig
            parseNested(element, parserContext, ServiceBean.class, true, "service", "provider", id, beanDefinition);
        } else if (ConsumerConfig.class.equals(beanClass)) {    //按照consumerConfig的定义解析并关联其影响的相关referenceConfig
            parseNested(element, parserContext, ReferenceBean.class, false, "reference", "consumer", id, beanDefinition);
        }
        Set<String> props = new HashSet<String>();
        ManagedMap parameters = null;
        for (Method setter : beanClass.getMethods()) {  //利用反射拿到指定类型的所有用于注入的方法
            String name = setter.getName();
            if (name.length() > 3 && name.startsWith("set")
                    && Modifier.isPublic(setter.getModifiers())
                    && setter.getParameterTypes().length == 1) {    //注入方法的特征是：以set字母开头，是公共方法，且参数个数为1
                Class<?> type = setter.getParameterTypes()[0];
                String property = StringUtils.camelToSplitName(name.substring(3, 4).toLowerCase() + name.substring(4), "-");    //把方法名字的驼峰格式改成-分割格式
                props.add(property);
                Method getter = null;
                try {
                    getter = beanClass.getMethod("get" + name.substring(3), new Class<?>[0]);
                } catch (NoSuchMethodException e) {
                    try {
                        getter = beanClass.getMethod("is" + name.substring(3), new Class<?>[0]);
                    } catch (NoSuchMethodException e2) {
                    }
                }
                if (getter == null 
                        || ! Modifier.isPublic(getter.getModifiers())
                        || ! type.equals(getter.getReturnType())) { //如果没有满足条件的对应getter方法存在，则直接跳过该setter方法
                    continue;
                }

                if ("parameters".equals(property)) {    //从配置文件中解析出parameter配置，用于配置自定义参数，该配置项将作为扩展点设置自定义参数使用，parameter的值当string类型解析
                    parameters = parseParameters(element.getChildNodes(), beanDefinition);
                } else if ("methods".equals(property)) {    //注入对应的method配置
                    parseMethods(id, element.getChildNodes(), beanDefinition, parserContext);
                } else if ("arguments".equals(property)) {  //为method注入对应的argument配置
                    parseArguments(id, element.getChildNodes(), beanDefinition, parserContext);
                } else {
                    String value = element.getAttribute(property);  //检查该setter方法所适配要注入的属性是否在配置中明确定义
                    if (value != null) {    //若存在定义，则完成其注入解析
                        value = value.trim();
                        if (value.length() > 0) {
                            if ("registry".equals(property) && RegistryConfig.NO_AVAILABLE.equalsIgnoreCase(value)) {   //处理无注册中心的情况
                                RegistryConfig registryConfig = new RegistryConfig();
                                registryConfig.setAddress(RegistryConfig.NO_AVAILABLE);
                                beanDefinition.getPropertyValues().addPropertyValue(property, registryConfig);
                            } else if ("registry".equals(property) && value.indexOf(',') != -1) {   //处理多注册中心的情况
                                parseMultiRef("registries", value, beanDefinition, parserContext);
                            } else if ("provider".equals(property) && value.indexOf(',') != -1) {   //处理继承多个provider的情况，缺使用第一个provider配置
                                parseMultiRef("providers", value, beanDefinition, parserContext);
                            } else if ("protocol".equals(property) && value.indexOf(',') != -1) {   //处理多协议暴露
                                parseMultiRef("protocols", value, beanDefinition, parserContext);
                            } else {
                                Object reference;
                                if (isPrimitive(type)) {    //如果setter的参数类型为jdk原始类型，直接当string注入到对应属性中去
                                    if ("async".equals(property) && "false".equals(value)
                                            || "timeout".equals(property) && "0".equals(value)
                                            || "delay".equals(property) && "0".equals(value)
                                            || "version".equals(property) && "0.0.0".equals(value)
                                            || "stat".equals(property) && "-1".equals(value)
                                            || "reliable".equals(property) && "false".equals(value)) {
                                        // 兼容旧版本xsd中的default值
                                        value = null;
                                    }
                                    reference = value;
                                } else if ("protocol".equals(property) 
                                        && ExtensionLoader.getExtensionLoader(Protocol.class).hasExtension(value)   //是否存在指定的扩展点定义
                                        && (! parserContext.getRegistry().containsBeanDefinition(value) //检查当前解析出的要使用协议对应的protocolConfig是否已经被初始化
                                                || ! ProtocolConfig.class.getName().equals(parserContext.getRegistry().getBeanDefinition(value).getBeanClassName()))) {
                                    if ("dubbo:provider".equals(element.getTagName())) {
                                        logger.warn("Recommended replace <dubbo:provider protocol=\"" + value + "\" ... /> to <dubbo:protocol name=\"" + value + "\" ... />");
                                    }
                                    // 兼容旧版本配置
                                    ProtocolConfig protocol = new ProtocolConfig();
                                    protocol.setName(value);
                                    reference = protocol;
                                } else if ("monitor".equals(property) 
                                        && (! parserContext.getRegistry().containsBeanDefinition(value)
                                                || ! MonitorConfig.class.getName().equals(parserContext.getRegistry().getBeanDefinition(value).getBeanClassName()))) {
                                    // 兼容旧版本配置
                                    reference = convertMonitor(value);
                                } else if ("onreturn".equals(property)) {   //对应methodConfig中的返回拦截
                                    int index = value.lastIndexOf(".");
                                    String returnRef = value.substring(0, index);
                                    String returnMethod = value.substring(index + 1);
                                    reference = new RuntimeBeanReference(returnRef);
                                    beanDefinition.getPropertyValues().addPropertyValue("onreturnMethod", returnMethod);
                                } else if ("onthrow".equals(property)) {    //对应methodConfig中的异常拦截
                                    int index = value.lastIndexOf(".");
                                    String throwRef = value.substring(0, index);
                                    String throwMethod = value.substring(index + 1);
                                    reference = new RuntimeBeanReference(throwRef);
                                    beanDefinition.getPropertyValues().addPropertyValue("onthrowMethod", throwMethod);
                                } else {
                                    if ("ref".equals(property) && parserContext.getRegistry().containsBeanDefinition(value)) {
                                        BeanDefinition refBean = parserContext.getRegistry().getBeanDefinition(value);
                                        if (! refBean.isSingleton()) {
                                            throw new IllegalStateException("The exported service ref " + value + " must be singleton! Please set the " + value + " bean scope to singleton, eg: <bean id=\"" + value+ "\" scope=\"singleton\" ...>");
                                        }
                                    }
                                    reference = new RuntimeBeanReference(value);
                                }
                                beanDefinition.getPropertyValues().addPropertyValue(property, reference);
                            }
                        }
                    }
                }
            }
        }
        NamedNodeMap attributes = element.getAttributes();
        int len = attributes.getLength();
        for (int i = 0; i < len; i++) {
            Node node = attributes.item(i);
            String name = node.getLocalName();
            if (! props.contains(name)) {   //处理配置中声明的没有满足注入条件的剩余属性
                if (parameters == null) {
                    parameters = new ManagedMap();
                }
                String value = node.getNodeValue();
                parameters.put(name, new TypedStringValue(value, String.class));
            }
        }
        if (parameters != null) {
            beanDefinition.getPropertyValues().addPropertyValue("parameters", parameters);
        }
        return beanDefinition;
    }

    private static final Pattern GROUP_AND_VERION = Pattern.compile("^[\\-.0-9_a-zA-Z]+(\\:[\\-.0-9_a-zA-Z]+)?$");

    protected static MonitorConfig convertMonitor(String monitor) {
        if (monitor == null || monitor.length() == 0) {
            return null;
        }
        if (GROUP_AND_VERION.matcher(monitor).matches()) {
            String group;
            String version;
            int i = monitor.indexOf(':');
            if (i > 0) {
                group = monitor.substring(0, i);
                version = monitor.substring(i + 1);
            } else {
                group = monitor;
                version = null;
            }
            MonitorConfig monitorConfig = new MonitorConfig();
            monitorConfig.setGroup(group);
            monitorConfig.setVersion(version);
            return monitorConfig;
        }
        return null;
    }

    private static boolean isPrimitive(Class<?> cls) {
        return cls.isPrimitive() || cls == Boolean.class || cls == Byte.class
                || cls == Character.class || cls == Short.class || cls == Integer.class
                || cls == Long.class || cls == Float.class || cls == Double.class
                || cls == String.class || cls == Date.class || cls == Class.class;
    }

    @SuppressWarnings("unchecked")
    private static void parseMultiRef(String property, String value, RootBeanDefinition beanDefinition,
            ParserContext parserContext) {
        String[] values = value.split("\\s*[,]+\\s*");
        ManagedList list = null;
        for (int i = 0; i < values.length; i++) {
            String v = values[i];
            if (v != null && v.length() > 0) {
                if (list == null) {
                    list = new ManagedList();
                }
                list.add(new RuntimeBeanReference(v));
            }
        }
        beanDefinition.getPropertyValues().addPropertyValue(property, list);
    }

    private static void parseNested(Element element,
                                    ParserContext parserContext,
                                    Class<?> beanClass,
                                    boolean required,
                                    String tag,
                                    String property,
                                    String ref,
                                    BeanDefinition beanDefinition) {
        NodeList nodeList = element.getChildNodes();
        if (nodeList != null && nodeList.getLength() > 0) {
            boolean first = true;
            for (int i = 0; i < nodeList.getLength(); i++) {
                Node node = nodeList.item(i);
                if (node instanceof Element) {
                    if (tag.equals(node.getNodeName())
                            || tag.equals(node.getLocalName())) {
                        if (first) {
                            //如果该providerBean没有设置default开关，且子节点中定义了serviceBean，则明确赋值该参数为false，也就是说该providerBean只作为其子serviceBean节点的默认协议
                            //这样就不会让该providerBean的作用范围盲目扩大（成为所有serviceBean的默认协议）
                            first = false;
                            String isDefault = element.getAttribute("default");
                            if (isDefault == null || isDefault.length() == 0) {
                                beanDefinition.getPropertyValues().addPropertyValue("default", "false");
                            }
                        }
                        //所有子serviceBean定义节点全部解析并引用该providerBean作为默认值配置
                        BeanDefinition subDefinition = parse((Element) node, parserContext, beanClass, required);
                        if (subDefinition != null && ref != null && ref.length() > 0) {
                            subDefinition.getPropertyValues().addPropertyValue(property, new RuntimeBeanReference(ref));
                        }
                    }
                }
            }
        }
    }

    private static void parseProperties(NodeList nodeList, RootBeanDefinition beanDefinition) {
        if (nodeList != null && nodeList.getLength() > 0) {
            for (int i = 0; i < nodeList.getLength(); i++) {
                Node node = nodeList.item(i);
                if (node instanceof Element) {
                    if ("property".equals(node.getNodeName())
                            || "property".equals(node.getLocalName())) {
                        String name = ((Element) node).getAttribute("name");
                        if (name != null && name.length() > 0) {
                            String value = ((Element) node).getAttribute("value");  //java基础类型
                            String ref = ((Element) node).getAttribute("ref");  //引用其他bean
                            if (value != null && value.length() > 0) {
                                beanDefinition.getPropertyValues().addPropertyValue(name, value);
                            } else if (ref != null && ref.length() > 0) {
                                beanDefinition.getPropertyValues().addPropertyValue(name, new RuntimeBeanReference(ref));
                            } else {
                                throw new UnsupportedOperationException("Unsupported <property name=\"" + name + "\"> sub tag, Only supported <property name=\"" + name + "\" ref=\"...\" /> or <property name=\"" + name + "\" value=\"...\" />");
                            }
                        }
                    }
                }
            }
        }
    }

    @SuppressWarnings("unchecked")
    private static ManagedMap parseParameters(NodeList nodeList, RootBeanDefinition beanDefinition) {   //解析参数配置，用于配置自定义参数，该配置项将作为扩展点设置自定义参数使用。
        if (nodeList != null && nodeList.getLength() > 0) {
            ManagedMap parameters = null;
            for (int i = 0; i < nodeList.getLength(); i++) {
                Node node = nodeList.item(i);
                if (node instanceof Element) {
                    if ("parameter".equals(node.getNodeName())
                            || "parameter".equals(node.getLocalName())) {
                        if (parameters == null) {
                            parameters = new ManagedMap();
                        }
                        String key = ((Element) node).getAttribute("key");
                        String value = ((Element) node).getAttribute("value");
                        boolean hide = "true".equals(((Element) node).getAttribute("hide"));
                        if (hide) {
                            key = Constants.HIDE_KEY_PREFIX + key;
                        }
                        parameters.put(key, new TypedStringValue(value, String.class)); //注意parameter的值都是string类型
                    }
                }
            }
            return parameters;
        }
        return null;
    }

    @SuppressWarnings("unchecked")
    private static void parseMethods(String id, NodeList nodeList, RootBeanDefinition beanDefinition,
                              ParserContext parserContext) {
        if (nodeList != null && nodeList.getLength() > 0) {
            ManagedList methods = null;
            for (int i = 0; i < nodeList.getLength(); i++) {
                Node node = nodeList.item(i);
                if (node instanceof Element) {
                    Element element = (Element) node;
                    if ("method".equals(node.getNodeName()) || "method".equals(node.getLocalName())) {
                        String methodName = element.getAttribute("name");
                        if (methodName == null || methodName.length() == 0) {   //name为必填项，这一点在文档里也表明
                            throw new IllegalStateException("<dubbo:method> name attribute == null");
                        }
                        if (methods == null) {
                            methods = new ManagedList();
                        }
                        BeanDefinition methodBeanDefinition = parse(((Element) node),
                                parserContext, MethodConfig.class, false);  //解析methodConfig
                        String name = id + "." + methodName;    //注意这里，方法的名称前会加上bean的id
                        BeanDefinitionHolder methodBeanDefinitionHolder = new BeanDefinitionHolder(
                                methodBeanDefinition, name);
                        methods.add(methodBeanDefinitionHolder);
                    }
                }
            }
            if (methods != null) {
                beanDefinition.getPropertyValues().addPropertyValue("methods", methods);    //关联bean和其method
            }
        }
    }

    @SuppressWarnings("unchecked")
    private static void parseArguments(String id, NodeList nodeList, RootBeanDefinition beanDefinition,
                              ParserContext parserContext) {
        if (nodeList != null && nodeList.getLength() > 0) {
            ManagedList arguments = null;
            for (int i = 0; i < nodeList.getLength(); i++) {
                Node node = nodeList.item(i);
                if (node instanceof Element) {
                    Element element = (Element) node;
                    if ("argument".equals(node.getNodeName()) || "argument".equals(node.getLocalName())) {
                        String argumentIndex = element.getAttribute("index");   //不清楚这里为何没有必填校验
                        if (arguments == null) {
                            arguments = new ManagedList();
                        }
                        BeanDefinition argumentBeanDefinition = parse(((Element) node),
                                parserContext, ArgumentConfig.class, false);
                        String name = id + "." + argumentIndex;
                        BeanDefinitionHolder argumentBeanDefinitionHolder = new BeanDefinitionHolder(
                                argumentBeanDefinition, name);
                        arguments.add(argumentBeanDefinitionHolder);
                    }
                }
            }
            if (arguments != null) {
                beanDefinition.getPropertyValues().addPropertyValue("arguments", arguments);    //关联arguments和其method
            }
        }
    }

}
现在，我们的dubbo就已经把配置文件中定义的bean全部解析成对应的beanDefinition，为spring的getBean做好准备工作。

beanDefinition -> bean

其实也就是从beanDefinition转换成bean的过程，我在网上找了一幅图，可以辅助我们了解spring内部是如何初始化bean的：


这里也有一篇不错的文章，从代码的角度描述了spring内部是如何使用BeanDefinition生成Bean的，dubbo就是委托给spring来管理bean的生命周期的。

那么dubbo自定义schemas所产生的beanDefinition，spring是如何将其转换成dubbo需要的bean呢？毕竟我们从上面的解析中看到，解析生成的beanDefinition中包含太多dubbo特殊的配置方式。这里我有两个猜测：

dubbo在spring提供的相关扩展点上实现了自己的getBean逻辑，可我却在dubbo的源码中找不到对应实现；
spring解析生成的beanDefinition并没有dubbo特殊性，交给默认的BeanFactory没啥问题（这都怪我spring太差啊~）
带着疑问我进行了严酷的单步调试，事实证明是第二种路数。到目前为止，dubbo已经按照我们提供的配置文件把所有需要的bean初始化完成，这部分基本上都是交给spring来搞定的。

这还不够，我们还不知道这些bean是怎么服务于业务！

bean -> service

那么到底是哪些bean最终会被dubbo直接拿来使用呢？其实DubboNamespaceHandler.init中的那些就是答案。我们先看一下这些类的关系：


其实这么复杂的关系最终都会被转换成字符串以URL的形式交给dubbo的底层最终暴露成服务。我们先来重点看一下ServiceBean的实现，了解一下服务提供方的细节。

按照上面uml图来看，这些xxxConfig类的关系已经很清楚了（谁继承谁，谁聚合谁，谁依赖谁）。不过图里并没有出现我们的目标：ServiceBean，补充下图：


除了继承父类外，我们也要注意ServiceBean实现的相关接口：

public class ServiceBean<T> extends ServiceConfig<T> implements InitializingBean, DisposableBean, ApplicationContextAware, ApplicationListener, BeanNameAware 
这里我们着重看InitializingBean接口，该接口为spring留给开发者的一个hook，用来执行初始化bean的个性化逻辑的回调，详情可以看这篇文章。

既然我们的ServiceBean实现了这个接口，意味着当spring进行容器初始化任务过程中，会执行我们在ServiceBean.afterPropertiesSet方法中安排的逻辑，这也是bean导出为服务的关键入口，先把本尊注释过的代码贴出来：

public class ServiceBean<T> extends ServiceConfig<T> implements InitializingBean, DisposableBean, ApplicationContextAware, ApplicationListener, BeanNameAware {

    private static final long serialVersionUID = 213195494150089726L;

    private static transient ApplicationContext SPRING_CONTEXT;

    private transient ApplicationContext applicationContext;

    private transient String beanName;

    private transient boolean supportedApplicationListener;

    public ServiceBean() {
        super();
    }

    public ServiceBean(Service service) {
        super(service);
    }

    public static ApplicationContext getSpringContext() {
        return SPRING_CONTEXT;
    }

    public void setApplicationContext(ApplicationContext applicationContext) {
        this.applicationContext = applicationContext;

        //把该应用上下文存储在SpringExtensionFactory（dubbo的SPI扩展点机制）中
        //把原先spring通过ApplicationContext获取bean的方式封装了一下，以dubbo统一的SPI扩展点机制风格接口暴露给业务使用
        SpringExtensionFactory.addApplicationContext(applicationContext);
        if (applicationContext != null) {
            SPRING_CONTEXT = applicationContext;
            try {
                //把所有serviceBean都加入到ApplicationContext的事件通知中
                Method method = applicationContext.getClass().getMethod("addApplicationListener", new Class<?>[]{ApplicationListener.class}); // 兼容Spring2.0.1
                method.invoke(applicationContext, new Object[] {this});
                supportedApplicationListener = true;
            } catch (Throwable t) {
                if (applicationContext instanceof AbstractApplicationContext) {
                    try {
                        Method method = AbstractApplicationContext.class.getDeclaredMethod("addListener", new Class<?>[]{ApplicationListener.class}); // 兼容Spring2.0.1
                        if (! method.isAccessible()) {
                            method.setAccessible(true);
                        }
                        method.invoke(applicationContext, new Object[] {this});
                        supportedApplicationListener = true;
                    } catch (Throwable t2) {
                    }
                }
            }
        }
    }

    public void setBeanName(String name) {
        this.beanName = name;
    }

    //如果配置serviceBean时声明了延迟暴露（例如：<dubbo:service delay="-1" />），则会依赖监听spring提供的相关事件来触发export
    public void onApplicationEvent(ApplicationEvent event) {
        if (ContextRefreshedEvent.class.getName().equals(event.getClass().getName())) { //监听ContextRefreshedEvent事件（容器发生初始化或更新时触发）
            if (isDelay() && ! isExported() && ! isUnexported()) {  //如果已导出过或者已手工放弃导出则不会执行export逻辑
                if (logger.isInfoEnabled()) {
                    logger.info("The service ready on spring started. service: " + getInterface());
                }
                export();
            }
        }
    }

    private boolean isDelay() {
        Integer delay = getDelay();
        ProviderConfig provider = getProvider();
        if (delay == null && provider != null) {    //若没有明确指定延迟，则尝试继承provider配置
            delay = provider.getDelay();
        }
        return supportedApplicationListener && (delay == null || delay.intValue() == -1);   //注意这里对delay值的条件很奇怪，如果我设置delay为5000毫秒时，难道不算是延迟么？请参考\com\alibaba\dubbo\config\ServiceConfig.java的132行
    }

    @SuppressWarnings({ "unchecked", "deprecation" })
    public void afterPropertiesSet() throws Exception {
        if (getProvider() == null) {    //如果当前serviceBean并没有指定provider，则下面的逻辑为其指定默认的providerConfig（如果存在的话）
            Map<String, ProviderConfig> providerConfigMap = applicationContext == null ? null  : BeanFactoryUtils.beansOfTypeIncludingAncestors(applicationContext, ProviderConfig.class, false, false);
            if (providerConfigMap != null && providerConfigMap.size() > 0) {
                Map<String, ProtocolConfig> protocolConfigMap = applicationContext == null ? null  : BeanFactoryUtils.beansOfTypeIncludingAncestors(applicationContext, ProtocolConfig.class, false, false);
                if ((protocolConfigMap == null || protocolConfigMap.size() == 0)
                        && providerConfigMap.size() > 1) { // 兼容旧版本
                    List<ProviderConfig> providerConfigs = new ArrayList<ProviderConfig>();
                    for (ProviderConfig config : providerConfigMap.values()) {
                        if (config.isDefault() != null && config.isDefault().booleanValue()) {  //把所有指定为默认范围的providerConfig拿到，跳转到下面
                            providerConfigs.add(config);
                        }
                    }
                    if (providerConfigs.size() > 0) {
                        setProviders(providerConfigs);  //接着上面，把所有指定为默认范围的providerConfig中与protocol相关的配置封装成protocolConfig并存入serviceConfig对应属性中
                    }
                } else {
                    ProviderConfig providerConfig = null;
                    for (ProviderConfig config : providerConfigMap.values()) {
                        //如果某个provider配置包含子node（ServiceBean），且没有明确指定default，也会被当成默认配置么？这个疑问请参看：com\alibaba\dubbo\config\spring\schema\DubboBeanDefinitionParser.java中330行注解
                        if (config.isDefault() == null || config.isDefault().booleanValue()) {
                            if (providerConfig != null) {   //只能有一个provider设置为默认
                                throw new IllegalStateException("Duplicate provider configs: " + providerConfig + " and " + config);
                            }
                            providerConfig = config;
                        }
                    }
                    if (providerConfig != null) {
                        setProvider(providerConfig);    //为serviceBean绑定继承的providerConfig
                    }
                }
            }
        }
        //如果当前serviceBean并没有指定Application且其继承的provider也没有指定Application，则下面的逻辑为其指定默认的applicationConfig（如果存在的话）
        if (getApplication() == null
                && (getProvider() == null || getProvider().getApplication() == null)) {
            Map<String, ApplicationConfig> applicationConfigMap = applicationContext == null ? null : BeanFactoryUtils.beansOfTypeIncludingAncestors(applicationContext, ApplicationConfig.class, false, false);
            if (applicationConfigMap != null && applicationConfigMap.size() > 0) {
                ApplicationConfig applicationConfig = null;
                for (ApplicationConfig config : applicationConfigMap.values()) {
                    if (config.isDefault() == null || config.isDefault().booleanValue()) {
                        if (applicationConfig != null) {    //只能有一个Application设置为默认
                            throw new IllegalStateException("Duplicate application configs: " + applicationConfig + " and " + config);
                        }
                        applicationConfig = config;
                    }
                }
                if (applicationConfig != null) {
                    setApplication(applicationConfig);  //为serviceBean绑定applicationConfig
                }
            }
        }
        //如果当前serviceBean并没有指定Module且其继承的provider也没有指定Module，则下面的逻辑为其指定默认的moduleConfig（如果存在的话）
        if (getModule() == null
                && (getProvider() == null || getProvider().getModule() == null)) {
            Map<String, ModuleConfig> moduleConfigMap = applicationContext == null ? null : BeanFactoryUtils.beansOfTypeIncludingAncestors(applicationContext, ModuleConfig.class, false, false);
            if (moduleConfigMap != null && moduleConfigMap.size() > 0) {
                ModuleConfig moduleConfig = null;
                for (ModuleConfig config : moduleConfigMap.values()) {
                    if (config.isDefault() == null || config.isDefault().booleanValue()) {
                        if (moduleConfig != null) { //只能有一个Module设置为默认
                            throw new IllegalStateException("Duplicate module configs: " + moduleConfig + " and " + config);
                        }
                        moduleConfig = config;
                    }
                }
                if (moduleConfig != null) {
                    setModule(moduleConfig);    //为serviceBean绑定moduleConfig
                }
            }
        }
        //如果当前serviceBean并没有指定Registry且其继承的provider,application也没有指定Registry，则下面的逻辑为其指定默认的registryConfig（如果存在的话）
        if ((getRegistries() == null || getRegistries().size() == 0)
                && (getProvider() == null || getProvider().getRegistries() == null || getProvider().getRegistries().size() == 0)
                && (getApplication() == null || getApplication().getRegistries() == null || getApplication().getRegistries().size() == 0)) {
            Map<String, RegistryConfig> registryConfigMap = applicationContext == null ? null : BeanFactoryUtils.beansOfTypeIncludingAncestors(applicationContext, RegistryConfig.class, false, false);
            if (registryConfigMap != null && registryConfigMap.size() > 0) {
                List<RegistryConfig> registryConfigs = new ArrayList<RegistryConfig>();
                for (RegistryConfig config : registryConfigMap.values()) {
                    if (config.isDefault() == null || config.isDefault().booleanValue()) {  //允许为serviceBean指定多个Registry
                        registryConfigs.add(config);
                    }
                }
                if (registryConfigs != null && registryConfigs.size() > 0) {
                    super.setRegistries(registryConfigs);
                }
            }
        }
        //如果当前serviceBean并没有指定Monitor且其继承的provider,application也没有指定Monitor，则下面的逻辑为其指定默认的monitorConfig（如果存在的话）
        if (getMonitor() == null
                && (getProvider() == null || getProvider().getMonitor() == null)
                && (getApplication() == null || getApplication().getMonitor() == null)) {
            Map<String, MonitorConfig> monitorConfigMap = applicationContext == null ? null : BeanFactoryUtils.beansOfTypeIncludingAncestors(applicationContext, MonitorConfig.class, false, false);
            if (monitorConfigMap != null && monitorConfigMap.size() > 0) {
                MonitorConfig monitorConfig = null;
                for (MonitorConfig config : monitorConfigMap.values()) {
                    if (config.isDefault() == null || config.isDefault().booleanValue()) {
                        if (monitorConfig != null) {    //只能有一个Monitor设置为默认
                            throw new IllegalStateException("Duplicate monitor configs: " + monitorConfig + " and " + config);
                        }
                        monitorConfig = config;
                    }
                }
                if (monitorConfig != null) {
                    setMonitor(monitorConfig);  //为serviceBean绑定monitorConfig
                }
            }
        }
        //如果当前serviceBean并没有指定Protocol且其继承的provider也没有指定Protocol，则下面的逻辑为其指定默认的protocolConfig（如果存在的话）
        if ((getProtocols() == null || getProtocols().size() == 0)
                && (getProvider() == null || getProvider().getProtocols() == null || getProvider().getProtocols().size() == 0)) {
            Map<String, ProtocolConfig> protocolConfigMap = applicationContext == null ? null  : BeanFactoryUtils.beansOfTypeIncludingAncestors(applicationContext, ProtocolConfig.class, false, false);
            if (protocolConfigMap != null && protocolConfigMap.size() > 0) {
                List<ProtocolConfig> protocolConfigs = new ArrayList<ProtocolConfig>();
                for (ProtocolConfig config : protocolConfigMap.values()) {
                    if (config.isDefault() == null || config.isDefault().booleanValue()) {
                        protocolConfigs.add(config);    //允许为serviceBean指定多个Protocol
                    }
                }
                if (protocolConfigs != null && protocolConfigs.size() > 0) {
                    super.setProtocols(protocolConfigs);
                }
            }
        }
        //设置服务路径，默认使用的是该bean在spring容器中注册的beanName，这也是该类继承BeanNameAware的原因
        if (getPath() == null || getPath().length() == 0) {
            if (beanName != null && beanName.length() > 0 
                    && getInterface() != null && getInterface().length() > 0
                    && beanName.startsWith(getInterface())) {
                setPath(beanName);
            }
        }
        //若不是延迟加载，就上演好戏
        if (! isDelay()) {
            export();
        }
    }

    public void destroy() throws Exception {
        unexport();
    }
}
这里就明白为何ServiceBean和其父类ServiceConfig不在同一个包内，因为前者是为了适配spring而提供的适配器。ServiceBean依赖spring提供的相关hook接口完成了bean的初始化，最终export逻辑交给ServiceConfig来完成，这才是dubbo的核心服务配置类，这也解释了为何上面UML图中没有画ServiceBean的原因。

我们继续跟着线索来看一下ServiceConfig.export：

public synchronized void export() {
    //从provider中继承一些必要但没有明确设置的参数
    if (provider != null) {
        if (export == null) {
            export = provider.getExport();
        }
        if (delay == null) {
            delay = provider.getDelay();
        }
    }
    if (export != null && ! export.booleanValue()) {    //如果不需要暴露该服务，则就此结束
        return;
    }
    if (delay != null && delay > 0) {   //如果明确指定了想要延迟的时间差，则依赖线程休眠来完成延迟暴露，delay的值只有为-1或null才依赖spring的事件机制完成延迟暴露
        Thread thread = new Thread(new Runnable() {
            public void run() {
                try {
                    Thread.sleep(delay);
                } catch (Throwable e) {
                }
                doExport();
            }
        });
        thread.setDaemon(true);
        thread.setName("DelayExportServiceThread");
        thread.start();
    } else {
        doExport();
    }
}
一目了然，这个方法主要就是解决了到底暴露不暴露的问题，并且到底是不是延迟暴露的问题。接下来看看doExport方法：

protected synchronized void doExport() {
    if (unexported) {
        throw new IllegalStateException("Already unexported!");
    }
    if (exported) {
        return;
    }

    exported = true;    //修改暴露状态

    if (interfaceName == null || interfaceName.length() == 0) {
        throw new IllegalStateException("<dubbo:service interface=\"\" /> interface not allow null!");
    }

    checkDefault(); //根据文档中提到的参数优先级，决定最终使用的配置值，在spring的xml解析阶段只是简单解析xml的配置值，在真正使用前，还需要看一下：-D和properties文件

    //下面根据文档中的优先级创建对应的继承链
    if (provider != null) { //todo 这里必然成立吧？
        if (application == null) {
            application = provider.getApplication();
        }
        if (module == null) {
            module = provider.getModule();
        }
        if (registries == null) {
            registries = provider.getRegistries();
        }
        if (monitor == null) {
            monitor = provider.getMonitor();
        }
        if (protocols == null) {
            protocols = provider.getProtocols();
        }
    }
    if (module != null) {
        if (registries == null) {
            registries = module.getRegistries();
        }
        if (monitor == null) {
            monitor = module.getMonitor();
        }
    }
    if (application != null) {
        if (registries == null) {
            registries = application.getRegistries();
        }
        if (monitor == null) {
            monitor = application.getMonitor();
        }
    }

    if (ref instanceof GenericService) {    //泛接口实现方式主要用于服务器端没有API接口及模型类元的情况，参数及返回值中的所有POJO均用Map表示，通常用于框架集成，比如：实现一个通用的远程服务Mock框架，可通过实现GenericService接口处理所有服务请求。
        interfaceClass = GenericService.class;
        if (StringUtils.isEmpty(generic)) {
            generic = Boolean.TRUE.toString();
        }
    } else {
        try {
            interfaceClass = Class.forName(interfaceName, true, Thread.currentThread()
                    .getContextClassLoader());
        } catch (ClassNotFoundException e) {
            throw new IllegalStateException(e.getMessage(), e);
        }
        checkInterfaceAndMethods(interfaceClass, methods);  //检查接口和方法的匹配情况
        checkRef(); //检查接口和实现的匹配情况
        generic = Boolean.FALSE.toString();
    }

    if(local !=null){   //todo 文档中并没有与local相关的参数解释
        if(local=="true"){
            local=interfaceName+"Local";
        }
        Class<?> localClass;
        try {
            localClass = ClassHelper.forNameWithThreadContextClassLoader(local);
        } catch (ClassNotFoundException e) {
            throw new IllegalStateException(e.getMessage(), e);
        }
        if(!interfaceClass.isAssignableFrom(localClass)){
            throw new IllegalStateException("The local implemention class " + localClass.getName() + " not implement interface " + interfaceName);
        }
    }

    //本地存根，http://alibaba.github.io/dubbo-doc-static/Stub+Proxy-zh.htm
    if(stub !=null){
        if(stub=="true"){
            stub=interfaceName+"Stub";  //todo 这里文档中的解释貌似有错误：http://alibaba.github.io/dubbo-doc-static/Service+Config-zh.htm
        }
        Class<?> stubClass;
        try {
            stubClass = ClassHelper.forNameWithThreadContextClassLoader(stub);
        } catch (ClassNotFoundException e) {
            throw new IllegalStateException(e.getMessage(), e);
        }
        if(!interfaceClass.isAssignableFrom(stubClass)){
            throw new IllegalStateException("The stub implemention class " + stubClass.getName() + " not implement interface " + interfaceName);
        }
    }

    //作用雷同于上面的checkDefault()，根据文档中提到的参数优先级来选择使用的配置参数
    checkApplication();
    checkRegistry();
    checkProtocol();
    appendProperties(this);

    checkStubAndMock(interfaceClass);   //检查local，stub和mock的有效性

    if (path == null || path.length() == 0) {   //此时path如果还为空，这使用interfaceName
        path = interfaceName;
    }

    doExportUrls();
}
木牛错，doExport方法依然是在做预备工作，感觉越来越靠近真像了，目前为止，我们已经按照规定的优先级最终确定了要暴露成为服务的bean的”大部分”相关配置参数，并校验了相关参数的有效性（例如：ref，method，stub，mock，path等）。再来看一下doExportUrls方法：

private void doExportUrls() {
    List<URL> registryURLs = loadRegistries(true);  //获取所有的注册中心地址
    for (ProtocolConfig protocolConfig : protocols) {
        doExportUrlsFor1Protocol(protocolConfig, registryURLs);
    }
}
好，是该真刀真枪干一架的时候了，doExportUrlsFor1Protocol应该就是今次的Boss，解决掉它我们就回家。

private void doExportUrlsFor1Protocol(ProtocolConfig protocolConfig, List<URL> registryURLs) {
    String name = protocolConfig.getName();
    if (name == null || name.length() == 0) {
        name = "dubbo"; //N多次的检查，N多次的赋值，这算是严谨呢？还是重复？
    }

    String host = protocolConfig.getHost();
    if (provider != null && (host == null || host.length() == 0)) {
        host = provider.getHost();
    }
    boolean anyhost = false;
    if (NetUtils.isInvalidLocalHost(host)) {    //检查host是否为本地ip，或者无效的
        anyhost = true;
        try {
            host = InetAddress.getLocalHost().getHostAddress();
        } catch (UnknownHostException e) {
            logger.warn(e.getMessage(), e);
        }
        if (NetUtils.isInvalidLocalHost(host)) {    //如果拿到的还是本地地址，就只能出杀手锏了
            if (registryURLs != null && registryURLs.size() > 0) {
                for (URL registryURL : registryURLs) {
                    try {
                        Socket socket = new Socket();
                        try {
                            //尝试连接注册中心，选用连接时使用的ip地址
                            SocketAddress addr = new InetSocketAddress(registryURL.getHost(), registryURL.getPort());
                            socket.connect(addr, 1000);
                            host = socket.getLocalAddress().getHostAddress();
                            break;
                        } finally {
                            try {
                                socket.close();
                            } catch (Throwable e) {}
                        }
                    } catch (Exception e) {
                        logger.warn(e.getMessage(), e);
                    }
                }
            }
            if (NetUtils.isInvalidLocalHost(host)) {
                host = NetUtils.getLocalHost(); //实在不行，就只能使用本机上第一个找到的合法ip了
            }
        }
    }

    Integer port = protocolConfig.getPort();
    if (provider != null && (port == null || port == 0)) {
        port = provider.getPort();
    }
    final int defaultPort = ExtensionLoader.getExtensionLoader(Protocol.class).getExtension(name).getDefaultPort();
    if (port == null || port == 0) {
        port = defaultPort;
    }
    if (port == null || port <= 0) {
        port = getRandomPort(name);
        if (port == null || port < 0) {
            port = NetUtils.getAvailablePort(defaultPort);  //到这里如果还没有拿到port，就直接随机拿个能用的端口
            putRandomPort(name, port);  //这一步很讲究，意味着相同协议使用相同的端口，要理解这个就需要先消化dubbo底层通信方式。
        }
        logger.warn("Use random available port(" + port + ") for protocol " + name);
    }

    Map<String, String> map = new HashMap<String, String>();
    if (anyhost) {
        map.put(Constants.ANYHOST_KEY, "true");
    }
    map.put(Constants.SIDE_KEY, Constants.PROVIDER_SIDE);
    map.put(Constants.DUBBO_VERSION_KEY, Version.getVersion());
    map.put(Constants.TIMESTAMP_KEY, String.valueOf(System.currentTimeMillis()));
    if (ConfigUtils.getPid() > 0) {
        map.put(Constants.PID_KEY, String.valueOf(ConfigUtils.getPid()));
    }

    //获取相关的配置参数用于后面的url生成，注意优先级顺序哟
    appendParameters(map, application);
    appendParameters(map, module);
    appendParameters(map, provider, Constants.DEFAULT_KEY);
    appendParameters(map, protocolConfig);
    appendParameters(map, this);

    if (methods != null && methods.size() > 0) {
        for (MethodConfig method : methods) {
            appendParameters(map, method, method.getName());

            //处理重试设置
            String retryKey = method.getName() + ".retry";
            if (map.containsKey(retryKey)) {
                String retryValue = map.remove(retryKey);
                if ("false".equals(retryValue)) {
                    map.put(method.getName() + ".retries", "0");
                }
            }

            List<ArgumentConfig> arguments = method.getArguments();
            if (arguments != null && arguments.size() > 0) {
                for (ArgumentConfig argument : arguments) { //ArgumentConfig作用主要就是用来完成事件回调机制。
                    //类型自动转换.
                    if(argument.getType() != null && argument.getType().length() >0){
                        Method[] methods = interfaceClass.getMethods();
                        //遍历所有方法
                        if(methods != null && methods.length > 0){
                            for (int i = 0; i < methods.length; i++) {
                                String methodName = methods[i].getName();
                                //匹配方法名称，获取方法签名.
                                if(methodName.equals(method.getName())){    //注意方法重载情况
                                    Class<?>[] argtypes = methods[i].getParameterTypes();
                                    //一个方法中单个callback
                                    if (argument.getIndex() != -1 ){    //todo 这部分和文档写的有出入，不过这也不是第一次了。。
                                        if (argtypes[argument.getIndex()].getName().equals(argument.getType())){
                                            appendParameters(map, argument, method.getName() + "." + argument.getIndex());
                                        }else {
                                            throw new IllegalArgumentException("argument config error : the index attribute and type attirbute not match :index :"+argument.getIndex() + ", type:" + argument.getType());
                                        }
                                    } else {
                                        //一个方法中多个callback
                                        for (int j = 0 ;j<argtypes.length ;j++) {   //todo 这部分和文档写的有出入，不过这也不是第一次了。。
                                            Class<?> argclazz = argtypes[j];
                                            if (argclazz.getName().equals(argument.getType())){
                                                appendParameters(map, argument, method.getName() + "." + j);
                                                if (argument.getIndex() != -1 && argument.getIndex() != j){
                                                    throw new IllegalArgumentException("argument config error : the index attribute and type attirbute not match :index :"+argument.getIndex() + ", type:" + argument.getType());
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }else if(argument.getIndex() != -1){
                        appendParameters(map, argument, method.getName() + "." + argument.getIndex());
                    }else {
                        throw new IllegalArgumentException("argument config must set index or type attribute.eg: <dubbo:argument index='0' .../> or <dubbo:argument type=xxx .../>");
                    }

                }
            }
        } // end of methods for
    }

    if (ProtocolUtils.isGeneric(generic)) { //处理泛化
        map.put("generic", generic);
        map.put("methods", Constants.ANY_VALUE);
    } else {
        String revision = Version.getVersion(interfaceClass, version);
        if (revision != null && revision.length() > 0) {
            map.put("revision", revision);  //todo 为什么是revision?
        }

        String[] methods = Wrapper.getWrapper(interfaceClass).getMethodNames(); //todo 动态封装interfaceClass，目前不知道干啥用，猜测dubbo直接操作的都是这个封装后的wrapper
        if(methods.length == 0) {
            logger.warn("NO method found in service interface " + interfaceClass.getName());
            map.put("methods", Constants.ANY_VALUE);
        }
        else {
            map.put("methods", StringUtils.join(new HashSet<String>(Arrays.asList(methods)), ","));
        }
    }

    //令牌验证，为空表示不开启，如果为true，表示随机生成动态令牌，否则使用静态令牌，令牌的作用是防止消费者绕过注册中心直接访问，保证注册中心的授权功能有效，如果使用点对点调用，需关闭令牌功能
    if (! ConfigUtils.isEmpty(token)) {
        if (ConfigUtils.isDefault(token)) {
            map.put("token", UUID.randomUUID().toString());
        } else {
            map.put("token", token);
        }
    }

    //injvm表示不会跨进程，所以不需要注册中心
    if ("injvm".equals(protocolConfig.getName())) {
        protocolConfig.setRegister(false);
        map.put("notify", "false");
    }

    // 导出服务
    String contextPath = protocolConfig.getContextpath();
    if ((contextPath == null || contextPath.length() == 0) && provider != null) {
        contextPath = provider.getContextpath();
    }
    URL url = new URL(name, host, port, (contextPath == null || contextPath.length() == 0 ? "" : contextPath + "/") + path, map);   //拿到服务的url

    if (ExtensionLoader.getExtensionLoader(ConfiguratorFactory.class)
            .hasExtension(url.getProtocol())) {
        url = ExtensionLoader.getExtensionLoader(ConfiguratorFactory.class)
                .getExtension(url.getProtocol()).getConfigurator(url).configure(url);
    }

    String scope = url.getParameter(Constants.SCOPE_KEY);
    //配置为none不暴露
    if (! Constants.SCOPE_NONE.toString().equalsIgnoreCase(scope)) {

        //配置不是remote的情况下做本地暴露 (配置为remote，则表示只暴露远程服务)
        if (!Constants.SCOPE_REMOTE.toString().equalsIgnoreCase(scope)) {
            exportLocal(url);
        }
        //如果配置不是local则暴露为远程服务.(配置为local，则表示只暴露远程服务)
        if (! Constants.SCOPE_LOCAL.toString().equalsIgnoreCase(scope) ){
            if (logger.isInfoEnabled()) {
                logger.info("Export dubbo service " + interfaceClass.getName() + " to url " + url);
            }
            if (registryURLs != null && registryURLs.size() > 0
                    && url.getParameter("register", true)) {
                for (URL registryURL : registryURLs) {
                    url = url.addParameterIfAbsent("dynamic", registryURL.getParameter("dynamic"));
                    URL monitorUrl = loadMonitor(registryURL);
                    if (monitorUrl != null) {
                        url = url.addParameterAndEncoded(Constants.MONITOR_KEY, monitorUrl.toFullString());
                    }
                    if (logger.isInfoEnabled()) {
                        logger.info("Register dubbo service " + interfaceClass.getName() + " url " + url + " to registry " + registryURL);
                    }
                    //todo 暴露为何要封装一层代理呢？
                    Invoker<?> invoker = proxyFactory.getInvoker(ref, (Class) interfaceClass, registryURL.addParameterAndEncoded(Constants.EXPORT_KEY, url.toFullString()));

                    Exporter<?> exporter = protocol.export(invoker);
                    exporters.add(exporter);
                }
            } else {
                //todo 暴露为何要封装一层代理呢？
                Invoker<?> invoker = proxyFactory.getInvoker(ref, (Class) interfaceClass, url);

                Exporter<?> exporter = protocol.export(invoker);
                exporters.add(exporter);
            }
        }
    }
    this.urls.add(url);
}
一路走来可以发现，dubbo会为每个有效协议暴露一份服务，并且会注册到所有有效的注册中心里。而bean转变为service中最重要的就是映射出来的URL，也就是说我们在配置文件中进行的相关配置都会映射成对应url中的相关部分，举个例子：

<dubbo:application name="demo-provider" owner="programmer" organization="dubbox"/>
<dubbo:registry address="zookeeper://127.0.0.1:2181"/>
<dubbo:protocol name="dubbo" serialization="kryo" optimizer="com.alibaba.dubbo.demo.SerializationOptimizerImpl"/>

<bean id="bidService" class="com.alibaba.dubbo.demo.bid.BidServiceImpl" />
<dubbo:service interface="com.alibaba.dubbo.demo.bid.BidService" ref="bidService"  protocol="dubbo" />
我们通过debug看一下最终它映射出来的url是什么：

//exportLocal
injvm://127.0.0.1/com.alibaba.dubbo.demo.bid.BidService?anyhost=true&application=demo-provider&dubbo=2.0.0&generic=false&interface=com.alibaba.dubbo.demo.bid.BidService&methods=throwNPE,bid&optimizer=com.alibaba.dubbo.demo.SerializationOptimizerImpl&organization=dubbox&owner=programmer&pid=3872&serialization=kryo&side=provider&timestamp=1422241023451

//exportRemote
registry://127.0.0.1:2181/com.alibaba.dubbo.registry.RegistryService?application=demo-provider&dubbo=2.0.0&export=dubbo%3A%2F%2F192.168.153.1%3A20880%2Fcom.alibaba.dubbo.demo.bid.BidService%3Fanyhost%3Dtrue%26application%3Ddemo-provider%26dubbo%3D2.0.0%26generic%3Dfalse%26interface%3Dcom.alibaba.dubbo.demo.bid.BidService%26methods%3DthrowNPE%2Cbid%26optimizer%3Dcom.alibaba.dubbo.demo.SerializationOptimizerImpl%26organization%3Ddubbox%26owner%3Dprogrammer%26pid%3D3872%26serialization%3Dkryo%26side%3Dprovider%26timestamp%3D1422241023451&organization=dubbox&owner=programmer&pid=3872&registry=zookeeper&timestamp=1422240274186
那么这个url的作用是什么呢？官方给出的解释很明确，这个url作为解耦的通信数据（跨层调用的参数），有了它dubbo就可以更容易做到业务逻辑实现的替换。除此之外可以看到url中还包含了大量的辅助参数（例如：timeout，version，organization等）供服务治理使用，这些都是根据真实需求一步一步补充完善的，可见，好的架构是演化而来的。

可以看到贴出来的代码中包含很多todo项，其中一些问题我们从代码层面是很难找到答案的，我们需要上升到业务，运维甚至架构师高度才能消化得了，小弟将在后续的分析中慢慢的尝试解开谜团。

最后更新时间：2018年2月14日 8:37 
这里写留言或版权声明：http://blog.kazaff.me/2015/01/26/dubbo如何一步一步拿到bean/