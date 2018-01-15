Spring之FactoryBean - CSDN博客 http://blog.csdn.net/is_zhoufeng/article/details/38422549

* BeanFactory： 以Factory结尾，表示它是一个工厂类，是用于管理Bean的一个工厂
* FactoryBean：以Bean结尾，表示它是一个Bean，不同于普通Bean的是：
  * 它是实现了FactoryBean<T>接口的Bean，
  * 根据该Bean的Id从BeanFactory中获取的实际上是FactoryBean的getObject()返回的对象，而不是FactoryBean本身 
  * 如果要获取FactoryBean对象，可以在id前面加一个&符号来获取。

# Spring中的Bean有两种。

* 一种是普通的bean ，比如配置
```xml
<bean id="personService" class="com.spring.service.impl.PersonServiceImpl" scope="prototype">  
    <property name="name" value="is_zhoufeng" />  
</bean>
```
那个使用BeanFactory根据id personService获取bean的时候，得到的对象就是PersonServiceImpl类型的。

* 另外一种就是实现了org.springframework.beans.factory.FactoryBean<T>接口的Bean，那么在从BeanFactory中根据定义的id获取bean的时候，获取的实际上是FactoryBean接口中的getObject()方法返回的对象。

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

那么在代码中根据personServiceByLog来获取的Bean实际上是PersonService类型的。 
```java
@Test  
 public void test01() {  
  
     PersonService ps = context.getBean("personServiceByLog", PersonService.class);  
  
     ps.sayHello();  
  
     String name = ps.getName();  
  
     System.out.println(name);  
 }  
```

如果要获取ProxyFactoryBean本身，可以如下
[java] view plain copy
@Test  
 public void test04() {  
     ProxyFactoryBean factoryBean = context.getBean("&personServiceByLog", ProxyFactoryBean.class);  
     PersonService ps = (PersonService) factoryBean.getObject();  
     String name = ps.getName();  
     System.out.println(name);  
  
 }  

自己实现一个FactoryBean， 功能：用来代理一个对象，对该对象的所有方法做一个拦截，在方法调用前后都输出一行log

[java] view plain copy
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


然后来试试：
首先这样定义bean

[java] view plain copy
<bean id="personService" class="com.spring.service.impl.PersonServiceImpl" scope="prototype">  
            <property name="name" value="is_zhoufeng" />  
      </bean>    
        
      <bean id="zfPersonService" class="com.spring.factorybean.ZFFactoryBean">  
        <property name="interfaceName" value="com.spring.service.PersonService" />  
        <property name="target"  ref="personService"/>  
      </bean>  
然后获取Bean，并测试。
[java] view plain copy
@Test  
 public void test06() {  
     PersonService ps = context.getBean("zfPersonService", PersonService.class);  
  
     ps.sayHello();  
  
     String name = ps.getName();  
  
     System.out.println(name);  
 }  

会发现sayHello与getName方法调用前后都有log打印。




上面的ZFBeanFactory只是模仿了ProxyFactoryBean的功能做了一个实现而已。

其实通过FactoryBean这种特点，可以实现很多有用的功能 。。