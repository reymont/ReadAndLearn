

采用Jmeter测试Dubbo服务接口 - 51Testing软件测试网 
http://www.51testing.com/html/12/n-3715712.html

准备两台机器，一台用于部署dubbo的服务端代码，另一台安装jmeter，用于运行客户端的测试脚本。采用zookeeper作为dubbo的注册中心。本次测试所有依赖的版本信息如下：
　　· jdk版本：1.7
　　· maven版本：3.3
　　· jmeter版本：3.0
　　· dubbo版本：2.5.4
　　为简单起见，我们直接使用dubbo官方提供的demo工程来进行讲解。
　　服务端部署
　　具体步骤
　　1、首先clone dubbo的官方代码，编译安装：
　　# cd ~
　　# git clone https://github.com/alibaba/dubbo.git
　　# cd dubbo
　　# mvn clean install -DskipTests=true
　　2、安装成功之后，我们进入demo工程，解压服务端的代码：
　　# cd dubbo-demo/dubbo-demo-provider/target
　　# tar zxvf dubbo-demo-provider-2.5.4-SNAPSHOT-assembly.tar.gz
　　# cd dubbo-demo-provider-2.5.4-SNAPSHOT
　　我们需要编辑dubbo的配置文件，使其采用zookeeper作为注册中心（默认情况下采用组播注册中心）：
　　# vim conf/dubbo.properties
　　修改好之后的配置文件内容如下：
dubbo.container=log4j,spring
dubbo.application.name=demo-provider
dubbo.application.owner=
dubbo.registry.address=zookeeper://10.168.120.xxx:2181
dubbo.monitor.protocol=registry
dubbo.protocol.name=dubbo
dubbo.protocol.port=20880
dubbo.service.loadbalance=roundrobin
dubbo.log4j.file=logs/dubbo-demo-provider.log
dubbo.log4j.level=WARN
　　zookeeper的地址根据自己的实际情况填写即可。
　　3、启动服务：
　　# bin/start.sh
　　如果启动成功，会有如下的输出：
　　Starting the demo-provider ......OK!
　　PID: 28164
　　STDOUT: logs/stdout.log
　　注意点
　　1、如果出现启动失败，或者注册中心注册失败的问题，请检查注册中心的ip地址是否配置成功，以及防火墙是否开放了对应的端口。
　　2、默认情况下，start.sh里配置的jvm堆栈大小为2g，如果自己的机器内存不够的话，可以调低start.sh里面jvm堆栈大小的配置。
　　3、如果还有其他问题，可以通过logs文件夹下的日志进一步分析。
　　客户端部署
　　具体步骤
　　我们借助jmeter的java sampler来调用服务端的接口进行测试，所以我们需要将原先的客户端里的代码和java sampler进行结合。我们在刚才的demo工程目录下，创建我们的测试类：
　　# vim ~/dubbo/dubbo-demo/dubbo-demo-consumer/src/main/java/com/alibaba/dubbo/demo/consumer/DemoConsumer.java
　　具体代码如下：
package com.dubbo.test;
import org.apache.jmeter.protocol.java.sampler.AbstractJavaSamplerClient;
import org.apache.jmeter.protocol.java.sampler.JavaSamplerContext;
import org.apache.jmeter.samplers.SampleResult;
import org.springframework.context.support.ClassPathXmlApplicationContext;
import com.alibaba.dubbo.demo.DemoService;
import java.util.Random;
public classDemoConsumerextendsAbstractJavaSamplerClient{
private DemoService demoService = null;
@Override
publicvoidsetupTest(JavaSamplerContext context){
super.setupTest(context);
ClassPathXmlApplicationContext springContext = new ClassPathXmlApplicationContext(new String[] { "dubbo-demo-consumer.xml" });
springContext.start();
demoService = (DemoService) springContext.getBean("demoService");
}
@Override
publicSampleResultrunTest(JavaSamplerContext javaSamplerContext){
SampleResult sr = new SampleResult();
Random r = new Random();
try {
sr.sampleStart();
String result = demoService.sayHello(r.nextInt(100000) + "");
sr.setResponseData("from provider:" + result, null);
sr.setDataType(SampleResult.TEXT);
sr.setSuccessful(true);
sr.sampleEnd();
}
catch (Exception e) {
e.printStackTrace();
}
return sr;
}
@Override
publicvoidteardownTest(JavaSamplerContext context){
super.teardownTest(context);
}
}
　　自定义的java sampler测试类需要继承AbstractJavaSamplerClient抽象类，然后我们需要重载setupTest、runTest以及teardownTest这三个方法：
　　· setupTest：用于构建测试环境。我们在这里可以初始化spring以及dubbo上下文，获取服务端的bean。
　　· runTest：具体的测试逻辑。我们在这里向服务端发送了一个随机数字字符串，然后借助SampleResult类将服务端的返回值回显到jmeter。
　　· teardownTest：执行收尾工作，比如释放相关资源等。
　　同时，我们需要在pom里添加jmeter对应的依赖：
　　# vim ~/dubbo/dubbo-demo/dubbo-demo-consumer/pom.xml
　　添加的依赖如下：
<dependency>
<groupId>org.apache.jmeter</groupId>
<artifactId>ApacheJMeter_core</artifactId>
<version>3.0</version>
</dependency>
<dependency>
<groupId>org.apache.jmeter</groupId>
<artifactId>ApacheJMeter_java</artifactId>
<version>3.0</version>
</dependency>
　　将dubbo.properties以及dubbo-demo-consumer.xml文件拷贝到resources根目录下，方便程序读取配置文件，否则需要做些额外的工作使他们纳入到classpath中：
　　# cd ~/dubbo/dubbo-demo/dubbo-demo-consumer
　　# cp src/main/assembly/conf/dubbo.properties src/main/resources
　　# cp src/main/resources/META-INF/spring/dubbo-demo-consumer.xml src/main/resources
　　然后编辑dubbo.properties文件，使客户端也采用zookeeper作为注册中心：
　　dubbo.container=log4j,spring
　　dubbo.application.name=demo-consumer
　　dubbo.application.owner=
　　dubbo.registry.address=zookeeper://10.168.120.xxx:2181
　　dubbo.monitor.protocol=registry
　　dubbo.log4j.file=logs/dubbo-demo-consumer.log
　　dubbo.log4j.level=WARN
　　在dubbo-demo-consumer文件夹下重新执行 mvn clean install -DskipTests=true ，然后解压target目录下的dubbo-demo-consumer-2.5.4-SNAPSHOT-assembly.tar.gz。将解压目录的lib文件夹下的所有jar包拷贝到jmeter的lib文件夹下，并且将其中的dubbo-demo-consumer-2.5.4-SNAPSHOT.jar拷贝到jmeter的lib/ext文件夹。
　　启动jmeter，建立线程组，然后选择java sampler，并且添加察看结果树：

　　运行结果如下：

【有奖活动】2017软件测试现状调查 填问卷送51Testing测试资料大礼包！>>
