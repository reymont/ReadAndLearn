Spring Cloud Zuul重试机制探秘 | 程序猿DD http://blog.didispace.com/spring-cloud-zuul-retry-detail/

简介

本文章对应spring cloud的版本为(Dalston.SR4)，具体内容如下：

开启Zuul功能
通过源码了解Zuul的一次转发
怎么开启zuul的重试机制
Edgware.RC1版本的优化
开启Zuul的功能

首先如何使用spring cloud zuul完成路由转发的功能，这个问题很简单，只需要进行如下准备工作即可：

注册中心(Eureka Server)
zuul(同时也是Eureka Client)
应用服务(同时也是Eureka Client)
我们希望zuul和后端的应用服务同时都注册到Eureka Server上，当我们访问Zuul的某一个地址时，对应其实访问的是后端应用的某个地址，从而从这个地址返回一段内容，并展现到浏览器上。

注册中心(Eureka Server)

创建一个Eureka Server只需要在主函数上添加@EnableEurekaServer，并在properties文件进行简单配置即可，具体内容如下：

@EnableEurekaServer
@RestController
@SpringBootApplication
public class EurekaServerApplication {

   public static void main(String[] args) {
      SpringApplication.run(EurekaServerApplication.class, args);
   }
}
server.port=8761
eureka.client.register-with-eureka=false
eureka.client.fetch-registry=false
Zuul

主函数添加@EnableZuulProxy注解(因为集成Eureka，需要另外添加@EnableDiscoveryClient注解)。并配置properties文件，具体内容如下所示：

@EnableZuulProxy
@EnableDiscoveryClient
@SpringBootApplication
public class ZuulDemoApplication {
  	/**
  	 * 省略代码...
  	 */
}
server.port=8081
spring.application.name=ZUUL-CLIENT
zuul.routes.api-a.serviceId=EUREKA-CLIENT
zuul.routes.api-a.path=/api-a/**
eureka.client.service-url.defaultZone=http://localhost:8761/eureka
应用服务

@RestController
@EnableEurekaClient
@SpringBootApplication
public class EurekaClientApplication {

   public static void main(String[] args) {
      SpringApplication.run(EurekaClientApplication.class, args);
   }

   @RequestMapping(value = "/hello")
   public String index() {
      return "hello spring...";
   }
}
spring.application.name=EUREKA-CLIENT
eureka.client.service-url.defaultZone=http://localhost:8761/eureka
三个工程全部启动，这时当我们访问localhost:8081/api-a/hello时，你会看到浏览器输出的内容是hello spring...

通过源码了解Zuul的一次转发

接下来我们通过源码层面来了解下，一次转发内部都做了哪些事情。

首先我们查看Zuul的配置类ZuulProxyAutoConfiguration在这个类中有一项工作是初始化Zuul默认自带的Filter，其中有一个Filter很重要，它就是RibbonRoutingFilter。它主要是完成请求的路由转发。接下来我们看下他的run方法

@Override
public Object run() {
   RequestContext context = RequestContext.getCurrentContext();
   try {
      RibbonCommandContext commandContext = buildCommandContext(context);
      ClientHttpResponse response = forward(commandContext);
      setResponse(response);
      return response;
   }
   catch (ZuulException ex) {
      throw new ZuulRuntimeException(ex);
   }
   catch (Exception ex) {
      throw new ZuulRuntimeException(ex);
   }
}
可以看到进行转发的方法是forward，我们进一步查看这个方法，具体内容如下：
省略部分代码

protected ClientHttpResponse forward(RibbonCommandContext context) throws Exception {
   RibbonCommand command = this.ribbonCommandFactory.create(context);
   try {
      ClientHttpResponse response = command.execute();
      return response;
   }
   catch (HystrixRuntimeException ex) {
      return handleException(info, ex);
   }
}
ribbonCommandFactory指的是HttpClientRibbonCommandFactory这个类是在RibbonCommandFactoryConfiguration完成初始化的(触发RibbonCommandFactoryConfiguration的加载动作是利用ZuulProxyAutoConfiguration类上面的@Import标签)，具体代码如下：

@Configuration
@ConditionalOnRibbonHttpClient
protected static class HttpClientRibbonConfiguration {

   @Autowired(required = false)
   private Set<ZuulFallbackProvider> zuulFallbackProviders = Collections.emptySet();

   @Bean
   @ConditionalOnMissingBean
   public RibbonCommandFactory<?> ribbonCommandFactory(
         SpringClientFactory clientFactory, ZuulProperties zuulProperties) {
      return new HttpClientRibbonCommandFactory(clientFactory, zuulProperties, zuulFallbackProviders);
   }
}
知道了这个ribbonCommandFactory具体的实现类(HttpClientRibbonCommandFactory)，接下来我们看看它的create方法具体做了那些事情

@Override
public HttpClientRibbonCommand create(final RibbonCommandContext context) {
   ZuulFallbackProvider zuulFallbackProvider = getFallbackProvider(context.getServiceId());
   final String serviceId = context.getServiceId();
   final RibbonLoadBalancingHttpClient client = this.clientFactory.getClient(
         serviceId, RibbonLoadBalancingHttpClient.class);
   client.setLoadBalancer(this.clientFactory.getLoadBalancer(serviceId));

   return new HttpClientRibbonCommand(serviceId, client, context, zuulProperties, zuulFallbackProvider,
         clientFactory.getClientConfig(serviceId));
}
这个方法按照我的理解主要做了以下几件事情：

@Override
public HttpClientRibbonCommand create(final RibbonCommandContext context) {
   /**
    *获取所有ZuulFallbackProvider,即当Zuul
    *调用失败后的降级方法
    */
   ZuulFallbackProvider = xxxxx
   /**
    *创建处理请求转发类，该类会利用
    *Apache的Http client进行请求的转发
    */
   RibbonLoadBalancingHttpClient = xxxxx
   
   /**
    *将降级方法、处理请求转发类、以及其他一些内容
    *包装成HttpClientRibbonCommand(这个类继承了HystrixCommand)
    */
   return new HttpClientRibbonCommand(xxxxx);
}
到这里我们很清楚的知道了RibbonRoutingFilter类的forward
方法中RibbonCommand command = this.ribbonCommandFactory.create(context);这一行代码都做了哪些内容.

接下来调用的是command.execute();方法，通过刚刚的分析我们知道了command其实指的是HttpClientRibbonCommand，同时我们也知道HttpClientRibbonCommand继承了HystrixCommand所以当执行command.execute();时其实执行的是HttpClientRibbonCommand的run方法。查看源码我们并没有发现run方法，但是我们发现HttpClientRibbonCommand直接继承了AbstractRibbonCommand。所以其实执行的是AbstractRibbonCommand的run方法，接下来我们看看run方法里面都做了哪些事情：

@Override
protected ClientHttpResponse run() throws Exception {
   final RequestContext context = RequestContext.getCurrentContext();
   RQ request = createRequest();
   RS response = this.client.executeWithLoadBalancer(request, config);
   context.set("ribbonResponse", response);
   if (this.isResponseTimedOut()) {
      if (response != null) {
         response.close();
      }
   }
   return new RibbonHttpResponse(response);
}
可以看到在run方法中会调用client的executeWithLoadBalancer方法，通过上面介绍我们知道client指的是RibbonLoadBalancingHttpClient，而RibbonLoadBalancingHttpClient里面并没有executeWithLoadBalancer方法。(这里面会最终调用它的父类AbstractLoadBalancerAwareClient的executeWithLoadBalancer方法。)

具体代码如下：

public T executeWithLoadBalancer(final S request, final IClientConfig requestConfig) throws ClientException {
	/**
	 * 创建一个RetryHandler，这个很重要它是用来
	 * 决定利用RxJava的Observable是否进行重试的标准。
	 */
    RequestSpecificRetryHandler handler = getRequestSpecificRetryHandler(request, requestConfig);
    /**
     * 创建一个LoadBalancerCommand，这个类用来创建Observable
     * 以及根据RetryHandler来判断是否进行重试操作。
     */
    LoadBalancerCommand<T> command = LoadBalancerCommand.<T>builder()
            .withLoadBalancerContext(this)
            .withRetryHandler(handler)
            .withLoadBalancerURI(request.getUri())
            .build();

    try {
    	/**
    	 *command.submit()方法主要是创建了一个Observable(RxJava)
    	 *并且为这个Observable设置了重试次数，这个Observable最终
    	 *会回调AbstractLoadBalancerAwareClient.this.execute()
    	 *方法。
    	 */
        return command.submit(
            new ServerOperation<T>() {
                @Override
                public Observable<T> call(Server server) {
                    URI finalUri = reconstructURIWithServer(server, request.getUri());
                    S requestForServer = (S) request.replaceUri(finalUri);
                    try {
                        return Observable.just(AbstractLoadBalancerAwareClient.this.execute(requestForServer, requestConfig));
                    } 
                    catch (Exception e) {
                        return Observable.error(e);
                    }
                }
            })
            .toBlocking()
            .single();
    } catch (Exception e) {
        Throwable t = e.getCause();
        if (t instanceof ClientException) {
            throw (ClientException) t;
        } else {
            throw new ClientException(e);
        }
    }
    
}
下面针对于每一块内容做详细说明：
首先getRequestSpecificRetryHandler(request, requestConfig);这个方法其实调用的是RibbonLoadBalancingHttpClient的getRequestSpecificRetryHandler方法，这个方法主要是返回一个RequestSpecificRetryHandler

@Override
public RequestSpecificRetryHandler getRequestSpecificRetryHandler(RibbonApacheHttpRequest request, IClientConfig requestConfig) {
	/**
	 *这个很关键，请注意该类构造器中的前两个参数的值
	 *正因为一开始我也忽略了这两个值，所以后续给我造
	 *成一定的干扰。
	 */
   return new RequestSpecificRetryHandler(false, false,
         RetryHandler.DEFAULT, requestConfig);
}
接下来创建LoadBalancerCommand并将上一步获得的RequestSpecificRetryHandler作为参数内容。
最后调用LoadBalancerCommand的submit方法。该方法内容太长具体代码细节就不在这里贴出了，按照我个人的理解，只贴出相应的伪代码：

public Observable<T> submit(final ServerOperation<T> operation) {
	//相同server的重试次数(去除首次请求)
    final int maxRetrysSame = retryHandler.getMaxRetriesOnSameServer();
    //集群内其他Server的重试个数
    final int maxRetrysNext = retryHandler.getMaxRetriesOnNextServer();
    /**
     *创建一个Observable(RxJava),selectServer()方法是
     *利用Ribbon选择一个Server，并将其包装成Observable
     */
    Observable<T> o = selectServer().concatMap(new Func1<Server, Observable<T>>() { 
        @Override
        public Observable<T> call(final Server server) {
        	/**
        	 *这里会回调submit方法入参ServerOperation类的call方法，
        	 */
  			return operation.call(server).doOnEach(new Observer<T>() {}
		}
    }
    if (maxRetrysSame > 0) 
    	o = o.retry(retryPolicy(maxRetrysSame, true));
        
    if (maxRetrysNext > 0 && server == null) 
        o = o.retry(retryPolicy(maxRetrysNext, false));
    
    return o.onErrorResumeNext(new Func1<Throwable, Observable<T>>() {
        @Override
        public Observable<T> call(Throwable e) {
 	    	/**
 	    	 *转发请求失败时，会进入此方法。通过此方法进行判断
 	    	 *是否超过重试次数maxRetrysSame、maxRetrysNext。
 	    	 */
 	    }
    });
}
operation.call()方法最终会调用RibbonLoadBalancingHttpClient的execute方法，该方法内容如下：

@Override
public RibbonApacheHttpResponse execute(RibbonApacheHttpRequest request,
      final IClientConfig configOverride) throws Exception {
   /**
    * 组装参数(RequestConfig)
    */
   final RequestConfig.Builder builder = RequestConfig.custom();
   IClientConfig config = configOverride != null ? configOverride : this.config;
   builder.setConnectTimeout(config.get(
         CommonClientConfigKey.ConnectTimeout, this.connectTimeout));
   builder.setSocketTimeout(config.get(
         CommonClientConfigKey.ReadTimeout, this.readTimeout));
   builder.setRedirectsEnabled(config.get(
         CommonClientConfigKey.FollowRedirects, this.followRedirects));

   final RequestConfig requestConfig = builder.build();
   if (isSecure(configOverride)) {
      final URI secureUri = UriComponentsBuilder.fromUri(request.getUri())
            .scheme("https").build().toUri();
      request = request.withNewUri(secureUri);
   }
   final HttpUriRequest httpUriRequest = request.toRequest(requestConfig);
   /**
    * 发送转发请求
    */
   final HttpResponse httpResponse = this.delegate.execute(httpUriRequest);
   /**
    * 返回结果
    */
   return new RibbonApacheHttpResponse(httpResponse, httpUriRequest.getURI());
}
可以看到上面方法主要做的就是组装请求参数(包括各种超时时间)，然后发起转发请求，最终获取相应结果。

说到这里，zuul转发一次请求的基本原理就说完了。让我们再回顾下整个流程。

zuul的转发是通过RibbonRoutingFilter这个Filter进行操作的。
在转发之前，zuul利用Hystrix将此次转发请求包装成一个HystrixCommand，正应为这样才使得zuul具有了降级(Fallback)的功能，同时HystrixCommand是具备超时时间的(默认是1s)。而且Zuul默认采用的隔离级别是信号量模式。
在HystrixCommand内部zuul再次将请求包装成一个Observable，(有关RxJava的知识请参照其官方文档)。并且为Observable设置了重试次数。
事实真的是这样吗？当我看到源码中为Observable设置重试次数的时候，我以为这就是zuul的重试逻辑。遗憾的是我的想法是错误的。还记得上面我说的getRequestSpecificRetryHandler(request, requestConfig);这个方法吗?(不记得的同学可以回过头来再看下)，这个方法返回的是RequestSpecificRetryHandler这个类，而且在创建该类时，构造器的前两个参数都为false。(这一点非常重要)。这两个参数分别是okToRetryOnConnectErrors和okToRetryOnAllErrors。

我原本的想法是这个请求被包装成Observable，如果这次请求因为超时出现异常或者其他异常，这样就会触发Observable的重试机制(RxJava)，但是事实并非如此，为什么呢？原因就是上面的那两个参数，当出现了超时异常的时候，在触发重试机制之前会调用RequestSpecificRetryHandler的isRetriableException()方法，该方法的作用是用来判断是否执行重试动作，具体代码如下：

@Override
public boolean isRetriableException(Throwable e, boolean sameServer) {
    //此时该值为false
    if (okToRetryOnAllErrors) {
        return true;
    } 
    else if (e instanceof ClientException) {
        ClientException ce = (ClientException) e;
        if (ce.getErrorType() == ClientException.ErrorType.SERVER_THROTTLED) {
            return !sameServer;
        } else {
            return false;
        }
    } 
    else  {
        //此时该值为false
        return okToRetryOnConnectErrors && isConnectionException(e);
    }
}
说道这里zuul转发一次请求的基本原理大概了解了，同时也验证了一个事实就是实现zuul进行重试的逻辑并不是Observable的重试机制。那么问题来了？是什么使zuul具有重试功能的呢？

怎么开启zuul的重试机制

开启Zuul重试的功能在原有的配置基础上需要额外进行以下设置：

在pom中添加spring-retry的依赖(maven工程)
设置zuul.retryable=true(该参数默认为false)
具体properties文件内容如下：

server.port=8081
spring.application.name=ZUUL-CLIENT
#路由信息
zuul.routes.api-a.serviceId=EUREKA-CLIENT
zuul.routes.api-a.path=/api-a/**
#是否开启重试功能
zuul.retryable=true
#同一个Server重试的次数(除去首次)
ribbon.MaxAutoRetries=3
#切换相同Server的次数
ribbon.MaxAutoRetriesNextServer=0
eureka.client.service-url.defaultZone=http://localhost:8761/eureka
为了模拟出Zuul重试的功能，需要对后端应用服务进行改造，改造后的内容如下：

@RequestMapping(value = "/hello")
public String index() {
   System.out.println("request is coming...");
   try {
      Thread.sleep(100000);
   } catch (InterruptedException e) {
      System.out.println("线程被打断... " + e.getMessage());
   }
   return "hello spring ...";
}
通过使用Thread.sleep(100000)达到Zuul转发超时情况(Zuul默认连接超时未2s、read超时时间为5s)，从而触发Zuul的重试功能。这时候在此访问localhost:8081/api-a/hello时，查看应用服务后台，会发现最终打印三次"request is coming..."

通过现象看本质，接下来简单介绍下Zuul重试的原理。首先如果你工程classpath中存在spring-retry，那么zuul在初始化的时候就不会创建RibbonLoadBalancingHttpClient而是创建RetryableRibbonLoadBalancingHttpClient具体源代码如下：

@ConditionalOnClass(name = "org.apache.http.client.HttpClient")
@ConditionalOnProperty(name = "ribbon.httpclient.enabled", matchIfMissing = true)
public class HttpClientRibbonConfiguration {
   @Value("${ribbon.client.name}")
   private String name = "client";

   @Bean
   @ConditionalOnMissingBean(AbstractLoadBalancerAwareClient.class)
   @ConditionalOnMissingClass(value = "org.springframework.retry.support.RetryTemplate")
   public RibbonLoadBalancingHttpClient ribbonLoadBalancingHttpClient(
         IClientConfig config, ServerIntrospector serverIntrospector,
         ILoadBalancer loadBalancer, RetryHandler retryHandler) {
      RibbonLoadBalancingHttpClient client = new RibbonLoadBalancingHttpClient(
            config, serverIntrospector);
      client.setLoadBalancer(loadBalancer);
      client.setRetryHandler(retryHandler);
      Monitors.registerObject("Client_" + this.name, client);
      return client;
   }

   @Bean
   @ConditionalOnMissingBean(AbstractLoadBalancerAwareClient.class)
   @ConditionalOnClass(name = "org.springframework.retry.support.RetryTemplate")
   public RetryableRibbonLoadBalancingHttpClient retryableRibbonLoadBalancingHttpClient(
         IClientConfig config, ServerIntrospector serverIntrospector,
         ILoadBalancer loadBalancer, RetryHandler retryHandler,
         LoadBalancedRetryPolicyFactory loadBalancedRetryPolicyFactory) {
      RetryableRibbonLoadBalancingHttpClient client = new RetryableRibbonLoadBalancingHttpClient(
            config, serverIntrospector, loadBalancedRetryPolicyFactory);
      client.setLoadBalancer(loadBalancer);
      client.setRetryHandler(retryHandler);
      Monitors.registerObject("Client_" + this.name, client);
      return client;
   }
}
所以请求到来需要转发的时候(AbstractLoadBalancerAwareClient类中executeWithLoadBalancer方法会调用AbstractLoadBalancerAwareClient.this.execute())其实调用的是RetryableRibbonLoadBalancingHttpClient的execute方法(而不是没有重试时候RibbonLoadBalancingHttpClient的execute方法)，源码内容如下：

@Override
public RibbonApacheHttpResponse execute(final RibbonApacheHttpRequest request, final IClientConfig configOverride) throws Exception {
   final RequestConfig.Builder builder = RequestConfig.custom();
   IClientConfig config = configOverride != null ? configOverride : this.config;
   builder.setConnectTimeout(config.get(
         CommonClientConfigKey.ConnectTimeout, this.connectTimeout));
   builder.setSocketTimeout(config.get(
         CommonClientConfigKey.ReadTimeout, this.readTimeout));
   builder.setRedirectsEnabled(config.get(
         CommonClientConfigKey.FollowRedirects, this.followRedirects));

   final RequestConfig requestConfig = builder.build();
   final LoadBalancedRetryPolicy retryPolicy = loadBalancedRetryPolicyFactory.create(this.getClientName(), this);
   RetryCallback retryCallback = new RetryCallback() {
      @Override
      public RibbonApacheHttpResponse doWithRetry(RetryContext context) throws Exception {
         //on retries the policy will choose the server and set it in the context
         //extract the server and update the request being made
         RibbonApacheHttpRequest newRequest = request;
         if(context instanceof LoadBalancedRetryContext) {
            ServiceInstance service = ((LoadBalancedRetryContext)context).getServiceInstance();
            if(service != null) {
               //Reconstruct the request URI using the host and port set in the retry context
               newRequest = newRequest.withNewUri(new URI(service.getUri().getScheme(),
                     newRequest.getURI().getUserInfo(), service.getHost(), service.getPort(),
                     newRequest.getURI().getPath(), newRequest.getURI().getQuery(),
                     newRequest.getURI().getFragment()));
            }
         }
         if (isSecure(configOverride)) {
            final URI secureUri = UriComponentsBuilder.fromUri(newRequest.getUri())
                  .scheme("https").build().toUri();
            newRequest = newRequest.withNewUri(secureUri);
         }
         HttpUriRequest httpUriRequest = newRequest.toRequest(requestConfig);
         final HttpResponse httpResponse = RetryableRibbonLoadBalancingHttpClient.this.delegate.execute(httpUriRequest);
         if(retryPolicy.retryableStatusCode(httpResponse.getStatusLine().getStatusCode())) {
            if(CloseableHttpResponse.class.isInstance(httpResponse)) {
               ((CloseableHttpResponse)httpResponse).close();
            }
            throw new RetryableStatusCodeException(RetryableRibbonLoadBalancingHttpClient.this.clientName,
                  httpResponse.getStatusLine().getStatusCode());
         }
         return new RibbonApacheHttpResponse(httpResponse, httpUriRequest.getURI());
      }
   };
   return this.executeWithRetry(request, retryPolicy, retryCallback);
}
executeWithRetry方法内容如下：

private RibbonApacheHttpResponse executeWithRetry(RibbonApacheHttpRequest request, LoadBalancedRetryPolicy retryPolicy, RetryCallback<RibbonApacheHttpResponse, IOException> callback) throws Exception {
   RetryTemplate retryTemplate = new RetryTemplate();
   boolean retryable = request.getContext() == null ? true :
         BooleanUtils.toBooleanDefaultIfNull(request.getContext().getRetryable(), true);
   retryTemplate.setRetryPolicy(retryPolicy == null || !retryable ? new NeverRetryPolicy()
         : new RetryPolicy(request, retryPolicy, this, this.getClientName()));
   return retryTemplate.execute(callback);
}
按照我的理解，主要逻辑如下：

@Override
public RibbonApacheHttpResponse execute(final RibbonApacheHttpRequest request, final IClientConfig configOverride) throws Exception {
   /**
    *创建RequestConfig(请求信息)
    */
   final RequestConfig requestConfig = builder.build();
   final LoadBalancedRetryPolicy retryPolicy =            	loadBalancedRetryPolicyFactory.create(this.getClientName(), this);
   /**
    * 创建RetryCallbck的实现类，用来完成重试逻辑
    */
   RetryCallback retryCallback = new RetryCallback() {};
   
   //创建Spring-retry的模板类，RetryTemplate。
   RetryTemplate retryTemplate = new RetryTemplate();
	/**
	 *设置重试规则，即在什么情况下进行重试
	 *什么情况下停止重试。源码中这部分存在
	 *一个判断，判断的根据就是在zuul工程
	 *的propertris中配置的zuul.retryable
	 *该参数内容为true才可以具有重试功能。
	 */
	retryTemplate.setRetryPolicy(xxx);
	/**
	 *发起请求
	 */
	return retryTemplate.execute(callback);
}
到此为止我们不仅知道了zuul路由一次请求的整体过程，也明确了zuul因后端超时而触发重试的原理。可是似乎还存在着一个问题，就是超时问题。前面说过zuul把路由请求这个过程包装成一个HystrixCommnd，而在我的propertries文件中并没有设置Hystrix的超时时间(默认时间为1s)，而read的超时时间是5s(前面源码部分介绍过)。这里就会有人问，因为最外层是采用Hystrix，而Hystrix此时已经超时了，为什么还允许它内部继续使用spring-retry进行重试呢？带着这个问题我查看了官方GitHub上的issues，发现有人对此问题提出过疑问。作者给出的回复是Hystrix超时的时候并不会打断内部重试的操作。

其实说实话这块内容我并不是很理解(可能是因为Hystrix源码了解较少)，带着这个问题我给作者发了一封邮件，邮件对话内容如下：

我的(英语水平不好，大家见谅)：

I want to confirm two issues with you, First of all zuul retry only spring-retry exists and zuul.retry this parameter is true to take effect? The second problem is that if my classpath spring-retry at the same time I let zuul.retry this parameter is true, which means that at this time zuul have a retry mechanism, then why when Hystrix time-out can not interrupt the spring- retry it. thank you very much

作者的回复(重点)：

Zuul will retry failed requests IF Spring Retry is on the classpath and the property zuul.retryable is set to true. The retry is happening within the hystrix command, so if hystrix times out than a response is returned. Right now there is no mechanism to stop further retries from happening if hystrix times out before all the retries are exhauted.
On Thu, Nov 16, 2017 at 8:40 AM 李刚 spring_holy@163.com wrote:

虽然得到了作者的确认，但是这部分内容始终还是没有完全理解，后续还要看看Hystrix的源码。

Edgware.RC1版本的优化

在Edgware.RC1版本中，作者修改了代码并不使用Ribbon的默认值而是将ConnectTimeout以及ReadTimeout都赋值为1S),，同时调整Hystrix的超时时间，时间为(2S).具体信息内容如下：
https://github.com/spring-cloud/spring-cloud-netflix/pull/2261

同时作者也阐明了利用Hystrix包装使用Ribbon时关于超时时间的设置规则(以下内容来自GitHub)：

When using Hystrix commands that wrap Ribbon clients you want to make sure your Hystrix timeout is configured to be longer than the configured Ribbon timeout, including any potential
retries that might be made. For example, if your Ribbon connection timeout is one second and
the Ribbon client might retry the request three times, than your Hystrix timeout should
be slightly more than three seconds.

以上全部内容就是本人对Zuul重试机制的理解，由于水平有限可能有些问题没有阐述清楚，还请大家多多留言讨论。

最后感谢Spring4all社区提供这个平台，能让大家交流学习Spring相关知识。