
* [Apache log4net – Apache log4net: Home - Apache log4net ](http://logging.apache.org/log4net/)

# VS2012 C#使用/配置Log4Net

* [VS2012 C#使用/配置Log4Net - 天才卧龙 - 博客园 ](http://www.cnblogs.com/chenwolong/p/log4net.html)

最近悟出来一个道理，在这儿分享给大家：学历代表你的过去，能力代表你的现在，学习代表你的将来。

十年河东十年河西，莫欺少年穷

学无止境，精益求精  

本节探讨如何在VS2012中使用Log4Net

1、首先在项目中添加Nuget程序包...



 2、然后在NuGet窗体中搜索Log4Net，然后点击安装<安装过程可能会持续几分钟，请耐心等待>



3、在项目中添加一个Config文件，并命名为：Log4Net.config



截图中配置的XML代码如下：

```xml
<log4net>
  <logger name="logerror">
    <level value="ERROR" />
    <appender-ref ref="ErrorAppender" />
  </logger>
  <logger name="loginfo">
    <level value="INFO" />
    <appender-ref ref="InfoAppender" />
  </logger>
  <appender name="ErrorAppender" type="log4net.Appender.RollingFileAppender">
    <param name="File" value="Log\\LogError\\" />
    <param name="AppendToFile" value="true" />
    <param name="MaxSizeRollBackups" value="100" />
    <param name="MaxFileSize" value="10240" />
    <param name="StaticLogFileName" value="false" />
    <param name="DatePattern" value="yyyyMMdd&quot;.txt&quot;" />
    <param name="RollingStyle" value="Date" />
    <layout type="log4net.Layout.PatternLayout">
      <param name="ConversionPattern" value="&lt;HR COLOR=red&gt;%n异常时间：%d [%t] &lt;BR&gt;%n异常级别：%-5p &#xD;&#xA;   &lt;BR&gt;%n异 常 类：%c [%x] &lt;BR&gt;%n%m &lt;BR&gt;%n &lt;HR Size=1&gt;" />
    </layout>
  </appender>
  <appender name="InfoAppender" type="log4net.Appender.RollingFileAppender">
    <param name="File" value="Log\\LogInfo\\" />
    <param name="AppendToFile" value="true" />
    <param name="MaxFileSize" value="10240" />
    <param name="MaxSizeRollBackups" value="100" />
    <param name="StaticLogFileName" value="false" />
    <param name="DatePattern" value="yyyyMMdd&quot;.txt&quot;" />
    <param name="RollingStyle" value="Date" />
    <layout type="log4net.Layout.PatternLayout">
      <param name="ConversionPattern" value="&lt;HR COLOR=blue&gt;%n日志时间：%d [%t] &lt;BR&gt;%n日志级别：%-5p &#xD;&#xA;   &lt;BR&gt;%n日 志 类：%c [%x] &lt;BR&gt;%n%m &lt;BR&gt;%n &lt;HR Size=1&gt;" />
    </layout>
  </appender>
</log4net>
```
最后在项目的 AssemblyInfo.cs 文件中注册Config文件，如下：


```xml
#为项目注册Log4Net.config配置文件
[assembly: log4net.Config.DOMConfigurator(ConfigFile = "Log4Net.config", Watch = true)]
```
最后，添加日志类：

```cs
 public class LogHelper
    {
        private LogHelper()
        {
        }

        public static readonly log4net.ILog loginfo = log4net.LogManager.GetLogger("loginfo");

        public static readonly log4net.ILog logerror = log4net.LogManager.GetLogger("logerror");

        public static void SetConfig()
        {
            log4net.Config.DOMConfigurator.Configure();
        }

        public static void SetConfig(FileInfo configFile)
        {
            log4net.Config.DOMConfigurator.Configure(configFile); 
        }

        public static void WriteLog(string info)
        {
            if(loginfo.IsInfoEnabled)
            {
                loginfo.Info(info);
            }
        }

        public static void WriteLog(string info,Exception se)
        {
            if(logerror.IsErrorEnabled)
            {
                logerror.Error(info,se);
            }
        }
    }
```
好了，到了这里，准备工作也就完成了，下面我们就开始测试下吧<为了简单，直接在日志文件中写一句话>

首先引用：using log4net;

然后：

```cs
    public partial class index : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            LogHelper.WriteLog("陈卧龙是个大坏蛋");
        }
    }
```
最后，我们在项目中显示所有文件，你会发现有个Log文件夹，如下：



我们打开LogInfo文件夹下20161220.txt便会看到我们打印的信息



当然，您的代码也可以这样写：

```cs
        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                //todo
            }
            catch(Exception ex)
            {
                LogHelper.WriteLog("被除数为零，呃呃呃，小学数学没学好！", ex);
            }
        }
```
在todo过程中一旦发生异常就会执行Catch()语段，这时会在LogError文件夹中的文件中写入日志。

 好了，Log4Net还有一些用法，在此不作举例了！

```cs
        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                //todo
                LogHelper.loginfo.Warn("警告消息");
                LogHelper.logerror.Warn("错误警告信息");
            }
            catch(Exception ex)
            {
                LogHelper.WriteLog("被除数为零，呃呃呃，小学数学没学好！", ex);
            }
        }
```
等等吧！

如果您觉得还可以，就点个赞吧！谢谢！

@陈卧龙的博客


# Log4net入门使用

* [Log4net入门使用 - jiangys - 博客园 ](http://www.cnblogs.com/jys509/p/4569874.html)

```xml
<?xml version="1.0" encoding="utf-8" ?>
<configuration>
  <configSections>
    <section name="log4net" type="log4net.Config.Log4NetConfigurationSectionHandler, log4net"/>
  </configSections>
  
  <log4net>
    <appender name="RollingLogFileAppender" type="log4net.Appender.RollingFileAppender">
      <!--日志路径-->
      <param name= "File" value= "Log\\"/>
      <!--是否是向文件中追加日志-->
      <param name= "AppendToFile" value= "true"/>
      <!--log保留天数-->
      <param name= "MaxSizeRollBackups" value= "10"/>
      <!--日志文件名是否是固定不变的-->
      <param name= "StaticLogFileName" value= "false"/>
      <!--日志文件名格式为:2008-08-31.log-->
      <param name= "DatePattern" value= "yyyy-MM-dd&quot;.log&quot;"/>
      <!--日志根据日期滚动-->
      <param name= "RollingStyle" value= "Date"/>
      <layout type="log4net.Layout.PatternLayout">
        <param name="ConversionPattern" value="%d [%t] %-5p %c - %m%n %loggername" />
      </layout>
    </appender>
    
    <!-- 控制台前台显示日志 -->
    <appender name="ColoredConsoleAppender" type="log4net.Appender.ColoredConsoleAppender">
      <mapping>
        <level value="ERROR" />
        <foreColor value="Red, HighIntensity" />
      </mapping>
      <mapping>
        <level value="Info" />
        <foreColor value="Green" />
      </mapping>
      <layout type="log4net.Layout.PatternLayout">
        <conversionPattern value="%n%date{HH:mm:ss,fff} [%-5level] %m" />
      </layout>

      <filter type="log4net.Filter.LevelRangeFilter">
        <param name="LevelMin" value="Info" />
        <param name="LevelMax" value="Fatal" />
      </filter>
    </appender>

    <root>
      <!--(高) OFF > FATAL > ERROR > WARN > INFO > DEBUG > ALL (低) -->
      <level value="all" />
      <appender-ref ref="ColoredConsoleAppender"/>
      <appender-ref ref="RollingLogFileAppender"/>
    </root>
  </log4net>
</configuration>
```