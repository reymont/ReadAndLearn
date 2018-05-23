


* [Cglib及其基本使用 - 五月的仓颉 - 博客园 ](http://www.cnblogs.com/xrq730/p/6661692.html)


![cglib-structure.gif](img/cglib-structure.gif)

对此图总结一下：

* 最底层的是`字节码Bytecode`，字节码是Java为了保证“一次编译、到处运行”而产生的一种虚拟指令格式，例如iload_0、iconst_1、if_icmpne、dup等
* 位于字节码之上的是`ASM`，这是一种直接操作字节码的框架，应用ASM需要对Java字节码、Class结构比较熟悉
* 位于ASM之上的是`CGLIB、Groovy、BeanShell`，后两种并不是Java体系中的内容而是脚本语言，它们通过ASM框架生成字节码变相执行Java代码，这说明在JVM中执行程序并不一定非要写Java代码----只要你能生成Java字节码，JVM并不关心字节码的来源，当然通过Java代码生成的JVM字节码是通过编译器直接生成的，算是最“正统”的JVM字节码
* 位于CGLIB、Groovy、BeanShell之上的就是Hibernate、Spring AOP这些框架了，这一层大家都比较熟悉
* 最上层的是Applications，即具体应用，一般都是一个Web项目或者本地跑一个程序

# AOP的底层实现-CGLIB动态代理和JDK动态代理

* [AOP的底层实现-CGLIB动态代理和JDK动态代理 - 田有朋的专栏 - CSDN博客 ](http://blog.csdn.net/dreamrealised/article/details/12885739)

cglib动态代理用到了第三方类库，需要在项目中引入两个jar包：cglib.jar和asm.jar

```java
//目标类，cglib不需要定义目标类的统一接口
package cglibproxy;  
  
public class Base {  
    public void add() {  
        System.out.println("add ------------");  
    }  
}  
//实现动态代理类CglibProxy，需要实现MethodInterceptor接口，实现intercept方法。该代理中在add方法前后加入了自定义的切面逻辑，目标类add方法执行语句为proxy.invokeSuper(object, args);
[java] view plain copy
package cglibproxy;  
  
import java.lang.reflect.Method;  
import net.sf.cglib.proxy.MethodInterceptor;  
import net.sf.cglib.proxy.MethodProxy;  
  
public class CglibProxy implements MethodInterceptor {  
  
    public Object intercept(Object object, Method method, Object[] args,  
            MethodProxy proxy) throws Throwable {  
        // 添加切面逻辑（advise），此处是在目标类代码执行之前，即为MethodBeforeAdviceInterceptor。  
        System.out.println("before-------------");  
        // 执行目标类add方法  
        proxy.invokeSuper(object, args);  
        // 添加切面逻辑（advise），此处是在目标类代码执行之后，即为MethodAfterAdviceInterceptor。  
        System.out.println("after--------------");  
        return null;  
    }  
  
}  

//获取增强的目标类的工厂Factory，其中增强的方法类对象是有Enhancer来实现的，代码如下所示：
package cglibproxy;  
  
import net.sf.cglib.proxy.Enhancer;  
  
/** 
 * 工厂类，生成增强过的目标类（已加入切入逻辑） 
 *  
 * @author typ 
 *  
 */  
public class Factory {  
    /** 
     * 获得增强之后的目标类，即添加了切入逻辑advice之后的目标类 
     *  
     * @param proxy 
     * @return 
     */  
    public static Base getInstance(CglibProxy proxy) {  
        Enhancer enhancer = new Enhancer();  
        enhancer.setSuperclass(Base.class);  
        //回调方法的参数为代理类对象CglibProxy，最后增强目标类调用的是代理类对象CglibProxy中的intercept方法  
        enhancer.setCallback(proxy);  
        // 此刻，base不是单纯的目标类，而是增强过的目标类  
        Base base = (Base) enhancer.create();  
        return base;  
    }  
}  

package cglibproxy;  
  
public class Test {  
    public static void main(String[] args) {  
        CglibProxy proxy = new CglibProxy();  
        // base为生成的增强过的目标类  
        Base base = Factory.getInstance(proxy);  
        base.add();  
    }  
}  
```


# CGLIB and Java Serialization

* [How To · cglib/cglib Wiki ](https://github.com/cglib/cglib/wiki/How-To)