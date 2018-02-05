通过HttpServletResponseWrapper修改response输出流 - 宅山仔 - 博客园 http://www.cnblogs.com/gexiaoshan/p/6429888.html

在项目中遇到一个问题，需要对接口返回的数据进行加密给前端。项目中的controller一般都是返回一个实体form，重写的一个视图解析器继承ModelAndViewResolver，对返回的form转成json格式返回给前端。

视图解析器：


public class JsonModelAndViewResolver implements ModelAndViewResolver,
        InitializingBean, ApplicationContextAware {
    private String defaultContentType = "text/html";
    private Log log = LogFactory.getLog(super.getClass());
    private JsonSerialization jsonSerialization;
    private ApplicationContext applicationContext;
 
    public void afterPropertiesSet() throws Exception {
        if (this.jsonSerialization != null)
            return;
        this.jsonSerialization = JsonSerializationFactory.getInstance(this.applicationContext);
    }
 
    public void setApplicationContext(ApplicationContext paramApplicationContext)
            throws BeansException {
        this.applicationContext = paramApplicationContext;
    }
 
    //执行这个方法
    public ModelAndView resolveModelAndView(Method paramMethod,
            Class paramClass, Object paramObject,
            ExtendedModelMap paramExtendedModelMap,
            NativeWebRequest paramNativeWebRequest) {
        if (Rest.class.isAssignableFrom(paramClass)) {
            try {
                HttpServletResponse localHttpServletResponse = (HttpServletResponse) paramNativeWebRequest.getNativeResponse(HttpServletResponse.class);
                responseJson(paramObject, localHttpServletResponse);
            } catch (IOException localIOException) {
                throw new WebException(localIOException.getMessage(),
                        localIOException);
            }
            return null;
        }
        return UNRESOLVED;
    }
 
    public void responseJson(Object paramObject,
            HttpServletResponse paramHttpServletResponse) throws IOException {
        if (!(StringUtils.hasText(paramHttpServletResponse.getContentType())))
            paramHttpServletResponse.setContentType(this.defaultContentType);
        String str = writeResult(paramObject);
        PrintWriter localPrintWriter = paramHttpServletResponse.getWriter();
        if (this.log.isInfoEnabled())
            this.log.info("Rest result=" + str);
        if ("{}".equals(str)) {
            this.log.info("image stream is not write ");
            return;
        }
        localPrintWriter.write(str);
        localPrintWriter.flush();
    }
 
    protected String writeResult(Object paramObject) {
        String str = null;
        if (paramObject == null) {
            str = "{}";
        } else if ((paramObject instanceof Number)
                || (paramObject instanceof Boolean)) {
            str = "{\"resultCode\":\"" + paramObject.toString() + "\"}";
        } else if ((paramObject instanceof String)) {
            String result = (String) paramObject;
            str = result;
        } else {
            if (paramObject instanceof ModelAndView)
                paramObject = ((ModelAndView) paramObject).getModel();
            str = getJsonSerialization().toJSONString(paramObject);
        }
        return str;
    }
 
    public String getDefaultContentType() {
        return this.defaultContentType;
    }
 
    public void setDefaultContentType(String paramString) {
        this.defaultContentType = paramString;
    }
 
    public JsonSerialization getJsonSerialization() {
        return this.jsonSerialization;
    }
 
    public void setJsonSerialization(JsonSerialization paramJsonSerialization) {
        this.jsonSerialization = paramJsonSerialization;
    }
}
　　本来考虑直接修改视图解析器，对返回json串加密，但发现项目中有些接口直接在controller中直接通过PrintWriter返回了参数，显然有这种方法是拦截不到的。

最后通过HttpServletResponseWrapper截取返回数据流加密重新输出给前端的方式。

代码参照如下：

ResponseWrapper:


package com.paic.egis.smts.toa.web.interceptor;
 
import java.io.CharArrayWriter;
import java.io.IOException;
import java.io.PrintWriter;
 
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServletResponseWrapper;
 
import com.paic.egis.smts.common.util.LoggerUtil;
 
public class ResponseWrapper extends HttpServletResponseWrapper {
    private PrintWriter cachedWriter;
    private CharArrayWriter bufferedWriter;
 
    public ResponseWrapper(HttpServletResponse response) throws IOException {
        super(response);
        bufferedWriter = new CharArrayWriter();
        cachedWriter = new PrintWriter(bufferedWriter);
    }
 
    public PrintWriter getWriter() throws IOException {
        return cachedWriter;
    }
 
    public String getResult() {
        byte[] bytes = bufferedWriter.toString().getBytes();
        try {
            return new String(bytes, "UTF-8");
        } catch (Exception e) {
            LoggerUtil.logError(this.getClass().getName(), "getResult", e);
            return "";
        }
    }
 
}
　　过滤器如下：


package com.paic.egis.smts.toa.web.filter;
 
import java.io.IOException;
import java.io.PrintWriter;
 
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletResponse;
 
import com.alibaba.dubbo.common.utils.StringUtils;
import com.paic.egis.smts.common.util.LoggerUtil;
import com.paic.egis.smts.common.util.PropertiesUtil;
import com.paic.egis.smts.pama.security.Base64Utils;
import com.paic.egis.smts.toa.web.interceptor.ResponseWrapper;
import com.paic.egis.smts.trusteesship.util.RSACoder;
 
public class ResponseWrapperFilter implements Filter {
 
    public void destroy() {
 
    }
 
    public void doFilter(ServletRequest req, ServletResponse resp,
            FilterChain chain) throws IOException, ServletException {
 
        String version = req.getParameter("version");
        if(StringUtils.isEmpty(version)){
             
            chain.doFilter(req, resp);
             
        } else {
             
            HttpServletResponse response = (HttpServletResponse) resp;
            ResponseWrapper mr = new ResponseWrapper(response);
             
            chain.doFilter(req, mr);
             
            PrintWriter out = resp.getWriter(); 
            try {
                //取返回的json串
                String result = mr.getResult(); 
                System.out.println(result);
                //加密
                String encryptStr = encryptRSA(result);
                out.write(encryptStr); 
            } catch (Exception e) {
                LoggerUtil.logError(this.getClass().getName(), "doFilter", e);
            } finally {
                out.flush(); 
                out.close();
            }
        }
    }
 
    @Override
    public void init(FilterConfig filterconfig) throws ServletException {
         
    }
 
    //rsa公钥加密
    public String encryptRSA(String content) throws Exception{
        String publicKeyStr = PropertiesUtil.getProperty("response.publicKey");
        byte[] encryptBytes = RSACoder.encrypt(content.getBytes("utf-8"), publicKeyStr,"public");
        return  Base64Utils.encode(encryptBytes);
    }
}
　　在测试阶段发现，有的接口会出现重复加密的问题。

      过滤器配置如下:


<filter>
        <filter-name>encryptFilter</filter-name>
        <filter-class>com.paic.egis.smts.toa.web.filter.ResponseWrapperFilter</filter-class>
    </filter>
    <filter-mapping>
        <filter-name>encryptFilter</filter-name>
        <url-pattern>*.do</url-pattern>
    </filter-mapping>
    <filter-mapping>
        <filter-name>encryptFilter</filter-name>
        <url-pattern>/do/*</url-pattern>
    </filter-mapping>
    <filter-mapping>
        <filter-name>encryptFilter</filter-name>
        <url-pattern>/doh/*</url-pattern>
    </filter-mapping>
    <filter-mapping>
        <filter-name>encryptFilter</filter-name>
        <url-pattern>*.doh</url-pattern>
    </filter-mapping>
    <filter-mapping>
        <filter-name>encryptFilter</filter-name>
        <url-pattern>/app/*</url-pattern>
    </filter-mapping>
    <filter-mapping>
        <filter-name>encryptFilter</filter-name>
        <url-pattern>/mamc/*</url-pattern>
    </filter-mapping>
　　当接口地址是类似/do/smi/queryRegionInfo.do，过滤器类中会进入两次，对应同一个response，所以在第一次out.write(encryptStr);  时，就更改了response的输出值，在第二次String result = mr.getResult();  时取得就是第一次加密后的值。

      将接口改为/smi/queryRegionInfo.do就不会出现这种情况。