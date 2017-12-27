

* [Jenkins源码分析 - CSDN博客 ](http://blog.csdn.net/sogouauto/article/details/46507267)

# Stapler

Stapler 是一个将应用程序对象和 URL 装订在一起的 lib 库，使编写 web 应用程序更加方便。Stapler 的核心思想是自动为应用程序对象绑定 URL，并创建直观的 URL 层次结构。

Jenkins 的类对象和 URL 绑定就是通过 Stapler 来实现的。Hudson 实例作为 root 对象绑定到 URL“/”，其余部分则根据对象的可达性来绑定。

* Stapler
  * 自动为应用程序对象绑定URL，并创建直观的URL层次结构

   URL“/job/foo/”将绑定到 Hudson.getJob(“foo”) 返回的对象

# Jelly

Jelly 是一种基于 Java 技术和 XML 的脚本编制和处理引擎。Jelly 的特点是有许多基于 JSTL (JSP 标准标记库，JSP Standard Tag Library）、Ant、Velocity 及其它众多工具的可执行标记。Jelly 还支持 Jexl（Java 表达式语言，Java Expression Language），Jexl 是 JSTL 表达式语言的扩展版本。
Jenkins的界面绘制就是通过Jelly实现的。Jelly文件位于resources目录下


# Jenkins入口文件

WebAppMain 

类 WebAppMain 实现了 ServletContextListener 接口。该接口的作用主要是监听 ServletContext 对象的生命周期。当 Servlet 容器启动或终止 Web 应用时，会触发 ServletContextEvent 事件，该事件由 ServletContextListener 来处理。此外，ServletContextListener 接口还定义了两个方法，contextInitialized 和 contextDestroyed。通过方法名，我们可以看到这两个方法中一个是启动时候调用 (contextInitialized)，一个是终止的时候调用 (contextDestroyed)。
类中通过 contextInitialized 方法初始化了一个 Jenkins 对象。在 Servlet 容器初始化的时候，Jenkins 对象会交由 WebAppMain 的 initTread 线程创建。