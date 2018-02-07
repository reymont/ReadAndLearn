HttpServletRequestWrapper和HttpServletResponseWrapper详解 - CSDN博客 http://blog.csdn.net/zhongzh86/article/details/45721369

Servlet规范中的filter引入了一个功能强大的拦截模式。Filter能在request到达servlet的服务方法之前拦截HttpServletRequest对象，而在服务方法转移控制后又能拦截HttpServletResponse对象。
`但是HttpServletRequest中的参数是无法改变的，若是手动执行修改request中的参数，则会抛出异常。且无法获取到HttpServletResponse中的输出流中的数据，因为HttpServletResponse中输出流的数据会写入到默认的输出端，你手动无法获取到数据。`

`我们可以利用HttpServletRequestWrapper包装HttpServletRequest，用HttpServletResponseWrapper包装HttpServletResponse，在Wrapper中实现参数的修改或者是response输出流的读取，然后用HttpServletRequestWrapper替换HttpServletRequest，HttpServletResponseWrapper替换HttpServletResponse。这样就实现了参数的修改设置和输出流的读取。`

1.HttpServletRequestWrapper
类图：
有图可见，HttpServletRequestWrapper是HttpServletRequest的一个实现类，所以可以用HttpServletRequestWrapper替换HttpServletRequest。
我们先看ServletRequestWrapper的源码：
public
 class ServletRequestWrapper implements ServletRequest {
    private ServletRequest request;
    public ServletRequestWrapper(ServletRequest request) {
if (request == null) {
   throw new IllegalArgumentException("Request cannot be null");   
}
this.request = request;
    }
public ServletRequest getRequest() {
return this.request;
}
public void setRequest(ServletRequest request) {
   if (request == null) {
throw new IllegalArgumentException("Request cannot be null");
   }
   this.request = request;
}
    public Object getAttribute(String name) {
return this.request.getAttribute(name);
}
   
    public Enumeration getAttributeNames() {
return this.request.getAttributeNames();
}    
    public String getCharacterEncoding() {
return this.request.getCharacterEncoding();
}
    public void setCharacterEncoding(String enc) throws java.io.UnsupportedEncodingException {
this.request.setCharacterEncoding(enc);
}
    public int getContentLength() {
return this.request.getContentLength();
    }
   
    public String getContentType() {
return this.request.getContentType();
    }
    public ServletInputStream getInputStream() throws IOException {
return this.request.getInputStream();
}
     
        public String getParameter(String name) {
return this.request.getParameter(name);
    }
   
    public Map getParameterMap() {
return this.request.getParameterMap();
    }
   
    public Enumeration getParameterNames() {
return this.request.getParameterNames();
    }
    
    public String[] getParameterValues(String name) {
return this.request.getParameterValues(name);
}
    
        public String getProtocol() {
return this.request.getProtocol();
}
    
    public String getScheme() {
return this.request.getScheme();
}
    
    public String getServerName() {
return this.request.getServerName();
}
        public int getServerPort() {
return this.request.getServerPort();
}
    
        public BufferedReader getReader() throws IOException {
return this.request.getReader();
}
    
      ……………… 
}  
可见，ServletRequestWrapper
采取了适配器模式，实际上内部操作的就是构造方法中传递的ServletRequest。
        此处我们创建一个会自动将参数由繁体中文转化为简体中文的HttpServletRequestWrapper：
package
 com.xpspeed.cachept.filter;
import com.xpspeed.common.util.CharsetUtil;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.HashMap;
import java.util.Map;
/**
 * 自动将繁体参数转为简体参数的request
 * Created by Skyline on 2015/5/13.
 */
public class FtToJtRequestWrapper extends HttpServletRequestWrapper {
    /**
     * 处理后的请求参数map
     */
    private Map<String, String[]> newParams;
    /**
     * 原始请求参数map
     */
    private Map<String, String[]> oldParams;
    @SuppressWarnings("unchecked")
    public FtToJtRequestWrapper(HttpServletRequest req) {
        super(req);
        oldParams = req.getParameterMap();
        newParams = getParameterMap();
    }
    @Override
    public String getParameter(String name) {
        String[] vals = getParameterMap().get(name);
        if (vals != null && vals.length > 0)
            return vals[0];
        else
            return null;
    }
    @SuppressWarnings("unchecked")
    @Override
    public Map<String, String[]> getParameterMap() {
        if (newParams == null)
            newParams = createNewParams(oldParams);
        return newParams;
    }
    @Override
    public String[] getParameterValues(String name) {
        return getParameterMap().get(name);
    }
    /**
     * 由旧的参数map生成新参数map
     * @param oldParams
     * @return
     */
    private Map<String, String[]> createNewParams(Map<String, String[]> oldParams) {
        Map<String, String[]> res = new HashMap<String, String[]>();
        if (oldParams == null)
            return res;
        for (String key : oldParams.keySet()) {
            String[] oldValues = oldParams.get(key);
            String[] newVlues = new String[oldValues.length];
            for (int i = 0; i < oldValues.length; i++) {
                String oldValue = oldValues[i];
                //ajax请求中参数会自动encode，此处要先decode
                try {
                    oldValue = URLDecoder.decode(oldValue,"utf-8");
                } catch (UnsupportedEncodingException e) {
                    e.printStackTrace();
                }
                //繁体转为简体
                newVlues[i] = CharsetUtil.ftToJt(oldValue);
            }
            res.put(key, newVlues);
        }
        return res;
    }
}

# 2.HttpServletResponseWrapper
        可以在response输出页面内容之前，进行页面内容的过滤等操作。
比如知名的页面装饰框架sitemesh，就是利用filter过滤器先截获返回给客户端的页面，然后分析html代码并最终装饰页面效果后返回给客户端。
      类图：
由上图可见，HttpServletResponseWrapper是HttpServletResponse的实现类，所以HttpServletResponseWrapper可以替换HttpServletResponse。
同ServletResponseWrapper一样，ServletResponseWrapper也是采去了适配器模式，内部操作的也是构造方法中传递的ServletResponse。
此处我们创建一个可以获取到response中的输出流数据的HttpServletResponseWrapper：
```java
package
 com.xpspeed.cachept.filter;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServletResponseWrapper;
import java.io.*;
/**
 * 定义response包装器ResponseWapper
 * 用以获取response中的数据
 * Created by Skyline on 2015/5/13.
 */
public class ResponseWapper extends HttpServletResponseWrapper {
    private ByteArrayOutputStream buffer = null;
    private ServletOutputStream out = null;
    private PrintWriter writer = null;
    public ResponseWapper(HttpServletResponse resp) throws IOException {
        super(resp);
        /**
         * 替换默认的输出端，作为response输出数据的存储空间（即真正存储数据的流）
         */
        buffer = new ByteArrayOutputStream();
        /**
         * response输出数据时是调用getOutputStream()和getWriter()方法获取输出流，再将数据输出到输出流对应的输出端的。
         * 此处指定getOutputStream()和getWriter()返回的输出流的输出端为buffer，即将数据保存到buffer中。
         */
        out = new WapperedOutputStream(buffer);
        writer = new PrintWriter(new OutputStreamWriter(buffer, this.getCharacterEncoding()));
    }
    //重载父类获取outputstream的方法
    @Override
    public ServletOutputStream getOutputStream() throws IOException {
        return out;
    }
    //重载父类获取writer的方法
    @Override
    public PrintWriter getWriter() throws UnsupportedEncodingException {
        return writer;
    }
    /**
     * 这是将数据输出的最后步骤
     * @throws IOException
     */
    @Override
    public void flushBuffer() throws IOException {
        if (out != null) {
            out.flush();
        }
        if (writer != null) {
            writer.flush();
        }
    }
    @Override
    public void reset() {
        buffer.reset();
    }
    public byte[] getResponseData() throws IOException {
        flushBuffer();//将out、writer中的数据强制输出到WapperedResponse的buffer里面，否则取不到数据
        return buffer.toByteArray();
    }
    //内部类，对ServletOutputStream进行包装，指定输出流的输出端
    private class WapperedOutputStream extends ServletOutputStream {
        private ByteArrayOutputStream bos = null;
        public WapperedOutputStream(ByteArrayOutputStream stream) throws IOException {
            bos = stream;
        }
        //将指定字节写入输出流bos
        @Override
        public void write(int b) throws IOException {
            bos.write(b);
        }
    }
}
```
3.实例
创建一个过滤器，实现request中参数自动由繁体字转为简体字，且相应内容由简体字转为繁体字。
package
 com.xpspeed.cachept.filter;
import com.xpspeed.cachept.common.Constants.ConfDomain;
import com.xpspeed.common.util.CharsetUtil;
import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
/**
 * 语言过滤器
 * 当需要时，将简体转为繁体
 * Created by Skyline on 2015/5/13.
 */
public class LanguangeFilter implements Filter {
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest httpServletRequest = (HttpServletRequest)request;
        if(ConfDomain.isFt_cn()) {
            //自动将繁体参数转为简体参数的request包装器
//            FtToJtRequestWrapper requestWrapper = new FtToJtRequestWrapper(httpServletRequest);
            if(!isAjaxRequest(httpServletRequest)) {
//                chain.doFilter(requestWrapper, response);
                chain.doFilter(request, response);
            } else {
                //可以获取response中数据的response包装器
                ResponseWapper wapper=new ResponseWapper((HttpServletResponse)response);
//                chain.doFilter(requestWrapper, wapper);
                chain.doFilter(request, wapper);
                //获取response中的数据，并处理
                byte[] resp_old = wapper.getResponseData();
                String resp_old_str = new String(resp_old, response.getCharacterEncoding());
                String resp_new_str = CharsetUtil.jtToFt(resp_old_str);
                byte[] resp_new = resp_new_str.getBytes(response.getCharacterEncoding());
                //输出处理后的数据，注意要用response而非wapper
                ServletOutputStream output=response.getOutputStream();
                output.write(resp_new);
                output.flush();
            }
        } else {
            chain.doFilter(request,response);
        }
    }
    private boolean isAjaxRequest(HttpServletRequest request) {
        return "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"));
    }
    @Override
    public void destroy() {
    }
}