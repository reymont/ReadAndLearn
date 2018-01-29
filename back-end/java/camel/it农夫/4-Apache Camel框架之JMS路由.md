Apache Camel框架之JMS路由 - CSDN博客 http://blog.csdn.net/kkdelta/article/details/7237096

继上次Camel如何在做项目集成类型的项目中用于从FTP取文件和传文件之后,我们在系统集成中经常遇到的另一个应用就是将数据通过JMS传到消息中间件的queue里,或者从消息中间件的queue里取消息.
本文简单的介绍和示例一个用Camel实现这样的需求:监听某一个文件夹是否有文件,取到文件后发送到另外一个系统监听的queue.(图片来源于Camel in Action)
1,因为要用JMS,这里介绍一个open source的activeMQ,可以从http://activemq.apache.org/download.html 下载,下载后解压,bin目录有一个activemq.bat文件,在命令行里运行activemq 启动activeMQ,如果能从从浏览器里访问 http://localhost:8161/admin/则activeMQ成功启动了.
2,在Camel里实现上图所示的路由:JAVA项目里需要将activeMQ的jar包配置到classpath下,Java代码如下:
[java] view plain copy
private static String user = ActiveMQConnection.DEFAULT_USER;  
private static String password = ActiveMQConnection.DEFAULT_PASSWORD;  
private static String url = ActiveMQConnection.DEFAULT_BROKER_URL;  
  
public static void main(String args[]) throws Exception {          
    CamelContext context = new DefaultCamelContext();          
    ConnectionFactory connectionFactory =   
        new ActiveMQConnectionFactory(user, password, url);  
    context.addComponent("jms",  
        JmsComponent.jmsComponentAutoAcknowledge(connectionFactory));  
    System.out.println(url + " " + user + password);          
    context.addRoutes(new RouteBuilder() {  
        public void configure() {                  
            from("file:d:/temp/inbox").to(  
            "jms:queue:TOOL.DEFAULT");  
        }  
    });  
    context.start();  
    boolean loop = true;  
    while (loop) {  
        Thread.sleep(25000);  
    }  
  
    context.stop();  
}  
Camel会在路由的时候将文件的内容以binary message发到activeMQ的名为'TOOL.DEFAULT'的queue .
当然也可以用如下的方式发送textmessage:from("file:d:/temp/inbox").convertBodyTo(String.class).to("jms:queue:TOOL.DEFAULT");
用下面的代码可以从Camel发送的queue里取到消息.
[java] view plain copy
private static String user = ActiveMQConnection.DEFAULT_USER;  
private static String password = ActiveMQConnection.DEFAULT_PASSWORD;  
private static String url = ActiveMQConnection.DEFAULT_BROKER_URL;  
private static boolean transacted;  
private static int ackMode = Session.AUTO_ACKNOWLEDGE;  
  
public static void main(String[] args) throws Exception {  
    ActiveMQConnectionFactory connectionFactory = new ActiveMQConnectionFactory(user, password, url);  
    Connection connection = connectionFactory.createConnection();  
    connection.start();  
    Session session = connection.createSession(transacted, ackMode);  
    Destination destination = session.createQueue("TOOL.DEFAULT");  
    MessageConsumer consumer = session.createConsumer(destination);  
    Message message = consumer.receive(1000);  
    if (message instanceof TextMessage) {  
        TextMessage txtMsg = (TextMessage) message;  
        System.out.println("Received Text message : " + txtMsg.getText());  
    } else if(message != null){  
        BytesMessage bytesMsg = (BytesMessage) message;  
        byte[] bytes = new byte[(int) bytesMsg.getBodyLength()];  
        bytesMsg.readBytes(bytes);  
        System.out.println("Received byte message: " + new String(bytes));  
    }  
    consumer.close();  
    session.close();  
    connection.close();  
}  
同样,上面的路由也可以通过Spring配置实现:
[html] view plain copy
<bean id="jms" class="org.apache.camel.component.jms.JmsComponent">  
    <property name="connectionFactory">  
        <bean class="org.apache.activemq.ActiveMQConnectionFactory">  
            <property name="brokerURL" value="failover://tcp://localhost:61616"/>  
        </bean>  
    </property>  
</bean>      
<camelContext xmlns="http://camel.apache.org/schema/spring">  
    <route>  
        <from uri="file:d:/temp/inbox"/>  
        <to uri="jms:queue:TOOL.DEFAULT"/>  
    </route>  
</camelContext>  