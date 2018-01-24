

Spring Cloud 随笔：记录在使用 OAuth2 遇到的巨坑 | 伤神的博客 http://www.shangyang.me/2017/06/01/spring-cloud-oauth2-zuul-potholes/

```
POST /uaa/oauth/token/ HTTP/1.1
authorization: Basic ZGVtbzpkZW1v
user-agent: curl/7.51.0
accept: */*
content-type: application/x-www-form-urlencoded
x-forwarded-host: localhost
x-forwarded-proto: http
x-forwarded-prefix: /uaa
x-forwarded-port: 8000
x-forwarded-for: 0:0:0:0:0:0:0:1
Accept-Encoding: gzip
Content-Length: 51
Host: localhost:9999
Connection: Keep-Alive
grant_type=password&username=user&password=password

```


前言
根据当前的设计，打算将 Spring Boot 的 Authenticate (OAuth2) Server 配置到 ZUUL 中，通过 ZUUL 实现认证的负载均衡；看似顺理成章的东西，结果在实践过程中，踩到不少坑，也花费不少时间来整理，所以，打算专门写一篇博文来整理自己遇到的坑，以防以后踩到同样的坑，又耗费大量的时间和精力去模式；
本文为作者的原创作品，转载需注明出处；
环境
Authenticate Server: 9999
ZUUL Server: 8000
坑
Basic Authenticate 信息丢失
丢失情况一
当前的环境是，不采用 Eureka 服务器，直接通过地址转发的方式，将认证链接从 ZUUL 导向 Authenticate Server；
Client -> ZUUL -> Authentication Server 的过程中，在 ZUUL -> Authentication Server 的时候丢失；
分析

OAuth2 对 Client 的身份信息认证是通过 HTTP Basic 的方式进行的，也就是在 Header 中生成一串由 BASE64 编码的 client_id 和 client_secret 的字符串，类似如下，
1
2
3
4
5
6
7
8
POST /uaa/oauth/token HTTP/1.1
Host: localhost:9999
Authorization: Basic ZGVtbzpkZW1v
User-Agent: curl/7.51.0
Accept: */*
Content-Length: 51
Content-Type: application/x-www-form-urlencoded
grant_type=password&username=user&password=passwordH
这一串关键的 Authorization: Basic ZGVtbzpkZW1v 信息，在通过 ZUUL 转发给 Authenticate Server 的过程中，会丢失；结果导致在通过 ZUUL 转发认证请求后得到不能认证的错误返回 Response；如下所述；
1
2
$ curl -XPOST -u demo:demo localhost:8000/uaa/ -d grant_type=password -d username=user -d password=password
{"timestamp":1496055288220,"status":401,"error":"Unauthorized","message":"Full authentication is required to access this resource","path":"/uaa/oauth/token/"}
从抓包的结果中可以明显看到 Base Authorization 信息丢失；这直接导致 OAuth 认证失败，因为 Client 认证信息丢失；
1
2
3
4
5
6
7
8
9
POST /uaa/oauth/token/ HTTP/1.1
user-agent: curl/7.51.0
accept: */*
content-type: application/x-www-form-urlencoded
Content-Length: 51
Host: localhost:9999
Connection: Keep-Alive
grant_type=password&username=user&password=password
解决办法

Google 上找到几篇文章，
第一种说法，给 server 节点增加属性 use-forward-headers: true，验证失败，参考 https://docs.stormpath.com/java/spring-cloud-zuul/quickstart.html
1
2
3
server:
  port: 8000
  use-forward-headers: true
第二种说法，包括官文，说是可以通过设置 ZUUL sensitiveHeaders 属性的三个值，可以解决，如下配置，
1
zuul.sensitiveHeaders: Cookie,Set-Cookie,Authorization
验证还是失败；在转发的过程中，还是会丢弃 Base Authorization 的值；这个让我很奇怪了，明明是为 Header 设置了 Authorization 信息，为什么不转发呢？
结果，在 https://github.com/Netflix/zuul/issues/218 找到了解决办法，原来在配置 sensitiveHeaders 的时候，不能添加 Authorization，需要配置成如下的方式，
1
zuul.sensitiveHeaders: Cookie,Set-Cookie
这样，Base Authorization 转发了，
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
POST /uaa/oauth/token/ HTTP/1.1
authorization: Basic ZGVtbzpkZW1v
user-agent: curl/7.51.0
accept: */*
content-type: application/x-www-form-urlencoded
x-forwarded-host: localhost
x-forwarded-proto: http
x-forwarded-prefix: /uaa
x-forwarded-port: 8000
x-forwarded-for: 0:0:0:0:0:0:0:1
Accept-Encoding: gzip
Content-Length: 51
Host: localhost:9999
Connection: Keep-Alive
grant_type=password&username=user&password=password
总结下
为什么 sensitiveHeaders 中将 Authentication 移除，Base Authorization 的信息就可以发送了，参考官网的说明 https://github.com/spring-cloud/spring-cloud-netflix/blob/master/docs/src/main/asciidoc/spring-cloud-netflix.adoc#cookies-and-sensitive-headers 里面明确说明的是，sensitiveHeaders 是指 http header 中的敏感信息，既然是敏感信息，默认情况下，ZUUL 是不转发的；而如果不显示配置 sensitiveHeaders，那么默认情况下，配置的就是 zuul.sensitiveHeaders: Cookie,Set-Cookie,Authorization， 也就是说，默认情况下，cookie 和相关的 Authorization 都不会进行转发，这就导致了我之前遇到的问题；所以呢，我们必须显示的进行配置，将 Authorization 从 sensitiveHeaders 配置中去掉，保证 Authorization 是可以被转发的；当然，如果将来需要通过 Spring Session 统一所有服务器的 Http Session，那么 sessionid 是必须通过 cookie 进行传输的，所以，那个时候，ZUUL 还必须转发 cookie 的相关信息，到时候，Cookie 和 Set-Cookie 同样需要从 sensitiveHeaders 中移除；
丢失情况二
这种情况是，当客户端 Client 拿到了 access_token，在执行如下流程
Client -> ZUUL -> Order Service (a resource server) -> Stock Service (a resource server ) 的过程中丢失；
当前的环境是，采用 Eureka 服务器，并且使用 Feign 作为中间件让集群内部的微服务实现远程调用，通讯；
分析

具体情况是，Client 通过 access token 经过 ZUUL 访问到 Order Service 的被保护资源，但是 Order Service 需要通过 Feign 去调用另一个微服务 Stock Service 去获取 Stock 中的 product 信息，这是在这一步 Order Service -> Stock Service 通过 Feign 的调用过程中，access token 丢失了；所以导致，Stock Service 中的资源无法被获取到；错误信息如下，
此部分信息是从 Order Service 控制台截取的
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
ERROR 37525 --- [nio-2000-exec-1] o.a.c.c.C.[.[.[/].[dispatcherServlet]    : Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed; nested exception is com.netflix.hystrix.exception.HystrixRuntimeException: getProduct failed and no fallback available.] with root cause
feign.FeignException: status 401 reading IRemoteStock#getProduct(long); content:
{"error":"unauthorized","error_description":"Full authentication is required to access this resource"}
  at feign.FeignException.errorStatus(FeignException.java:62) ~[feign-core-8.16.2.jar:8.16.2]
  at feign.codec.ErrorDecoder$Default.decode(ErrorDecoder.java:91) ~[feign-core-8.16.2.jar:8.16.2]
  at feign.SynchronousMethodHandler.executeAndDecode(SynchronousMethodHandler.java:134) ~[feign-core-8.16.2.jar:8.16.2]
  at feign.SynchronousMethodHandler.invoke(SynchronousMethodHandler.java:76) ~[feign-core-8.16.2.jar:8.16.2]
  at feign.hystrix.HystrixInvocationHandler$1.run(HystrixInvocationHandler.java:97) ~[feign-hystrix-8.16.2.jar:8.16.2]
  at com.netflix.hystrix.HystrixCommand$1.call(HystrixCommand.java:293) ~[hystrix-core-1.5.2.jar:1.5.2]
  at com.netflix.hystrix.HystrixCommand$1.call(HystrixCommand.java:288) ~[hystrix-core-1.5.2.jar:1.5.2]
  at rx.internal.operators.OnSubscribeLift.call(OnSubscribeLift.java:50) ~[rxjava-1.1.5.jar:1.1.5]
  at rx.internal.operators.OnSubscribeLift.call(OnSubscribeLift.java:30) ~[rxjava-1.1.5.jar:1.1.5]
  at rx.internal.operators.OnSubscribeLift.call(OnSubscribeLift.java:50) ~[rxjava-1.1.5.jar:1.1.5]
  at rx.internal.operators.OnSubscribeLift.call(OnSubscribeLift.java:30) ~[rxjava-1.1.5.jar:1.1.5]
  at rx.internal.operators.OnSubscribeLift.call(OnSubscribeLift.java:50) ~[rxjava-1.1.5.jar:1.1.5]
  at rx.internal.operators.OnSubscribeLift.call(OnSubscribeLift.java:30) ~[rxjava-1.1.5.jar:1.1.5]
此部分信息是从 Order Service 控制台中截取的，可以明显的看到，Order-Service 所有的相关认证信息在 Stock Service 上全部丢失的了…
1
2
3
4
5
6
7
8
9
10
11
12
13
o.s.s.w.u.matcher.AntPathRequestMatcher  : Request 'GET /stock/product/1000' doesn't match 'POST /stock/**
o.s.s.w.u.matcher.AntPathRequestMatcher  : Request 'GET /stock/product/1000' doesn't match 'PUT /stock/**
o.s.s.w.u.matcher.AntPathRequestMatcher  : Checking match of request : '/stock/product/1000'; against '/stock/**'
o.s.s.w.a.i.FilterSecurityInterceptor    : Secure object: FilterInvocation: URL: /stock/product/1000; Attributes: [#oauth2.throwOnError(#oauth2.hasScope('read'))]
o.s.s.w.a.i.FilterSecurityInterceptor    : Previously Authenticated: org.springframework.security.authentication.AnonymousAuthenticationToken@9055286a: Principal: anonymousUser; Credentials: [PROTECTED]; Authenticated: true; Details: org.springframework.security.web.authentication.WebAuthenticationDetails@59b2: RemoteIpAddress: 10.254.64.157; SessionId: null; Granted Authorities: ROLE_ANONYMOUS
2017-05-30 12:25:18.541 DEBUG 38086 --- [nio-3000-exec-4] o.s.s.w.a.ExceptionTranslationFilter     : Access is denied (user is anonymous); redirecting to authentication entry point
org.springframework.security.access.AccessDeniedException: Insufficient scope for this resource
  at org.springframework.security.oauth2.provider.expression.OAuth2SecurityExpressionMethods.throwOnError(OAuth2SecurityExpressionMethods.java:72) ~[spring-security-oauth2-2.0.9.RELEASE.jar:na]
  at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method) ~[na:1.8.0_121]
  at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62) ~[na:1.8.0_121]
  at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43) ~[na:1.8.0_121]
  at java.lang.reflect.Method.invoke(Method.java:498) ~[na:1.8.0_121]
原因

进一步分析得知，是因为 Feign 默认下，不转发 Authorization 的相关的信息，所以才导致了上述的问题；而且 Google 了大量资料，也没看到 Feign 是否提供了这样的开关；
一系列关于此问题的讨论，Feign 转发不包含 Authorization 信息所引发的血案，
先来看看 Github 上对它的讨论 (直接把它当做一个 Bug)
Add support for Feign on OAuth2 protected resources #56
Custom Feign RequestInterceptor for Spring OAuth2 #75
这篇文章提出了，可以通过扩展 Feign 的 RequestInterceptor 接口来自己添加 Authorization 的信息；但是仅仅是思路；
Ability to configure feign.RequestInterceptor specific to a given feign client #288
这篇文章提到，我们应该在 FeignClientFactoryBean 中为所有的 Feign clients 添加 Authorization，但也仅仅是想法；
是的，网上的确给出了解决方法，看似好简单，写一个 Feign 的 RequestInterceptor 接口实现就搞定，然后我 google 了一些看似能够能解决的代码，后来我发现我错了，(水真的很深)
下面这段代码出自 https://gist.githubusercontent.com/joaoevangelista/dc90bcea15da5f554c7c/raw/c4d5801d536410af7d00f464ce24eb9967144ab0/RibbonRestBalanced.java
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
@Bean
   @ConditionalOnMissingBean(RequestInterceptor.class)
   @ConditionalOnBean(OAuth2ClientContext.class)
   @ConditionalOnClass({RequestInterceptor.class, Feign.class})
   feign.RequestInterceptor requestInterceptor(OAuth2ClientContext context) {
       if (context == null) return null;
       return new OAuth2FeignRequestInterceptor(context);
   }
   public class OAuth2FeignRequestInterceptor implements RequestInterceptor {
       private final OAuth2ClientContext oAuth2ClientContext;
       private final String tokenTypeName;
       private final String headerName;
       private final Logger logger = LoggerFactory.getLogger(OAuth2FeignRequestInterceptor.class);
       public OAuth2FeignRequestInterceptor(OAuth2ClientContext oAuth2ClientContext) {
           this(oAuth2ClientContext, "Bearer", "Authorization");
       }
       public OAuth2FeignRequestInterceptor(OAuth2ClientContext oAuth2ClientContext, String tokenTypeName, String headerName) {
           this.oAuth2ClientContext = oAuth2ClientContext;
           this.tokenTypeName = tokenTypeName;
           this.headerName = headerName;
       }
       @Override
       public void apply(RequestTemplate template) {
           if (oAuth2ClientContext.getAccessTokenRequest().getExistingToken() == null) {
               logger.warn("Cannot obtain existing token for request, if it is a non secured request, ignore.");
           } else {
               logger.debug("Constructing Header {} for Token {}", headerName, tokenTypeName);
               template.header(headerName, String.format("%s %s", tokenTypeName, oAuth2ClientContext.getAccessTokenRequest().getExistingToken().toString()));
           }
       }
   }
这段代码出自 https://github.com/spring-cloud/spring-cloud-netflix/issues/293
1
2
3
4
5
6
7
8
9
10
11
12
13
public class FeignInterceptor implements RequestInterceptor {
    @Autowired
    private OAuth2ClientContext context;
    @Override
    public void apply(RequestTemplate template) {
        if(context.getAccessToken() != null 
                && context.getAccessToken().getValue() != null
                && OAuth2AccessToken.BEARER_TYPE.equalsIgnoreCase(context.getAccessToken().getTokenType()) ){
            template.header("Authorization", String.format("%s %s", OAuth2AccessToken.BEARER_TYPE, context.getAccessToken().getValue()));
        }
    }
}
上面的种种代码我都试过了，但是，终究，还是遇到了和这位仁兄一样的错误，https://github.com/jmnarloch/feign-oauth2-spring-cloud-starter/issues/1 错误信息如下
1
No thread-bound request found: Are you referring to request attributes outside of an actual web request, or processing a request outside of the originally receiving thread? If you are actually operating within a web request and still receive this message, your code is probably running outside of DispatcherServlet/DispatcherPortlet: In this case, use RequestContextListener or RequestContextFilter to expose the current request.
那上面这个错误又是一个什么意思呢？
看下这篇文章，https://stackoverflow.com/questions/35265585/trying-to-use-oauth2-token-with-feign-client-and-hystrix 里面的 SUGENAN 说到了问题的点，因为 Hystrix 是在另外一个线程中执行的，与 Request 不在同一个线程中，所以，上述直接在当前的线程中去获取 OAuth2ClientContext 或者是 SecurityContext 是办不到的，也因此，会出现这个错误；
在来看看这篇文章，Make Spring Security Context Available Inside A Hystrix Command，里面详细的描述了 Hystrix 与 Spring Security Context 的问题，原因，以及如何解决；为了避免链接不可用，将这篇文章打印成了 PDF；Ok，这篇文章已经解释到了 Hystrix 为什么不兼容 Spring Security Context 的深层次的原因，根本原因是，Hystrix 是在自身的 Thread Pool 中执行的，所以，与 Request Context 本身就不在同一个线程中，所以，作者做了大量的工作，将 Request Context 中的 Attributes 赋值到 Hystrix 的线程中，这样才使得 Hystrix 能够获取到 Request Context 中的东西；该作者写了大量的接口，回调，处理生命周期的调用，但是，问题是，我们是需要在 Spring Boot 环境中生效，所以，除了问题的原因分析意外，其方式和方法都不能直接拿来使用；当然，如果读者有时间和耐心深入的去读透 Hystrix 和 Spring Security 的源码，那么解决这个问题自然不在话下；无奈，因为博主时间有限，需要交付一个可用的 Spring Cloud 框架，所以，需要一个快速的，能够解决问题的方法；
后来，读到这篇文章，https://stackoverflow.com/questions/34719809/unreachable-security-context-using-feign-requestinterceptor 里面提到了使用 HystrixRequestVariableDefault，通过该类的注释可以知道，这个是 Hystrix 为自身执行的线程提供的一个类似于 ThreadLocal 的类，但是它与 ThreadLocal 的不同之处在于，该 Locals 的作用范围提升到了这个 User Request Scope 级别，通过其注解可知，它是通过父类线程与子类线程共享的方式来共用该 Locals 中的信息；所以，达到了 User Request 线程与 Hystrix 线程共用 attributes 的目的；由此，可以猜测，Hystrix 的线程是由当前 Request 线程所创建的子线程；不过，使用的过程中，需要注意的是，HystrixRequestVariable 必须在每一个请求开始的时候进行初始化；也就是说，我们可以将 Request Context 中的有用信息存储到HystrixRequestVariableDefault中达到与 Hystrix Context 共享信息；也就实现了 Request Context 中的属性与 Hystrix Context 之间共享的目的；
好了，解决思路有了，就差源码了，可惜，作者找遍了能找到的信息，还没有一个最终可直接拿来使用的代码，所以，也只能在不了解源码的基础上，硬着头皮上了，自己撸代码吧~ 请看下一小节；
解决办法

其实经过上一小节的原因分析，解决思路已经很清晰了，
首先，写一个 Request Filter，将 Spring Security Context 中关键信息传递给 Hystrix Context
其次，写一个 Feign.RequestInterceptor 的接口实现类，为 ReqestTemplate 添加 Authorization 属性值；
下面贴出我花了整整一天才搞定的完整的代码，
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
71
72
73
74
75
76
77
78
79
80
81
82
83
84
85
86
87
88
89
90
91
92
93
94
95
96
97
98
99
100
101
102
103
104
105
106
107
108
109
110
111
112
113
114
115
116
117
118
119
120
121
122
123
124
125
126
127
128
129
130
131
132
133
134
135
136
package org.shangyang.springcloud;
import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.embedded.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.provider.authentication.OAuth2AuthenticationDetails;
import com.netflix.hystrix.strategy.concurrency.HystrixRequestContext;
import com.netflix.hystrix.strategy.concurrency.HystrixRequestVariableDefault;
import feign.RequestInterceptor;
import feign.RequestTemplate;
/**
 * 
 * 现在遇到的问题是，从 Order Service 向 Stock Service 转发的时候，Credentials 丢失，原因是 Hystrix 不转发；所以，需要补发，该类的逻辑就是取转发相关遗漏的 Credentials；在 OAuth 认证中是关键；
 * 
 * Godden Code...
 * 
 * @author shangyang
 *
 */
@Configuration
public class HystrixCredentialsContext {
  private static final Logger logger = LoggerFactory.getLogger(HystrixCredentialsContext.class);
    private static final HystrixRequestVariableDefault<Authentication> authentication = new HystrixRequestVariableDefault<>();
    public static HystrixRequestVariableDefault<Authentication> getInstance() {
        return authentication;
    }   
  
  /**
   * 下面这段代码是关键，实现 @See feign.RequestInterceptor，
   * 1. 添加认证所需的 oauth token；
   * 2. 添加认证所需的 user;
   * 
   * 目前仅实现了 oauth toke，将来看情况是否实现 user;
   * 
   * 特别要注意一点，因为 HystrixRequestContext 和 RequestContext 不在同一个线程中，所以，不能直接在 RequestInterceptor 的实现方法中调用 RequestContext 中的资源，因为 HystrixRequestContext 是在自己
   * 的 ThreadPool 中执行的；所以，这里搞得比较的麻烦... 不能在 {@link RequestInterceptor#apply(RequestTemplate)} 中直接使用 RequestContext / SecurityContextHolder，否则取到的资源全部是 null；
   * 
   * @return
   */
  @Bean
  public RequestInterceptor requestTokenBearerInterceptor() {
    
          return new RequestInterceptor() {
            
              @Override
              public void apply(RequestTemplate requestTemplate) {
                
                Authentication auth = HystrixCredentialsContext.getInstance().get();
                
                if( auth != null ){
                  
                  logger.debug("try to forward the authentication by Hystrix, the Authentication Object: "+ auth );
                  
                  // 记得，因为 Feign Interceptor 是通过自有的 ThreadPool 中的线程执行的，与当前的 Request 线程不是同一个线程，所以这里不能使用 debug 模式进行调试；
                    requestTemplate.header("Authorization", "bearer " + ( (OAuth2AuthenticationDetails) auth.getDetails()).getTokenValue() );
                  
                }else{
                  
                  logger.debug("attention, there is no Authentication Object needs to forward");
                  
                }
                  
          }
      };
  }
  
    @Bean
    public FilterRegistrationBean hystrixFilter() {
      
        FilterRegistrationBean r = new FilterRegistrationBean();
        
        r.setFilter(new Filter(){
      @Override
      public void init(FilterConfig filterConfig) throws ServletException {
      }
      @Override
      public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
          throws IOException, ServletException {
        // as the comments described by HystrixRequestContext, for using HystrixRequestVariable should first initialize the context at the beginning of each request
        // so made it here... 
        HystrixRequestContext.initializeContext();
        
        SecurityContext securityContext = SecurityContextHolder.getContext();
        
        if( securityContext != null ){
          Authentication auth = (Authentication) securityContext.getAuthentication();     
            
            HystrixCredentialsContext.getInstance().set(auth);
            logger.debug("try to register the authentication into Hystrix Context, the Authentication Object: "+ auth );
            
        }
          
          chain.doFilter(request, response);
        
      }
      @Override
      public void destroy() {
        
      }
          
        });
        
        // In case you want the filter to apply to specific URL patterns only
        r.addUrlPatterns("/*");
        
        return r;
    } 
  
}
幽灵般的 401: Bad credentials
分析
当前的环境是，不采用 Eureka 服务器，直接通过地址转发的方式，将认证链接从 ZUUL 导向 Authenticate Server；
现象分析

原本以为，解决了 BASE Authentication 的问题以后，后面就可以迎刃而解了，万万没有想到的是，遇到了下面这个错误返回
1
{"timestamp":1496061029672,"status":401,"error":"Unauthorized","message":"Bad credentials","path":"/uaa/oauth/token/"}
ZUUL 的配置如下，转发规则很简单，凡是 /uaa/** 都会被重定向到 http://localhost:9999/uaa/oauth/token
1
2
3
4
5
6
7
zuul:
  ignoredServices: '*'
  routes:
    auth:
      path: /uaa/**
      url: http://localhost:9999/uaa/oauth/token
      stripPrefix: true
一切看似合情合理，但是，奇怪的问题却接踵而至；
当直接访问 Authenticate Server 的时候，
1
$ curl demo:demo@localhost:9999/uaa/oauth/token -d grant_type=password -d username=user -d password=password
得到正常结果；
1
{"access_token":"09abb86d-c307-4683-b00c-0a83860cadd7","token_type":"bearer","refresh_token":"048d31fa-fd55-4be0-9236-6c179d0a3b65","expires_in":42416,"scope":"read write"}
但是一旦通过 ZUUL 进行转发 ( 既是通过 localhost:8000/uaa/ 的访问，将会转发到 localhost:9999/uaa/oauth/token 地址上 )
1
$ curl demo:demo@localhost:8000/uaa/ -d grant_type=password -d username=user -d password=password
就得到验证失败的结果，
1
{"timestamp":1496060499677,"status":401,"error":"Unauthorized","message":"Bad credentials","path":"/uaa/oauth/token/"}
从返回结果上也可以清晰的看到，获取 oauth token 的路径为 /uaa/oauth/token/ 也是正确的；这不和使用使用 localhost:9999/uaa/oauth/token 一模一样吗？
代码分析

后续无奈之下，调试代码，
从日志中可以发现，验证 client 和 user 的身份信息都是通过如下方法进行的
AbstractUserDetailsAuthenticationProvider.java
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
public Authentication authenticate(Authentication authentication)
      throws AuthenticationException {
         // Determine username
   String username = (authentication.getPrincipal() == null) ? "NONE_PROVIDED"
         : authentication.getName();
   boolean cacheWasUsed = true;
   UserDetails user = this.userCache.getUserFromCache(username);
   if (user == null) {
      cacheWasUsed = false;
      ...
      user = retrieveUser(username, (UsernamePasswordAuthenticationToken) authentication);
      ...         
   }
   ....
   return createSuccessAuthentication(principalToReturn, authentication, user);
}
将其它不相干的代码暂时删除；主要是通过上述代码第 13 行，获取用户信息；从该行代码进入
DaoAuthenticationProvider.java
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
protected final UserDetails retrieveUser(String username,
      UsernamePasswordAuthenticationToken authentication)
      throws AuthenticationException {
   UserDetails loadedUser;
   ....
   loadedUser = this.getUserDetailsService().loadUserByUsername(username);
   
   ....
   // 如果 loadedUser 没有找到，则会抛出 Bad credentials 认证失败的错误；
   return loadedUser;
}
好了，抛出错误的代码行找到了，那有什么性质呢？
若直接访问，也就是正常的情况下：
验证 client 的时候，this.getUserDetailsService() 返回 ClientDetailsUserDetailsService
验证 user 的时候，this.getUserDetailsService() 返回 InMemoryUserDetailsManager
若 ZUUL 转发，也就是报错的情况下：
验证 client 的时候，this.getUserDetailsService() 返回 InMemoryUserDetailsManager；
这就是问题的原因所在了，正常情况下，应该使用的是 ClientDetailsUserDetailsService，但是这里却使用了 InMemoryUserDetailsManager 所以导致错误的产生；
难道是代码的错误，如果是代码的错误，那这个就是 Spring OAuth 的一个 Bug，我可没有精力去修改该这个玩意儿呀…. 找到了代码的出处，但迫于没有精力去修改该，只好作罢；下面只好从一些细节现象上入手了，看看两种访问的方式，在哪些细节上不同；
分析日志

分析两段 Authenticate Server 上的 logs，看看一些细微之处到底有什么异同，
1
$ curl demo:demo@localhost:9999/uaa/oauth/token -d grant_type=password -d username=user -d password=password
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
2017-05-29 20:18:07.197 DEBUG 27222 --- [nio-9999-exec-1] o.s.security.web.FilterChainProxy        : /oauth/token at position 1 of 11 in additional filter chain; firing Filter: 'WebAsyncManagerIntegrationFilter'
2017-05-29 20:18:07.197 DEBUG 27222 --- [nio-9999-exec-1] o.s.security.web.FilterChainProxy        : /oauth/token at position 2 of 11 in additional filter chain; firing Filter: 'SecurityContextPersistenceFilter'
2017-05-29 20:18:07.197 DEBUG 27222 --- [nio-9999-exec-1] o.s.security.web.FilterChainProxy        : /oauth/token at position 3 of 11 in additional filter chain; firing Filter: 'HeaderWriterFilter'
2017-05-29 20:18:07.197 DEBUG 27222 --- [nio-9999-exec-1] o.s.s.w.header.writers.HstsHeaderWriter  : Not injecting HSTS header since it did not match the requestMatcher org.springframework.security.web.header.writers.HstsHeaderWriter$SecureRequestMatcher@4469b76e
2017-05-29 20:18:07.197 DEBUG 27222 --- [nio-9999-exec-1] o.s.security.web.FilterChainProxy        : /oauth/token at position 4 of 11 in additional filter chain; firing Filter: 'LogoutFilter'
2017-05-29 20:18:07.197 DEBUG 27222 --- [nio-9999-exec-1] o.s.s.w.u.matcher.AntPathRequestMatcher  : Checking match of request : '/oauth/token'; against '/logout'
2017-05-29 20:18:07.197 DEBUG 27222 --- [nio-9999-exec-1] o.s.security.web.FilterChainProxy        : /oauth/token at position 5 of 11 in additional filter chain; firing Filter: 'BasicAuthenticationFilter'
2017-05-29 20:18:07.197 DEBUG 27222 --- [nio-9999-exec-1] o.s.s.w.a.www.BasicAuthenticationFilter  : Basic Authentication Authorization header found for user 'demo'
2017-05-29 20:18:07.197 DEBUG 27222 --- [nio-9999-exec-1] o.s.s.authentication.ProviderManager     : Authentication attempt using org.springframework.security.authentication.dao.DaoAuthenticationProvider
2017-05-29 20:18:07.198 DEBUG 27222 --- [nio-9999-exec-1] o.s.s.w.a.www.BasicAuthenticationFilter  : Authentication success: org.springframework.security.authentication.UsernamePasswordAuthenticationToken@44334cb7: Principal: org.springframework.security.core.userdetails.User@2efde3: Username: demo; Password: [PROTECTED]; Enabled: true; AccountNonExpired: true; credentialsNonExpired: true; AccountNonLocked: true; Granted Authorities: ROLE_USER; Credentials: [PROTECTED]; Authenticated: true; Details: org.springframework.security.web.authentication.WebAuthenticationDetails@b364: RemoteIpAddress: 0:0:0:0:0:0:0:1; SessionId: null; Granted Authorities: ROLE_USER
2017-05-29 20:18:07.198 DEBUG 27222 --- [nio-9999-exec-1] o.s.security.web.FilterChainProxy        : /oauth/token at position 6 of 11 in additional filter chain; firing Filter: 'RequestCacheAwareFilter'
2017-05-29 20:18:07.198 DEBUG 27222 --- [nio-9999-exec-1] o.s.security.web.FilterChainProxy        : /oauth/token at position 7 of 11 in additional filter chain; firing Filter: 'SecurityContextHolderAwareRequestFilter'
2017-05-29 20:18:07.198 DEBUG 27222 --- [nio-9999-exec-1] o.s.security.web.FilterChainProxy        : /oauth/token at position 8 of 11 in additional filter chain; firing Filter: 'AnonymousAuthenticationFilter'
2017-05-29 20:18:07.198 DEBUG 27222 --- [nio-9999-exec-1] o.s.s.w.a.AnonymousAuthenticationFilter  : SecurityContextHolder not populated with anonymous token, as it already contained: 'org.springframework.security.authentication.UsernamePasswordAuthenticationToken@44334cb7: Principal: org.springframework.security.core.userdetails.User@2efde3: Username: demo; Password: [PROTECTED]; Enabled: true; AccountNonExpired: true; credentialsNonExpired: true; AccountNonLocked: true; Granted Authorities: ROLE_USER; Credentials: [PROTECTED]; Authenticated: true; Details: org.springframework.security.web.authentication.WebAuthenticationDetails@b364: RemoteIpAddress: 0:0:0:0:0:0:0:1; SessionId: null; Granted Authorities: ROLE_USER'
2017-05-29 20:18:07.198 DEBUG 27222 --- [nio-9999-exec-1] o.s.security.web.FilterChainProxy        : /oauth/token at position 9 of 11 in additional filter chain; firing Filter: 'SessionManagementFilter'
2017-05-29 20:18:07.198 DEBUG 27222 --- [nio-9999-exec-1] s.CompositeSessionAuthenticationStrategy : Delegating to org.springframework.security.web.authentication.session.ChangeSessionIdAuthenticationStrategy@6aa8cd60
2017-05-29 20:18:07.198 DEBUG 27222 --- [nio-9999-exec-1] o.s.security.web.FilterChainProxy        : /oauth/token at position 10 of 11 in additional filter chain; firing Filter: 'ExceptionTranslationFilter'
2017-05-29 20:18:07.198 DEBUG 27222 --- [nio-9999-exec-1] o.s.security.web.FilterChainProxy        : /oauth/token at position 11 of 11 in additional filter chain; firing Filter: 'FilterSecurityInterceptor'
2017-05-29 20:18:07.198 DEBUG 27222 --- [nio-9999-exec-1] o.s.s.w.u.matcher.AntPathRequestMatcher  : Checking match of request : '/oauth/token'; against '/oauth/token'
2017-05-29 20:18:07.198 DEBUG 27222 --- [nio-9999-exec-1] o.s.s.w.a.i.FilterSecurityInterceptor    : Secure object: FilterInvocation: URL: /oauth/token; Attributes: [fullyAuthenticated]
2017-05-29 20:18:07.198 DEBUG 27222 --- [nio-9999-exec-1] o.s.s.w.a.i.FilterSecurityInterceptor    : Previously Authenticated: org.springframework.security.authentication.UsernamePasswordAuthenticationToken@44334cb7: Principal: org.springframework.security.core.userdetails.User@2efde3: Username: demo; Password: [PROTECTED]; Enabled: true; AccountNonExpired: true; credentialsNonExpired: true; AccountNonLocked: true; Granted Authorities: ROLE_USER; Credentials: [PROTECTED]; Authenticated: true; Details: org.springframework.security.web.authentication.WebAuthenticationDetails@b364: RemoteIpAddress: 0:0:0:0:0:0:0:1; SessionId: null; Granted Authorities: ROLE_USER
2017-05-29 20:18:07.198 DEBUG 27222 --- [nio-9999-exec-1] o.s.s.access.vote.AffirmativeBased       : Voter: org.springframework.security.web.access.expression.WebExpressionVoter@4e8907f, returned: 1
2017-05-29 20:18:07.198 DEBUG 27222 --- [nio-9999-exec-1] o.s.s.w.a.i.FilterSecurityInterceptor    : Authorization successful
1
$ curl demo:demo@localhost:8000/uaa/ -d grant_type=password -d username=user -d password=password
1
2
3
4
5
6
7
8
9
10
11
2017-05-29 20:37:39.070 DEBUG 28225 --- [nio-9999-exec-6] o.s.security.web.FilterChainProxy        : /oauth/token/ at position 1 of 11 in additional filter chain; firing Filter: 'WebAsyncManagerIntegrationFilter'
2017-05-29 20:37:39.070 DEBUG 28225 --- [nio-9999-exec-6] o.s.security.web.FilterChainProxy        : /oauth/token/ at position 2 of 11 in additional filter chain; firing Filter: 'SecurityContextPersistenceFilter'
2017-05-29 20:37:39.070 DEBUG 28225 --- [nio-9999-exec-6] o.s.security.web.FilterChainProxy        : /oauth/token/ at position 3 of 11 in additional filter chain; firing Filter: 'HeaderWriterFilter'
2017-05-29 20:37:39.070 DEBUG 28225 --- [nio-9999-exec-6] o.s.s.w.header.writers.HstsHeaderWriter  : Not injecting HSTS header since it did not match the requestMatcher org.springframework.security.web.header.writers.HstsHeaderWriter$SecureRequestMatcher@5c1a42b0
2017-05-29 20:37:39.070 DEBUG 28225 --- [nio-9999-exec-6] o.s.security.web.FilterChainProxy        : /oauth/token/ at position 4 of 11 in additional filter chain; firing Filter: 'LogoutFilter'
2017-05-29 20:37:39.070 DEBUG 28225 --- [nio-9999-exec-6] o.s.s.w.u.matcher.AntPathRequestMatcher  : Checking match of request : '/oauth/token/'; against '/logout'
2017-05-29 20:37:39.070 DEBUG 28225 --- [nio-9999-exec-6] o.s.security.web.FilterChainProxy        : /oauth/token/ at position 5 of 11 in additional filter chain; firing Filter: 'BasicAuthenticationFilter'
2017-05-29 20:37:39.070 DEBUG 28225 --- [nio-9999-exec-6] o.s.s.w.a.www.BasicAuthenticationFilter  : Basic Authentication Authorization header found for user 'demo'
2017-05-29 20:37:39.070 DEBUG 28225 --- [nio-9999-exec-6] o.s.s.authentication.ProviderManager     : Authentication attempt using org.springframework.security.authentication.dao.DaoAuthenticationProvider
2017-05-29 20:37:39.071 DEBUG 28225 --- [nio-9999-exec-6] o.s.s.a.dao.DaoAuthenticationProvider    : User 'demo' not found
2017-05-29 20:37:39.071 DEBUG 28225 --- [nio-9999-exec-6] o.s.s.w.a.www.BasicAuthenticationFilter  : Authentication request for failed: org.springframework.security.authentication.BadCredentialsException: Bad credentials
可见，两端 logs 是何其的相似；oh，wait，我发现了一个非常奇怪的地方，通过直接访问的方式，映射的地址是 /oauth/token，但是通过 ZUUL 转发的方式，映射的地址却是 /oauth/token/；这是不是说明了什么？经过作者的后续验证，的确，这就是问题发生的地方，也就是为什么验证没有通过的根本原因，就是多了一个 /，而酿成了我一整个下午不知所措的血案！
解决
既然知道了，是因为映射的时候，多了一个/引起的，那么该如何解决呢？直觉告诉我，一定是一个非常琐碎，且不起眼的地方引发了这场血案~~，那到底是哪里呢？找到了，
如果使用下面这种方式，
1
$ curl demo:demo@localhost:8000/uaa/ -d grant_type=password -d username=user -d password=password
验证不通过，转发地址会被映射到 /uaa/oauth/token/ 上
如果使用下面这种方式，
1
$ curl demo:demo@localhost:8000/uaa -d grant_type=password -d username=user -d password=password
便得到了梦寐以求的 access token，转发地址将会被映射到 /uaa/oauth/token 上，正式因为后缀少了这个该死的/所以一切通过；
1
{"access_token":"a97141e2-6879-4231-b748-024bc3b9d5b3","token_type":"bearer","refresh_token":"e9d4d03f-c746-48b7-98a5-affe7b9cc195","expires_in":43199,"scope":"read write"}
猜测，难道，在 ZUUL 在替换匹配 /uaa/ 的时候，只是将 /uaa/ 的前面部分 /uaa 进行了替换，然后使用 url http://localhost:9999/uaa/oauth/token 来进行填充，所以最后多了一个/? 若不是这样，真想不出其它的理由了… 真不知道这段逻辑是哪位大神写的，该拉出去打板子了….
代码下载
convert_oauth2-sso-demo_to_springcloud.zip