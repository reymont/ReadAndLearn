* Spring之FactoryBean - CSDN博客 
  http://blog.csdn.net/is_zhoufeng/article/details/38422549
* http://yjc0407.iteye.com/blog/1036054
* https://spring.io/blog/2011/08/09/what-s-a-factorybean

A `FactoryBean` is a pattern to encapsulate interesting object construction logic in a class. It might be used, for example, to encode the construction of a complex object graph in a reusable way. Often this is used to construct complex objects that have many dependencies. It might also be used when the construction logic itself is highly volatile and depends on the configuration. A FactoryBean is also useful to help Spring construct objects that it couldn’t easily construct itself. For example, in order to inject a reference to a bean that was obtained from JNDI, the reference must first be obtained. You can use the JndiFactoryBean to obtain this reference in a consistent way. You may inject the result of a FactoryBean’s getObject() method into any other property.

`FactoryBean`是一个类封装对象构造逻辑的模式。例如：使用可重用的方式编码复杂对象图的构造。通常使用这种模式构造许多依赖关系的复杂对象。当结构逻辑本身高度不稳定并且取决于配置时，它也可能被使用。如果不能容易地构建本身，`FactoryBean`也能有所帮助。例如，为了从JNDI引用一个bean，必须先获得引用。你可以使用一致的方式，即`JndiFactoryBean`来获得这个引用。你可以在任何属性注入，`FactoryBean`中getobject()方法返回的结果。

Spring的BeanFacotry是一个类工厂，使用它来创建各种类型的Bean，最主要的方法就是getBean(String beanName),该方法从容器中返回特定名称的Bean，只不过其中有一种Bean是FacotryBean.

一个Bean 要想成为FacotryBean，必须实现FactoryBean 这个接口。
FactoryBean定义了三个接口方法：
1. Object getObject():返回由FactoryBean创建的Bean的实例，如果isSingleton（）方法返回true,是单例的实例，该实例将放入Spring的缓冲池中；
2. boolean isSingleton*():确定由FactoryBean创建的Bean的作用域是singleton还是prototype；
3. getObjectType():返回FactoryBean创建的Bean的类型。

FactoryBean 是一直特殊的bean,它实际上也是一个工厂，我们在通过FactoryBeanName得到的Bean,是FacotryBean创建的Bean,即它通过getObject()创建的Bean.我们要想得到FactoryBean本身，必须通过&FactoryBeanName得到，即在BeanFactory中通过getBean(&FactoryBeanName)来得到 FactoryBean
注：在spring 中是通过BeanFactoryUtils.isFactoryDereference()来判断一个Bean是否是FactoryBean.

spring 内部实现中应该是在通过BeanFacotry 的getBean(String beanName) 来得到Bean时，如果这个Bean是一个FactoryBean,则把它生成的Bean返回，否者直接返回Bean.

* BeanFactory：以Factory结尾，表示它是一个工厂类，是用于管理Bean的一个工厂
* FactoryBean：以Bean结尾，表示它是一个Bean，不同于普通Bean的是：
  * 它是实现了FactoryBean<T>接口的Bean，
  * 根据该Bean的Id从BeanFactory中获取的实际上是`FactoryBean的getObject()返回的对象`，而不是FactoryBean本身 
  * 如果要获取FactoryBean对象，可以在id前面加一个&符号来获取。

# Spring中的Bean有两种

## 一种是普通的bean ，比如配置
```xml
<bean id="personService" class="com.spring.service.impl.PersonServiceImpl" scope="prototype">  
    <property name="name" value="is_zhoufeng" />  
</bean>
```
那个使用BeanFactory根据id personService获取bean的时候，得到的对象就是PersonServiceImpl类型的。

## 实现了org.springframework.beans.factory.FactoryBean<T>接口的Bean

另外一种就是实现了org.springframework.beans.factory.FactoryBean<T>接口的Bean，那么在从BeanFactory中根据定义的id获取bean的时候，获取的实际上是FactoryBean接口中的getObject()方法返回的对象。

以Spring提供的ProxyFactoryBean为例子，配置如下：

```xml
<bean id="personServiceByLog" class="org.springframework.aop.framework.ProxyFactoryBean">  
    <property name="proxyInterfaces">  
        <list>  
            <value>com.spring.service.PersonService</value>  
        </list>  
    </property>  
    <property name="interceptorNames">  
        <list>  
            <value>logInteceptor</value>  
            <value>ZFMethodAdvice</value>  
        </list>  
    </property>  
    <property name="targetName" value="personService" />    
</bean>  
```


```java
// 那么在代码中根据personServiceByLog来获取的Bean实际上是PersonService类型的。 
@Test  
 public void test01() {  
  
     PersonService ps = context.getBean("personServiceByLog", PersonService.class);  
  
     ps.sayHello();  
  
     String name = ps.getName();  
  
     System.out.println(name);  
 }  
// 如果要获取ProxyFactoryBean本身，可以如下
@Test  
 public void test04() {  
     ProxyFactoryBean factoryBean = context.getBean("&personServiceByLog", ProxyFactoryBean.class);  
     PersonService ps = (PersonService) factoryBean.getObject();  
     String name = ps.getName();  
     System.out.println(name);  
  
 }  
```

## 自己实现一个FactoryBean

自己实现一个FactoryBean， 功能：用来代理一个对象，对该对象的所有方法做一个拦截，在方法调用前后都输出一行log

```java
package com.spring.factorybean;  
  
import java.lang.reflect.InvocationHandler;  
import java.lang.reflect.Method;  
import java.lang.reflect.Proxy;  
  
import org.springframework.beans.factory.DisposableBean;  
import org.springframework.beans.factory.FactoryBean;  
import org.springframework.beans.factory.InitializingBean;  
  
public class ZFFactoryBean implements FactoryBean<Object>, InitializingBean, DisposableBean {  
  
    // 被代理对象实现的接口名（在使用Proxy时需要用到，用于决定生成的代理对象类型）  
    private String interfaceName;  
  
    // 被代理的对象  
    private Object target;  
  
    // 生成的代理对象  
    private Object proxyObj;  
  
    public void destroy() throws Exception {  
        System.out.println("distory...");  
    }  
  
    public void afterPropertiesSet() throws Exception {  
  
        proxyObj = Proxy.newProxyInstance(this.getClass().getClassLoader(),  
                                          new Class[] { Class.forName(interfaceName) }, new InvocationHandler() {  
  
                                              public Object invoke(Object proxy, Method method, Object[] args)  
                                                                                                              throws Throwable {  
                                                  System.out.println("method:" + method.getName());  
                                                  System.out.println("Method before...");  
                                                  Object result = method.invoke(target, args);  
                                                  System.out.println("Method after...");  
                                                  return result;  
                                              }  
                                          });  
  
        System.out.println("afterPropertiesSet");  
    }  
  
    public Object getObject() throws Exception {  
        System.out.println("getObject");  
        return proxyObj;  
    }  
  
    public Class<?> getObjectType() {  
        return proxyObj == null ? Object.class : proxyObj.getClass();  
    }  
  
    public boolean isSingleton() {  
        return true;  
    }  
  
    public String getInterfaceName() {  
        return interfaceName;  
    }  
  
    public void setInterfaceName(String interfaceName) {  
        this.interfaceName = interfaceName;  
    }  
  
    public Object getTarget() {  
        return target;  
    }  
  
    public void setTarget(Object target) {  
        this.target = target;  
    }  
  
}  
```

然后来试试：
首先这样定义bean

```xml
<bean id="personService" class="com.spring.service.impl.PersonServiceImpl" scope="prototype">  
    <property name="name" value="is_zhoufeng" />  
</bean>    

<bean id="zfPersonService" class="com.spring.factorybean.ZFFactoryBean">  
    <property name="interfaceName" value="com.spring.service.PersonService" />  
    <property name="target"  ref="personService"/>  
</bean>  
```
```java
// 然后获取Bean，并测试。
@Test  
 public void test06() {  
     PersonService ps = context.getBean("zfPersonService", PersonService.class);  
  
     ps.sayHello();  
  
     String name = ps.getName();  
  
     System.out.println(name);  
 }  
```