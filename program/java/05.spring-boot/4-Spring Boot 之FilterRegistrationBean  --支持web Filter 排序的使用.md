Spring Boot 之FilterRegistrationBean --支持web Filter 排序的使用 - Beaver - CSDN博客 http://blog.csdn.net/doctor_who2004/article/details/56055505


Spring 提供了FilterRegistrationBean类，此类提供setOrder方法，可以为filter设置排序值，
让spring在注册web
 filter之前排序后再依次注册。


  写一个普通的filter：
[java] view plain copy
package com.sdcuike.practice.web2;  
  
import java.io.IOException;  
  
import javax.annotation.Resource;  
import javax.servlet.Filter;  
import javax.servlet.FilterChain;  
import javax.servlet.FilterConfig;  
import javax.servlet.ServletException;  
import javax.servlet.ServletRequest;  
import javax.servlet.ServletResponse;  
  
import org.slf4j.Logger;  
import org.slf4j.LoggerFactory;  
  
import com.sdcuike.practice.config.CommonConfig;  
  
public class FilterDemo3 implements Filter {  
    private final Logger log = LoggerFactory.getLogger(getClass());  
  
    @Resource  
    private CommonConfig commonConfig;  
  
    @Override  
    public void destroy() {  
        log.info("" + getClass() + " destroy");  
  
    }  
  
    @Override  
    public void doFilter(ServletRequest arg0, ServletResponse arg1, FilterChain arg2) throws IOException, ServletException {  
        log.info("" + getClass() + " doFilter " + commonConfig);  
        arg2.doFilter(arg0, arg1);  
  
    }  
  
    @Override  
    public void init(FilterConfig arg0) throws ServletException {  
        log.info("" + getClass() + " init");  
  
    }  
  
}  

配置如下：


[java] view plain copy
package com.sdcuike.practice.web2;  
  
import javax.servlet.Filter;  
  
import org.springframework.boot.web.servlet.FilterRegistrationBean;  
import org.springframework.context.annotation.Bean;  
import org.springframework.context.annotation.Configuration;  
  
import com.sdcuike.spring.extend.web.MvcConfigurerAdapter;  
  
/** 
 * web 组件配置 
 *  
 * @author sdcuike 
 *         <p> 
 *         Created on 2017-02-10 
 *         <p> 
 *         自定义注入，并支持依赖注入，组件排序 
 */  
@Configuration  
public class WebComponent2Config   {  
  
    @Bean  
    public FilterRegistrationBean filterDemo3Registration() {  
        FilterRegistrationBean registration = new FilterRegistrationBean();  
        registration.setFilter(filterDemo3());  
        registration.addUrlPatterns("/*");  
        registration.addInitParameter("paramName", "paramValue");  
        registration.setName("filterDemo3");  
        registration.setOrder(6);  
        return registration;  
    }  
  
    @Bean  
    public FilterRegistrationBean filterDemo4Registration() {  
        FilterRegistrationBean registration = new FilterRegistrationBean();  
        registration.setFilter(filterDemo4());  
        registration.addUrlPatterns("/*");  
        registration.addInitParameter("paramName", "paramValue");  
        registration.setName("filterDemo4");  
        registration.setOrder(7);  
        return registration;  
    }  
  
    @Bean  
    public Filter filterDemo3() {  
        return new FilterDemo3();  
    }  
  
    @Bean  
    public Filter filterDemo4() {  
        return new FilterDemo4();  
    }  
  
}  

利用这种方式，我们可以对filter排序，可自行测试，源码:
https://github.com/sdcuike/spring-boot-practice/tree/master/src/main/java/com/sdcuike/practice/web2







<spring-boot.version>1.5.1.RELEASE</spring-boot.version>