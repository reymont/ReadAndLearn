

从 0 到 1，搭建 dubbo 接口自动化测试 · TesterHome 
https://testerhome.com/topics/10617

公司dubbo接口数量较多，且核心接口较多，故需要一套dubbo接口自动化框架，来提高测试效率。

引用文本：https://testerhome.com/topics/9980 https://testerhome.com/topics/10525
1、dubbo接口自动化测试框架实现逻辑



2、框架具体功能

框架需要实现功能	功能说明	当前版本是否已实现
从maven库自动下载所需jar包	为了更好的自动化，所有的provider的jar都从maven下载，避免手工导入	已实现
参数自定义	匹配不同的dubbo接口，不同的参数需求	已实现
断言功能	一个接口是否调用成功，在于断言是否成功	已实现
邮件报警功能	如果dubbo接口调用provider失败，自动进行邮件报警	已实现
自动运行	利用jenkins自动运行	已实现
3、关键实践

由于目前阶段刚接触java及dubbo，本次实现为基本功能实现，数据隔离等没有做。

3.1 下载provider的jar包，并代理声明+zookeeper设置

<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"
       xmlns:p="http://www.springframework.org/schema/p"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
       http://www.springframework.org/schema/beans/spring-beans.xsd
       http://code.alibabatech.com/schema/dubbo
       http://code.alibabatech.com/schema/dubbo/dubbo.xsd">

    <dubbo:application name="demo-consumer"/>

    <dubbo:registry address="zookeeper://1127.0.0.1:2181" />

    <dubbo:reference id="IPromiseForOrderService" interface="com.test.api.IPromiseForOrderService" version="1.0" check="true"/>
</beans>
3.2 邮件发送功能

（1）邮件服务器配置在mailConfig.properties


（2）获取mailconfig信息，并封装成类

public class MailConfig {
    private static final String PROPERTIES_DEFAULT = "mailConfig.properties";
    public static String host;
    public static Integer port;
    public static String userName;
    public static String passWord;
    public static String emailForm;
    public static String timeout;
    public static String personal;
    public static Properties properties;
    static{
        init();
    }

    /**
     * 初始化
     */
    private static void init() {
        properties = new Properties();
        InputStream inputStream = null;
        try{

            inputStream = MailConfig.class.getClassLoader().getResourceAsStream(PROPERTIES_DEFAULT);
            properties.load(inputStream);
            inputStream.close();
            host = properties.getProperty("mailHost");
            port = Integer.parseInt(properties.getProperty("mailPort"));
            userName = properties.getProperty("mailUsername");
            passWord = properties.getProperty("mailPassword");
            emailForm = properties.getProperty("mailFrom");
            timeout = properties.getProperty("mailTimeout");
            personal = "自动化测试";
        } catch(IOException e){
            e.printStackTrace();
        }
    }
}

（3）封装发送邮件功能


public class MailUtil {
    private static final String HOST = MailConfig.host;
    private static final Integer PORT = MailConfig.port;
    private static final String USERNAME = MailConfig.userName;
    private static final String PASSWORD = MailConfig.passWord;
    private static final String emailForm = MailConfig.emailForm;
    private static final String timeout = MailConfig.timeout;
    private static final String personal = MailConfig.personal;
    private static JavaMailSenderImpl mailSender = createMailSender();
    /**
     * 邮件发送器
     *
     * @return 配置好的工具
     */
    private static JavaMailSenderImpl createMailSender() {
        JavaMailSenderImpl sender = new JavaMailSenderImpl();
        sender.setHost(HOST);
        sender.setPort(PORT);
        sender.setUsername(USERNAME);
        sender.setPassword(PASSWORD);
        sender.setDefaultEncoding("Utf-8");
        Properties p = new Properties();
        p.setProperty("mail.smtp.timeout", timeout);
        p.setProperty("mail.smtp.auth", "false");
        sender.setJavaMailProperties(p);
        return sender;
    }

    /**
     * 发送邮件
     *
     * @param to 接受人
     * @param subject 主题
     * @param html 发送内容
     * @throws MessagingException 异常
     * @throws UnsupportedEncodingException 异常
     */
    public void sendMail(InternetAddress[] to, String subject, String html) throws MessagingException,UnsupportedEncodingException {
        MimeMessage mimeMessage = mailSender.createMimeMessage();
        // 设置utf-8或GBK编码，否则邮件会有乱码
        MimeMessageHelper messageHelper = new MimeMessageHelper(mimeMessage, true, "UTF-8");
        messageHelper.setFrom(emailForm, personal);
        messageHelper.setTo(to);
        messageHelper.setSubject(subject);
        messageHelper.setText(html, false);
        mailSender.send(mimeMessage);
    }
}

3.3 封装dubbo接口信息类

把dubbo接口封装成一个类，方便信息get和set

public class DubboInterfaceInfo {
    private String dubboInterfaceWiki;
    private String dubboInterfacePacketName;
    private String dubboInterfaceClassName;
    private RestRequest request;
    private String responseStatusSuccessful;
    private String responseMessageSuccessful;
    private String dubboInterfaceId;

    public DubboInterfaceInfo() {}

    public String getDubboInterfaceWiki() {
        return this.dubboInterfaceWiki;
    }
    public void setDubboInterfaceWiki(String dubboInterfaceWiki) {
        this.dubboInterfaceWiki = dubboInterfaceWiki;
    }

    public String getDubboInterfacePacketName() {
        return this.dubboInterfacePacketName;
    }
    public void setDubboInterfacePacketName(String dubboInterfacePacketName) {
        this.dubboInterfacePacketName = dubboInterfacePacketName;
    }

    public String getDubboInterfaceClassName() {
        return this.dubboInterfaceClassName;
    }
    public void setDubboInterfaceClassName(String dubboInterfaceClassName) {
        this.dubboInterfaceClassName = dubboInterfaceClassName;
    }

    public RestRequest getRestRequest() {
        return this.request;
    }
    public void setRestRequest(RestRequest request) {
        this.request = request;
    }

    public String getResponseStatusSuccessful() {
        return this.responseStatusSuccessful;
    }
    public void setResponseStatusSuccessful(String responseStatusSuccessful) {
        this.responseStatusSuccessful = responseStatusSuccessful;
    }

    public String getResponseMessageSuccessful() {
        return this.responseMessageSuccessful;
    }
    public void setResponseMessageSuccessful(String responseMessageSuccessful) {
        this.responseMessageSuccessful = responseMessageSuccessful;
    }

    public String getDubboInterfaceId() {
        return this.dubboInterfaceId;
    }
    public void setDubboInterfaceId(String dubboInterfaceId) {
        this.dubboInterfaceId = dubboInterfaceId;
    }
}

3.4 利用Jmeter调用provider服务，并断言，邮件报警

利用Jmeter调用provider服务，并断言，邮件报警，这些功能封装成dubbo接口测试类，代码如下：

public class IPromiseForOrderServiceTest extends AbstractJavaSamplerClient {
    /**
     * CONTEXT
     * 读取dubbo-config.xml中的内容
     */
    private static final ApplicationContext CONTEXT = new ClassPathXmlApplicationContext("dubbo-config.xml");
    public DubboInterfaceInfo dubboInterfaceInfo = new DubboInterfaceInfo();
    public String responseSuccess;
    public String responseFail;
    public FreeStockForOrderParam request;
    /**
     * IPromiseForOrderService
     * 此处需要实例化dubbo接口 IPromiseForOrderService，像定义变量一样实例化
     */
    private static IPromiseForOrderService IPromiseForOrderService;

    /**
     * IPromiseForOrderService
     * 以下方法用于 输入dubbo接口信息
     */
    public void DubboInterfaceInfoInitialization () {
        dubboInterfaceInfo.setDubboInterfaceWiki("......");
        dubboInterfaceInfo.setDubboInterfacePacketName("......");
        dubboInterfaceInfo.setDubboInterfaceClassName("......");
        dubboInterfaceInfo.setDubboInterfaceId("......");
        dubboInterfaceInfo.setResponseStatusSuccessful("0");
        dubboInterfaceInfo.setResponseMessageSuccessful("success");
        String orderNo = "orderNo";
        String operater="";
        String channel="";
        String operateId="operateId";
        String version= PromiseVersion.V_1_0_0.getVersion();
        request = new FreeStockForOrderParam();
        if (orderNo != null || orderNo.length() > 0) {
            request.setOrderNo(orderNo);
        }
        if (operater != null || operater.length() > 0) {
            request.setOperater(operater);
        }
        if (channel != null || channel.length() > 0) {
            request.setChannel(channel);
        }
        if (operateId != null || operateId.length() > 0) {
            request.setOperateId(operateId);
        }
        if (version != null || version.length() > 0) {
            request.setVersion(version);
        }
        RestRequest<FreeStockForOrderParam> req = new RestRequest<FreeStockForOrderParam>();
        req.setRequest(request);
        dubboInterfaceInfo.setRestRequest(req);
    }


    @Override
    public void setupTest(JavaSamplerContext arg0){
        IPromiseForOrderService=(IPromiseForOrderService)CONTEXT.getBean("......");
    }

    @Override
    public SampleResult runTest(JavaSamplerContext javaSamplerContext) {
        SampleResult sr = new SampleResult();

        try {
            sr.sampleStart();
            RestResponse responseData = IPromiseForOrderService.freeSaleStock(dubboInterfaceInfo.getRestRequest());
//自定义dubbo调用成功和失败的邮件正文内容
            responseSuccess =
                             "dubbo接口: "
                                     + dubboInterfaceInfo.getDubboInterfaceId() + "请求成功\r\n"
                                     + "WIKI地址: " + dubboInterfaceInfo.getDubboInterfaceWiki() + "\r\n"
                                     + "PacketName: " + dubboInterfaceInfo.getDubboInterfacePacketName() + "\r\n"
                                     + "ClassName: " + dubboInterfaceInfo.getDubboInterfaceClassName() + "\r\n"
                                    ;
            responseFail =
                    "dubbo接口: " + dubboInterfaceInfo.getDubboInterfaceId() + "请求失败\r\n"
                            + "WIKI地址: " + dubboInterfaceInfo.getDubboInterfaceWiki() + "\r\n"
                            + "PacketName: " + dubboInterfaceInfo.getDubboInterfacePacketName() + "\r\n"
                            + "ClassName" + dubboInterfaceInfo.getDubboInterfaceClassName() + "\r\n"
                            + "请求参数为：Channel: " + request.getChannel() +
                                            " / operater: " + request.getOperater() +
                                            " / OperateId: " + request.getOperateId() +
                                            " / OrderNo: " + request.getOrderNo() +
                                            " / Version: " + request.getVersion()
                            + "\r\n"
                            + "返回结果为："
                            + "ResponseStatus: " + responseData.getStatus()
                            + " / ResponseMessage: " + responseData.getMessage()
                            + " / ResponseResult: " + responseData.getResult();


            /**
             * 邮件定义及发送
             */
            InternetAddress[] address = new InternetAddress[2];
            try {
                address[0] = new InternetAddress("lalllalala@qq.com");
                address[1] = new InternetAddress("3456789@qq.com");
            } catch (AddressException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
            MailUtil mailUtil = new MailUtil();

            if ((dubboInterfaceInfo.getResponseStatusSuccessful().equals(responseData.getStatus())) && (dubboInterfaceInfo.getResponseMessageSuccessful().equals(responseData.getMessage()))) {
                sr.setSuccessful(true);
                sr.setResponseData("responseData: " + responseData, "utf-8");
                System.out.println(responseSuccess);
                mailUtil.sendMail(address,"dubbo接口：" + dubboInterfaceInfo.getDubboInterfaceId() + "请求成功",responseSuccess.toString());

            } else {
                sr.setSuccessful(false);
                System.out.println(responseFail);
                mailUtil.sendMail(address,"dubbo接口：" + dubboInterfaceInfo.getDubboInterfaceId() + "请求失败",responseFail.toString());
            }

            sr.sampleEnd();
        } catch (Exception e) {
            e.printStackTrace();
        }

        return sr;
    }


}

3.5 利用testng注释，调用dubbo接口类，进行测试

public class TestngTest {
    @Test()
    public void testDubboInterface() {
        JavaSamplerContext arg0 = new JavaSamplerContext(new Arguments());

        dubbo接口测试类 TestForIPromiseForOrderService = new dubbo接口测试类();
        TestForIPromiseForOrderService.DubboInterfaceInfoInitialization();
        TestForIPromiseForOrderService.setupTest(arg0);
        SampleResult sr = TestForIPromiseForOrderService.runTest(arg0);
    }
}

4、利用jenkins自动化运行dubbo测试项目



至此，大功告成，你可以完成dubbo接口自动化测试了

备注：接下来将会加入关联、测试数据分离等功能，让框架变得更加易用。