理解Servlet过滤器(javax.servlet.Filter) - CSDN博客 http://blog.csdn.net/microtong/article/details/5007170

理解Servlet过滤器(javax.servlet.Filter)
                 佟强  2009年12月14日
过滤器（Filter）的概念
过滤器位于客户端和web应用程序之间，用于检查和修改两者之间流过的请求和响应。
在请求到达Servlet/JSP之前，过滤器截获请求。
在响应送给客户端之前，过滤器截获响应。
多个过滤器形成一个过滤器链，过滤器链中不同过滤器的先后顺序由部署文件web.xml中过滤器映射<filter-mapping>的顺序决定。
最先截获客户端请求的过滤器将最后截获Servlet/JSP的响应信息。
过滤器的链式结构
    可以为一个Web应用组件部署多个过滤器，这些过滤器组成一个过滤器链，每个过滤器只执行某个特定的操作或者检查。这样请求在到达被访问的目标之前，需要经过这个过滤器链。
过滤器链式结构
实现过滤器
在Web应用中使用过滤器需要实现javax.servlet.Filter接口，实现Filter接口中所定义的方法，并在web.xml中部署过滤器。
public class MyFilter implements Filter {

    public void init(FilterConfig fc) {
        //过滤器初始化代码
    }

    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) {
        //在这里可以对客户端请求进行检查
        //沿过滤器链将请求传递到下一个过滤器。
        chain.doFilter(request, response);
        //在这里可以对响应进行处理

    }

    public void destroy( ) {
        //过滤器被销毁时执行的代码
    }

}
 
Filter接口
public void init(FilterConfig config)
web容器调用本方法，说明过滤器正被加载到web容器中去。容器只有在实例化过滤器时才会调用该方法一次。容器为这个方法传递一个FilterConfig对象，其中包含与Filter相关的配置信息。

### doFilter

public void doFilter(ServletRequest request, 
            ServletResponse response, FilterChain chain)
每当请求和响应经过过滤器链时，容器都要调用一次该方法。需要注意的是过滤器的一个实例可以同时服务于多个请求，特别需要注意线程同步问题，尽量不用或少用实例变量。 

在过滤器的doFilter()方法实现中，任何出现在FilterChain的doFilter方法之前地方，request是可用的；
在doFilter()方法之后response是可用的。

### destroy

public void destroy()
容器调用destroy()方法指出将从服务中删除该过滤器。

如果过滤器使用了其他资源，需要在这个方法中释放这些资源。
 
部署过滤器
在Web应用的WEB-INF目录下，找到web.xml文件，在其中添加如下代码来声明Filter。
<filter>
    <filter-name>MyFilter</filter-name>
    <filter-class>
        cn.edu.uibe.webdev.MyFilter
    </filter-class>
    <init-param>
        <param-name>developer</param-name>
        <param-value>TongQiang</param-value>
    </init-param>
</filter>
针对一个Servlet做过滤
<filter-mapping>
    <filter-name>MyFilter</filter-name>
    <servlet-name>MyServlet</servlet-name>
</filter-mapping>
针对URL Pattern做过滤
<filter-mapping>
    <filter-name>MyFilter</filter-name>
    <url-pattern>/book/*</url-pattern>
</filter-mapping>
<filter-mapping>标记是有先后顺序的，它的声明顺序说明容器是如何形成过滤器链的。过滤器应当设计为在部署时很容易配置的形式。通过认真计划和使用初始化参数，可以得到复用性很高的过滤器。 过滤器逻辑与Servlet逻辑不同，它不依赖于任何用户状态信息，因为一个过滤器实例可能同时处理多个完全不同的请求。
 
    OakCMS内容管理系统 http://www.oakcms.cn