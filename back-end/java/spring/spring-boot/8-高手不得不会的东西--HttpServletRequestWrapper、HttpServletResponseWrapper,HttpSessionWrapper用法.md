(精)高手不得不会的东西--HttpServletRequestWrapper、HttpServletResponseWrapper,HttpSessionWrapper用法 - CSDN博客 http://blog.csdn.net/it_man/article/details/7556903

背景：项目使用的SOA架构，使用Oracle10G SOA SUITE，在该套件中增加了一个过滤器用于解析设置的访问策略。在其中遇到了一个问题，Oracle10g无法将IP与实例编号进行绑定，于是乎从过滤器入手，尝试了HttpServletRequestWrapper、HttpServletResponseWrapper拦截设置参数的方法。得到的结果request可以对请求参数进行修改，但是这样可能会导致Oracle10g SOA Suite的正常运行，想从response中获得返回的内容，但是得到的结果是null，到目前为止该问题仍旧没有得到解决，有好办法的欢迎联系本人，谢谢。 

1）建立一个响应包装器。扩展javax.servlet.http.HttpServletResponseWrapper。
2）提供一个缓存输出的PrintWriter。重载getWriter方法，返回一个保存发送给它的所有东西的PrintWriter，并把结果存进一个可以稍后访问的字段中。
3）传递该包装器给doFilter。此调用是合法的，因为HttpServletResponseWrapper实现HttpServletResponse。
4）提取和修改输出。在调用FilterChain的doFilter方法后，原资源的输出只要利用步骤2中提供的机制就可以得到。只要对你的应用适合，就可以修改或替换它。
5）发送修改过的输出到客户机。因为原资源不再发送输出到客户机（这些输出已经存放到你的响应包装器中了），所以必须发送这些输出。这样，你的过滤器需要从原响应对象中获得PrintWriter或OutputStream，并传递修改过的输出到该流中。 (2).GZipFilter类 (3).GZipUtil类 (4).在web.xml中配置 GZipFilter

下附HttpServletRequestWrapper、HttpServletResponseWrapper用法 
[java] view plain copy
class FilteredRequest extends HttpServletRequestWrapper  
    {  
  
        public FilteredRequest(ServletRequest request)  
        {  
            super((HttpServletRequest) request);  
        }  
  
        public String getParameter(String paramName)  
        {  
            String value = super.getParameter(paramName);  
            if ("myParameter".equals(paramName))  
            {  
                // 更改请求参数的值  
                value += "|127.0.0.1";  
            }  
            return value;  
        }  
  
        public String[] getParameterValues(String paramName)  
        {  
            String values[] = super.getParameterValues(paramName);  
            return values;  
        }  
    }  

[java] view plain copy
import java.io.ByteArrayOutputStream;  
import java.io.IOException;  
import java.io.PrintWriter;  
import java.io.UnsupportedEncodingException;  
  
import javax.servlet.ServletResponse;  
import javax.servlet.http.HttpServletResponse;  
import javax.servlet.http.HttpServletResponseWrapper;  
  
public class WrapperResponse extends HttpServletResponseWrapper  
{  
    private MyPrintWriter tmpWriter;  
  
    private ByteArrayOutputStream output;  
  
    public WrapperResponse(ServletResponse httpServletResponse)  
    {  
        super((HttpServletResponse)httpServletResponse);  
        output = new ByteArrayOutputStream();  
        tmpWriter = new MyPrintWriter(output);  
    }  
  
    public void finalize() throws Throwable  
    {  
        super.finalize();  
        output.close();  
        tmpWriter.close();  
    }  
  
    public String getContent()  
    {  
        try  
        {  
            tmpWriter.flush(); //刷新该流的缓冲，详看java.io.Writer.flush()     
            String s = tmpWriter.getByteArrayOutputStream().toString("UTF-8");  
            //此处可根据需要进行对输出流以及Writer的重置操作     
            //比如tmpWriter.getByteArrayOutputStream().reset()     
            return s;  
        } catch (UnsupportedEncodingException e)  
        {  
            return "UnsupportedEncoding";  
        }  
    }  
  
    //覆盖getWriter()方法，使用我们自己定义的Writer     
    public PrintWriter getWriter() throws IOException  
    {  
        return tmpWriter;  
    }  
  
    public void close() throws IOException  
    {  
        tmpWriter.close();  
    }  
  
    //自定义PrintWriter，为的是把response流写到自己指定的输入流当中     
    //而非默认的ServletOutputStream     
    private static class MyPrintWriter extends PrintWriter  
    {  
        ByteArrayOutputStream myOutput; //此即为存放response输入流的对象     
  
        public MyPrintWriter(ByteArrayOutputStream output)  
        {  
            super(output);  
            myOutput = output;  
        }  
  
        public ByteArrayOutputStream getByteArrayOutputStream()  
        {  
            return myOutput;  
        }  
    }  
}  

调用处 
[java] view plain copy
FilteredRequest filterRequest = new FilteredRequest(request);  
WrapperResponse filterResponse = new WrapperResponse(response);  
filterChain.doFilter(filterRequest, filterResponse);  
String content = filterResponse.getContent();  


或者自己实现HttpServletResponse和HttpServletRequest接口，但这是麻烦的。
如果要管理session，或session实现共享就用HttpSessionWrapper
学习oscache页面缓存得到的启示 :http://blog.sina.com.cn/s/blog_866b16a60100z2bi.html      
首先说一个无关的，但高手必须了解的。 servlet的Response的输出流在URL中保存Session ID的方法是哪一个？
A. the encodeURL method of the HttpServletRequest interface
B. the encodeURL method of the HttpServletResponse interface
C. the rewriteURL method of the HttpServletRequest interface
D. the rewriteURL method of the HttpServletResponse interface

答案选B.

学习完黎老师讲的oscache页面缓存后，它的实现原理大致如下（原理和oscache一样，但oscache做的更好，我这里只是用伪代码简单描述）：
Cachefilter implements  filter{
dofilter(request, response, chain){
String urlpath = req,...;
if(Oscache.contains(urlpath)){
String content = oscache.getKey(urlpath);
response.write(content);
}else{
CacheHettpServletResponseWrapper wrapper = new CacheHettpServletResponseWrapper (respone);
chain.doFilter(reques, wrapper);
String content = wrapper.getContent();//获取服务端往客户端输出的html代码
Oscache.put(urlpath, content);
response.write(content);
}
}
}

public CacheHettpServletResponseWrapper extends  HettpServletResponseWrapper{
private String content;
public CacheHettpServletResponseWrapper(HttpServletResponse response){
.......
}
//重写HettpServletResponseWrapper的一个方法，这里可能不是write方法，忘记叫什么了，自己去看。后来看了下是
/覆盖getWriter()方法，使用我们自己定义的Writer     
    public PrintWriter getWriter() throws IOException  

HettpServletResponseWrapper吧
public void getWriter(String Content){
this.Content = content;
}
public String getContent(){
return this.content;
}
}

:利用继承HettpServletResponseWrapper可以控制往客户端的输出，或在往客户端输出前取得要输出的内容。
同样希望大家会HttpServletRequestWrapper。 或者自己实现HttpServletResponse和HttpServletRequest接口，但这是麻烦的。
1）建立一个响应包装器。扩展javax.servlet.http.HttpServletResponseWrapper。
2）提供一个缓存输出的PrintWriter。重载getWriter方法，返回一个保存发送给它的所有东西的PrintWriter，并把结果存进一个可以稍后访问的字段中。
3）传递该包装器给doFilter。此调用是合法的，因为HttpServletResponseWrapper实现HttpServletResponse。
4）提取和修改输出。在调用FilterChain的doFilter方法后，原资源的输出只要利用步骤2中提供的机制就可以得到。只要对你的应用适合，就可以修改或替换它。
5）发送修改过的输出到客户机。因为原资源不再发送输出到客户机（这些输出已经存放到你的响应包装器中了），所以必须发送这些输出。这样，你的过滤器需要从原响应对象中获得PrintWriter或OutputStream，并传递修改过的输出到该流中。 (2).GZipFilter类 (3).GZipUtil类 (4).在web.xml中配置 GZipFilter
--------------------------------------------------
页面缓存
---》html--->client
二级缓存
--》action-->service层-->Jsp-->html-->client

：从上看出为什么页面缓存要比二级缓存要快。因为二级缓存处理流程更多，并且还要解析jsp及标签等转化成html，这是耗时的。