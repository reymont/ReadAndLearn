Ant+Jmeter搭建测试环境 - CSDN博客 http://blog.csdn.net/u011881908/article/details/52242336

准备搭建Jenkins+Ant+Jmeter这样一个自动化测试环境。考虑到一口不能吃个胖子，因此先从Ant+Jmeter开始。以下是Ant+Jmeter搭建的步骤：

1、首先确保测试机器中已经按照jdk1.6以上版本，如果没有，那就上官网下载吧。 
2、下载Ant，解压至指定目录，并配置好环境变量：http://ant.apache.org/ 
在命令行下执行ant -v可验证安装是否成功： 
这里写图片描述 
3、下载并安装jmeter（尽量与ant在同一个目录下）：http://jmeter.apache.org/ 
4、将 jmeter的extras目录中ant-jmeter-1.1.1.jar包拷贝至ant安装目录下的lib目录中 
5、修改Jmeter的bin目录下jmeter.properties文件的配置：jmeter.save.saveservice.output_format=xml 
6、在指定的工作目录下创建jmeter脚本保存的目录，并在其中创建一个build.xml文件

这里写图片描述

wsview目录中保存的是jmeter脚本以及运行脚本要用到的其他资源文件 
这里写图片描述

## 7、build.xml文件内容如下：

```xml
<?xml version="1.0" encoding="UTF-8"?>

<project name="ant-jmeter-test" default="run" basedir=".">
    <tstamp>
        <format property="time" pattern="yyyyMMddhhmm" />
    </tstamp>
    <!-- 需要改成自己本地的jmeter目录-->  
    <property name="jmeter.home" value="G:\TestTools\java\apache-jmeter-2.13" />
    <!-- jmeter生成的jtl格式的结果报告的路径--> 
    <property name="jmeter.result.jtl.dir" value="G:\TestTools\java\apache-jmeter-2.13\mytest\wsview\report\jti" />
    <!-- jmeter生成的html格式的结果报告的路径-->
    <property name="jmeter.result.html.dir" value="G:\TestTools\java\apache-jmeter-2.13\mytest\wsview\report\html" />
    <!-- ʺ生成的报告的前缀-->  
    <property name="ReportName" value="TestReport" />
    <property name="jmeter.result.jtlName" value="${jmeter.result.jtl.dir}/${ReportName}${time}.jtl" />
    <property name="jmeter.result.htmlName" value="${jmeter.result.html.dir}/${ReportName}${time}.html" />

    <target name="run">
        <antcall target="test" />
        <antcall target="report" />
    </target>

    <target name="test">
        <taskdef name="jmeter" classname="org.programmerplanet.ant.taskdefs.jmeter.JMeterTask" />
        <jmeter jmeterhome="${jmeter.home}" resultlog="${jmeter.result.jtlName}">
             <!-- 声明要运行的脚本“*.jmx”指包含此目录下的所有jmeter脚本-->
            <testplans dir="G:\TestTools\java\apache-jmeter-2.13\mytest\wsview" includes="*.jmx" />

           <property name="jmeter.save.saveservice.output_format" value="xml"/>

        </jmeter>
    </target>
    <path id="xslt.classpath">
            <fileset dir="${jmeter.home}/lib" includes="xalan*.jar"/>
            <fileset dir="${jmeter.home}/lib" includes="serializer*.jar"/>
    </path>

    <target name="report">
        <tstamp> 
                <format property="report.datestamp" pattern="yyyy/MM/dd HH:mm" />
        </tstamp>
        <xslt 
            classpathref="xslt.classpath"
            force="true"
            in="${jmeter.result.jtlName}"
            out="${jmeter.result.htmlName}"
            style="${jmeter.home}/extras/jmeter-results-detail-report_21.xsl">
            <param name="dateReport" expression="${report.datestamp}"/>
        </xslt>
        <!-- 拷贝报告所需的图片资源至目标目录 --> 
        <copy todir="${jmeter.result.html.dir}">
            <fileset dir="${jmeter.home}/extras">
                <include name="collapse.png" />
                <include name="expand.png" />
            </fileset>
        </copy>
    </target>
</project>
```
8、执行测试 
通过cmd进入build.xml所在的工作目录，输入ant，测试开始执行，如下： 
这里写图片描述

9、测试报告 
这里写图片描述

版权声明：本文为博主原创文章，未经博主允许不得转载。 //blog.csdn.net/u011881908/article/details/52242336