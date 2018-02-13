使用Gradle创建一个最简单的Spring Boot项目 - CSDN博客 http://blog.csdn.net/u013360850/article/details/53415005
https://spring.io/guides/gs/rest-service/

很多刚开始用Gradle的不能运行是因为依赖下载失败，请先看着篇文章： Gradle编译时下载依赖失败解决方法

最近在学习 Spring Boot ，但是由于没有科学上网，导致使用 Gradle 开发时编译特别慢并且经常出错，遇到很多问题，看了很多博客都写的非常零碎和混乱，今天在公司看了一天的官方文档才算是刚刚入门，所以记录一下，希望能对初学者能有所帮助
开发工具及环境

JDK 1.7+ 
Spring Boot 要求 JDK 不低于1.6，推荐使用1.8
编译工具 Gradle 
安装可以参考我之前写的博客（Gradle环境搭建），或其他很多教程都可以找到
开发工具建议使用IDEA或者 STS（Spring Tool Suite） 
因为集成度比较高，不需要再单独下载插件，如果使用 Eclipse 或 MyEclipse 需要单独下载 Gradle 和 Spring 插件，并且没有科学上网很容易失败，在这里我们使用 IDEA 作为开发工具
Spring Boot 是什么

Spring Boot 是 Spring 社区发布的一个开源项目，旨在帮助开发者快速并且更简单的构建项目。大多数 Spring Boot 项目只需要很少的配置文件。
Spring Boot 特性

创建独立的 Spring 项目
内置 Tomcat 和 Jetty 容器
提供一个 starter POMs 来简化 Maven 配置
提供了一系列大型项目中常见的非功能性特性，如安全、指标，健康检测、外部配置等
完全没有代码生成和 xml 配置文件
Spring Boot 应用快速搭建官方文档

1. 创建一个 Gradle 项目，填入所需要的信息

2. 创建相应的目录

因为 Spring Boot 使用 Gradle 编译，所以有固定的文件结构

目录结构

─src
     build.gradle
    ├─main
    │  ├─java
    │  │      SpringController.java
    │  │
    │  └─resources
    └─test
        ├─java
        └─resources
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
项目文件结构

3. 创建一个 Controller 类(在 main 文件夹下)

SpringController.java
import org.springframework.boot.*;
import org.springframework.boot.autoconfigure.*;
import org.springframework.stereotype.*;
import org.springframework.web.bind.annotation.*;

//表明这是一个 Controller
@Controller

//RestController是一种Rest风格的Controller，可以直接返回对象而不返回视图，返回的对象可以使JSON，XML等
//@RestController

//使用自动配置，主动添加并解析bean，配置文件等信息
@EnableAutoConfiguration

public class SpringController {

    //设置访问的url
    @RequestMapping("/")
    //表示返回JSON格式的结果，如果前面使用的是@RestController可以不用写
    @ResponseBody
    String home() {
        return "Hello World!";//返回结果为字符串
    }

    public static void main(String[] args) throws Exception {
        //通过SpringApplication的run()方法启动应用，无需额外的配置其他的文件
        SpringApplication.run(SpringController.class, args);
    }
}
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
4. 修改 build.gradle 文件

build.gradle
默认生成的 Gradle 文件并不能满足编译 Spring Boot 应用，需要手动修改
buildscript {
    repositories {
        mavenCentral()//依赖Maven仓库
    }
    dependencies {
        //使用1.4.2.RELEASE版本的Spring框架
        classpath("org.springframework.boot:spring-boot-gradle-plugin:1.4.2.RELEASE")
    }
}

apply plugin: 'java'
apply plugin: 'spring-boot'

//生成的jar包包名和版本
jar {
    baseName = 'gs-rest-service'
    version =  '0.1.0'
}

repositories {
    mavenCentral()
}

//设置jdk的版本
sourceCompatibility = 1.8
targetCompatibility = 1.8

//添加编译时的依赖
dependencies {
    compile("org.springframework.boot:spring-boot-starter-web")
    testCompile('org.springframework.boot:spring-boot-starter-test')
}
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
5. 编译项目

在命令行进入到该项目根目录下，输入 gradle build 进行编译
编译的过程中会下载很多的jar包，如果没有科学上网可能会很慢

编译成功后输出build successful

D:\WorkSpace\IntelliJIDEA\springboot>gradle build
The plugin id 'spring-boot' is deprecated. Please use 'org.springframework.boot' instead.
:compileJava                                                                                                               
:processResources UP-TO-DATE
:classes
:findMainClass
:jar
:bootRepackage                                                                                                        
:assemble
:compileTestJava UP-TO-DATE
:processTestResources UP-TO-DATE
:testClasses UP-TO-DATE
:test UP-TO-DATE
:check UP-TO-DATE
:build

BUILD SUCCESSFUL

Total time: 5.807 secs
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
也可以在左侧的 gradle 中点击刷新按钮，效果是一样的 
编译项目
6. 启动项目

在命令行中输入 gradle bootrun 进行启动项目
也可以使用左侧的 gradle 中 Task 下的 application 中的 bootRun 按钮启动（参照上图）
默认的会启动 tomcat，使用8080端口，如果端口被占用会报错

启动成功后会输出以下内容

D:\WorkSpace\IntelliJIDEA\springboot>gradle bootrun
The plugin id 'spring-boot' is deprecated. Please use 'org.springframework.boot' instead.
:compileJava UP-TO-DATE                                                                                                                                            
:processResources UP-TO-DATE
:classes UP-TO-DATE
:findMainClass
:bootRun                                                     

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::        (v1.4.2.RELEASE)

2016-11-30 22:14:47.878  INFO 9120 --- [           main] SpringController                         : Starting SpringController on H with PID 9120 (D:\WorkSpace\Intel
liJIDEA\springboot\build\classes\main started by 50185 in D:\WorkSpace\IntelliJIDEA\springboot)
2016-11-30 22:14:47.880  INFO 9120 --- [           main] SpringController                         : No active profile set, falling back to default profiles: default

2016-11-30 22:14:47.911  INFO 9120 --- [           main] ationConfigEmbeddedWebApplicationContext : Refreshing org.springframework.boot.context.embedded.AnnotationC
onfigEmbeddedWebApplicationContext@57c758ac: startup date [Wed Nov 30 22:14:47 CST 2016]; root of context hierarchy
2016-11-30 22:14:49.330  INFO 9120 --- [           main] s.b.c.e.t.TomcatEmbeddedServletContainer : Tomcat initialized with port(s): 8080 (http)
2016-11-30 22:14:49.343  INFO 9120 --- [           main] o.apache.catalina.core.StandardService   : Starting service Tomcat
2016-11-30 22:14:49.344  INFO 9120 --- [           main] org.apache.catalina.core.StandardEngine  : Starting Servlet Engine: Apache Tomcat/8.5.6
2016-11-30 22:14:49.457  INFO 9120 --- [ost-startStop-1] o.a.c.c.C.[Tomcat].[localhost].[/]       : Initializing Spring embedded WebApplicationContext
2016-11-30 22:14:49.458  INFO 9120 --- [ost-startStop-1] o.s.web.context.ContextLoader            : Root WebApplicationContext: initialization completed in 1550 ms
2016-11-30 22:14:49.642  INFO 9120 --- [ost-startStop-1] o.s.b.w.servlet.ServletRegistrationBean  : Mapping servlet: 'dispatcherServlet' to [/]
2016-11-30 22:14:49.647  INFO 9120 --- [ost-startStop-1] o.s.b.w.servlet.FilterRegistrationBean   : Mapping filter: 'characterEncodingFilter' to: [/*]
2016-11-30 22:14:49.648  INFO 9120 --- [ost-startStop-1] o.s.b.w.servlet.FilterRegistrationBean   : Mapping filter: 'hiddenHttpMethodFilter' to: [/*]
2016-11-30 22:14:49.648  INFO 9120 --- [ost-startStop-1] o.s.b.w.servlet.FilterRegistrationBean   : Mapping filter: 'httpPutFormContentFilter' to: [/*]
2016-11-30 22:14:49.648  INFO 9120 --- [ost-startStop-1] o.s.b.w.servlet.FilterRegistrationBean   : Mapping filter: 'requestContextFilter' to: [/*]
2016-11-30 22:14:49.941  INFO 9120 --- [           main] s.w.s.m.m.a.RequestMappingHandlerAdapter : Looking for @ControllerAdvice: org.springframework.boot.context.
embedded.AnnotationConfigEmbeddedWebApplicationContext@57c758ac: startup date [Wed Nov 30 22:14:47 CST 2016]; root of context hierarchy
2016-11-30 22:14:50.022  INFO 9120 --- [           main] s.w.s.m.m.a.RequestMappingHandlerMapping : Mapped "{[/]}" onto java.lang.String SpringController.home()
2016-11-30 22:14:50.026  INFO 9120 --- [           main] s.w.s.m.m.a.RequestMappingHandlerMapping : Mapped "{[/error]}" onto public org.springframework.http.Respons
eEntity<java.util.Map<java.lang.String, java.lang.Object>> org.springframework.boot.autoconfigure.web.BasicErrorController.error(javax.servlet.http.HttpServletReque
st)
2016-11-30 22:14:50.026  INFO 9120 --- [           main] s.w.s.m.m.a.RequestMappingHandlerMapping : Mapped "{[/error],produces=[text/html]}" onto public org.springf
ramework.web.servlet.ModelAndView org.springframework.boot.autoconfigure.web.BasicErrorController.errorHtml(javax.servlet.http.HttpServletRequest,javax.servlet.http
.HttpServletResponse)
2016-11-30 22:14:50.050  INFO 9120 --- [           main] o.s.w.s.handler.SimpleUrlHandlerMapping  : Mapped URL path [/webjars/**] onto handler of type [class org.sp
ringframework.web.servlet.resource.ResourceHttpRequestHandler]
2016-11-30 22:14:50.050  INFO 9120 --- [           main] o.s.w.s.handler.SimpleUrlHandlerMapping  : Mapped URL path [/**] onto handler of type [class org.springfram
ework.web.servlet.resource.ResourceHttpRequestHandler]
2016-11-30 22:14:50.088  INFO 9120 --- [           main] o.s.w.s.handler.SimpleUrlHandlerMapping  : Mapped URL path [/**/favicon.ico] onto handler of type [class or
g.springframework.web.servlet.resource.ResourceHttpRequestHandler]
2016-11-30 22:14:50.209  INFO 9120 --- [           main] o.s.j.e.a.AnnotationMBeanExporter        : Registering beans for JMX exposure on startup
2016-11-30 22:14:50.263  INFO 9120 --- [           main] s.b.c.e.t.TomcatEmbeddedServletContainer : Tomcat started on port(s): 8080 (http)
2016-11-30 22:14:50.267  INFO 9120 --- [           main] SpringController                         : Started SpringController in 2.734 seconds (JVM running for 3.049
)
2016-11-30 22:14:57.820  INFO 9120 --- [nio-8080-exec-1] o.a.c.c.C.[Tomcat].[localhost].[/]       : Initializing Spring FrameworkServlet 'dispatcherServlet'
2016-11-30 22:14:57.820  INFO 9120 --- [nio-8080-exec-1] o.s.web.servlet.DispatcherServlet        : FrameworkServlet 'dispatcherServlet': initialization started
2016-11-30 22:14:57.836  INFO 9120 --- [nio-8080-exec-1] o.s.web.servlet.DispatcherServlet        : FrameworkServlet 'dispatcherServlet': initialization completed i
n 16 ms
> Building 80% > :bootRun
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
7. 通过浏览器访问该项目

该项目因为配置的路径为根路径，所以直接访问localhost:8080即可
如果想停止运行该项目可以在命令行中按Ctrl+C，输入Y即可停止 
访问项目
至此，一个最简单的 Spring Boot 项目创建完成，想要学习更多的知识可以访问官方的文档
如果遇到 IDEA 中的 Controller 提示没有引入包无法进行代码提示可以点击 Gradle 的刷新按钮，等待编译完成就可以进行后续操作了
源码下载

操作步骤记录