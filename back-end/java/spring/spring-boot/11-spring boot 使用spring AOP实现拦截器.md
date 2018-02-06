spring boot 使用spring AOP实现拦截器 - CSDN博客 http://blog.csdn.net/clementad/article/details/52035199


在spring boot中，简单几步，使用spring AOP实现一个拦截器：

1、引入依赖：
```xml
<dependency>  
    <groupId>org.springframework.boot</groupId>  
    <artifactId>spring-boot-starter-aop</artifactId>  
</dependency>  
```

2、创建拦截器类（在该类中，定义了拦截规则：拦截com.xjj.web.controller包下面的所有类中，有@RequestMapping注解的方法。）：
```java
/** 
 * 拦截器：记录用户操作日志，检查用户是否登录…… 
 * @author XuJijun 
 */  
@Aspect  
@Component  
public class ControllerInterceptor {  
    private static final Logger logger = LoggerFactory.getLogger(ControllerInterceptor.class);  
      
    @Value("${spring.profiles}")  
    private String env;  
      
    /** 
     * 定义拦截规则：拦截com.xjj.web.controller包下面的所有类中，有@RequestMapping注解的方法。 
     */  
    @Pointcut("execution(* com.xjj.web.controller..*(..)) and @annotation(org.springframework.web.bind.annotation.RequestMapping)")  
    public void controllerMethodPointcut(){}  
      
    /** 
     * 拦截器具体实现 
     * @param pjp 
     * @return JsonResult（被拦截方法的执行结果，或需要登录的错误提示。） 
     */  
    @Around("controllerMethodPointcut()") //指定拦截器规则；也可以直接把“execution(* com.xjj.........)”写进这里  
    public Object Interceptor(ProceedingJoinPoint pjp){  
        long beginTime = System.currentTimeMillis();  
        MethodSignature signature = (MethodSignature) pjp.getSignature();  
        Method method = signature.getMethod(); //获取被拦截的方法  
        String methodName = method.getName(); //获取被拦截的方法名  
          
        Set<Object> allParams = new LinkedHashSet<>(); //保存所有请求参数，用于输出到日志中  
          
        logger.info("请求开始，方法：{}", methodName);  
          
        Object result = null;  
  
        Object[] args = pjp.getArgs();  
        for(Object arg : args){  
            //logger.debug("arg: {}", arg);  
            if (arg instanceof Map<?, ?>) {  
                //提取方法中的MAP参数，用于记录进日志中  
                @SuppressWarnings("unchecked")  
                Map<String, Object> map = (Map<String, Object>) arg;  
  
                allParams.add(map);  
            }else if(arg instanceof HttpServletRequest){  
                HttpServletRequest request = (HttpServletRequest) arg;  
                if(isLoginRequired(method)){  
                    if(!isLogin(request)){  
                        result = new JsonResult(ResultCode.NOT_LOGIN, "该操作需要登录！去登录吗？\n\n（不知道登录账号？请联系老许。）", null);  
                    }  
                }  
                  
                //获取query string 或 posted form data参数  
                Map<String, String[]> paramMap = request.getParameterMap();  
                if(paramMap!=null && paramMap.size()>0){  
                    allParams.add(paramMap);  
                }  
            }else if(arg instanceof HttpServletResponse){  
                //do nothing...  
            }else{  
                //allParams.add(arg);  
            }  
        }  
          
        try {  
            if(result == null){  
                // 一切正常的情况下，继续执行被拦截的方法  
                result = pjp.proceed();  
            }  
        } catch (Throwable e) {  
            logger.info("exception: ", e);  
            result = new JsonResult(ResultCode.EXCEPTION, "发生异常："+e.getMessage());  
        }  
          
        if(result instanceof JsonResult){  
            long costMs = System.currentTimeMillis() - beginTime;  
            logger.info("{}请求结束，耗时：{}ms", methodName, costMs);  
        }  
          
        return result;  
    }  
      
    /** 
     * 判断一个方法是否需要登录 
     * @param method 
     * @return 
     */  
    private boolean isLoginRequired(Method method){  
        if(!env.equals("prod")){ //只有生产环境才需要登录  
            return false;  
        }  
          
        boolean result = true;  
        if(method.isAnnotationPresent(Permission.class)){  
            result = method.getAnnotation(Permission.class).loginReqired();  
        }  
          
        return result;  
    }  
      
    //判断是否已经登录  
    private boolean isLogin(HttpServletRequest request) {  
        return true;  
        /*String token = XWebUtils.getCookieByName(request, WebConstants.CookieName.AdminToken); 
        if("1".equals(redisOperator.get(RedisConstants.Prefix.ADMIN_TOKEN+token))){ 
            return true; 
        }else { 
            return false; 
        }*/  
    }  
}  
```

3、测试

浏览器中输入：http://localhost:8082/api/admin/login

测试结果：

[plain] view plain copy
2016-07-26 11:58:12,057:INFO http-nio-8082-exec-1 (ControllerInterceptor.java:58) - 请求开始，方法：login  
2016-07-26 11:58:12,061:INFO http-nio-8082-exec-1 (ControllerInterceptor.java:103) - login请求结束，耗时：8ms  

证明拦截器已经生效。
源代码参考：https://github.com/xujijun/my-spring-boot

版权声明：本文为原创文章，转载请注明转自Clement-Xu的csdn博客。