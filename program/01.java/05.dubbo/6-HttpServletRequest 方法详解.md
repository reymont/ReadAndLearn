HttpServletRequest 方法详解 - 空谷幽兰 - ITeye博客 http://changbl.iteye.com/blog/1906540

```java
request.setCharacterEncoding("utf-8");//设置request编码方式  
request.getLocalAddr();//获取本地IP，即服务器IP  
request.getLocalName();//获取本地名称，即服务器名称  
request.getLocalPort();//获取本地端口号，即Tomcat端口号  
request.getLocale();//用户的语言环境  
request.getContextPath();//context路径  
request.getMethod();//GET还是POST  
request.getProtocol();//协议，http协议  
request.getQueryString();//查询字符串  
request.getRemoteAddr();//远程IP，即客户端IP  
request.getRemotePort();//远程端口，即客户端端口  
request.getRemoteUser();//远程用户  
request.getRequestedSessionId();//客户端的Session的ID  
request.getRequestURI();//用户请求的URL  
request.getScheme();//协议头，例如http  
request.getServerName();//服务器名称  
request.getServerPort();//服务器端口  
request.getServletPath();//Servlet路径  
```