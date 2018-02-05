在过滤器Filter中获取Response中的内容 - CSDN博客 http://blog.csdn.net/binlixia/article/details/55259581?locationNum=11&fps=1

第一步：创建一个类继承PrintWriter
package demo;

import java.io.PrintWriter;
import java.io.Writer;

public class MyWriter extends PrintWriter{
    private StringBuilder buffer;

    public MyWriter(Writer out) {
        super(out);
        buffer = new StringBuilder();
    }

    @Override
    public void write(char[] buf, int off, int len) {
        // super.write(buf, off, len);
        char[] dest = new char[len];
        System.arraycopy(buf, off, dest, 0, len);
        buffer.append(dest);
        System.out.println("write1");
    }

    @Override
    public void write(char[] buf) {
        super.write(buf);
        System.out.println("write2");
    }

    @Override
    public void write(int c) {
        super.write(c);
        System.out.println("write3");
    }

    @Override
    public void write(String s, int off, int len) {
        super.write(s, off, len);
        buffer.append(s);
        System.out.println("write4");
    }

    @Override
    public void write(String s) {
        super.write(s);
        System.out.println("write5");
    }
    
    public String getContent(){
        return buffer.toString();
    }

}



第二步：创建一个类继承HttpServletResponseWrapper
package demo;

import java.io.IOException;
import java.io.PrintWriter;


import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServletResponseWrapper;

public class MyResponseWrapper extends HttpServletResponseWrapper {
    private MyWriter myWriter;
    
    
    public MyResponseWrapper(HttpServletResponse response) {
        super(response);
    }
    
    @Override
    public PrintWriter getWriter() throws IOException {
        myWriter = new MyWriter(super.getWriter());
        return myWriter;
    }
    
    

    public MyWriter getMyWriter() {
        return myWriter;
    }

    
    
}

第三步，创建一个filter,并在doFilter函数中获取response中的内容
package demo;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Locale;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class TestFilter implements Filter {

    @Override
    public void destroy() {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
            FilterChain chain) throws IOException, ServletException {
        MyResponseWrapper responseWrapper = new MyResponseWrapper((HttpServletResponse) response);
        chain.doFilter(request, responseWrapper);
        MyWriter myWriter = responseWrapper.getMyWriter();
        if (myWriter != null) {
            String content = myWriter.getContent();
            System.out.println("content="+content);
            
        }
    }

    @Override
    public void init(FilterConfig arg0) throws ServletException {
    }

}

第四步：在web.xml中配置过滤器
 <filter>
        <filter-name>filterHttp</filter-name>
        <filter-class>demo.TestFilter</filter-class>
    </filter>
    
    <filter-mapping>
        <filter-name>filterHttp</filter-name>
        <url-pattern>*</url-pattern>
    </filter-mapping>
