

# Hudson插件开发入门体验 - CSDN博客 
http://blog.csdn.net/lmtahoe/article/details/44946673

持续集成（CI）将软件项目流程的各个阶段进行自动化部署，从build, deploy, test automation到coverage分析，全部实现自动完成，而不需要每天的手工操作。
在敏捷开发过程中，持续集成大大提高了团队的工作效率，开发和测试人员可以专注于代码与测试用例的编写，而不需要过多关注编译和部署。每天夜晚进行持续集成的自动化部署，第二天可以马上开始测试和分析前日的测试效果与代码覆盖率，和敏捷开发的理念结合的恰到好处。
下面我就来介绍下如何开发一个Hudson的插件。

首先你要有Maven 2和JDK1.6以上，这是必须的。然后在你的Maven 2的setting.xml 文件中加入下列代码 
```xml
 <pluginGroups>  
<pluginGroup>org.jvnet.hudson.tools</pluginGroup>    
 </pluginGroups>  
  
 <profiles>  
<profile>    
   <id>hudson</id>    
   
   <activation>    
     <activeByDefault />    
   </activation>    
   
   <pluginRepositories>    
     <pluginRepository>    
       <id>m.g.o-public</id>    
       <url>http://maven.glassfish.org/content/groups/public/</url>    
     </pluginRepository>    
   </pluginRepositories>    
   <repositories>    
     <repository>    
       <id>m.g.o-public</id>    
       <url>http://maven.glassfish.org/content/groups/public/</url>    
     </repository>    
   </repositories>    
 </profile>   
 </profiles>  
  
 <activeProfiles>   
<activeProfile>hudson</activeProfile>  
 </activeProfiles>   
```
  
这样会将你的Maven指向有着Hudson-related Maven plugins的仓库，而且允许你使用Hudson Maven plugins的短名字来调用相关的插件(例如:hpi:create 代替org.jvnet.hudson.tools:maven-hpi-plugin:1.23:create)。 

接着在CMD中输入 

mvn hpi:create  
之后会问你一些如groupId和artifactId之类的问题，groupId填写成你一般开发java代码的package信息，例如com.webex.slim.hudsonplugin，artifactId则是你编写此hudson插件的名称，例如buildslim。 

完成后计算机会自动的创建了一个项目，里面有一些模板代码，可供你学习如何开始写一个Hudson的插件，后面的代码全部来自模版代码。如果你需要在Eclipse里编辑插件可以执行  

mvn -DdownloadSources=true eclipse:eclipse  
然后你就可以在Eclipse中导入这个项目并开始开发了。Eclipse导入maven工程，需要安装maven插件，然后在工程里选择导入已有项目即可。
 
执行前面的maven命令后，在我们的指定目录下已经生成了一个Hudson 插件的项目文件夹，这个目录应该是~/artifactId/。在Eclipse中导入这个项目，我们可以看见项目有如下的结构： 


+ src   
    + main   
        + java   
             +  full.package.name   
                    +- HelloWorldBuilder.java   
+resources   
             +  full.package.name   
                    +- config.jelly   
                    +- global.jelly   
                +- index.jelly   
        + webapp   
            +- help-globalConfig.html   
            +- help-projectConfig.html   

 HelloWorldBuilder.java 
这个类就是具体实现某一扩展点的一个类，在这里由于要扩展Builder这个扩展点，所以继承了 Builder 这个类。在Hudson 中有很多不同种类的扩展点，比如Publisher、Recorder 等等。详细的说明可以参考Hudson 的网站。 

建好工程后，已经有一些代码是maven自动生成的hudson插件示例代码。

下面我来逐步分析这些代码 
```java
@DataBoundConstructor     
public HelloWorldBuilder(String name) {     
    this.name = name;     
}     
  
/**   
 * We'll use this from the <tt>config.jelly</tt>.   
 */     
public String getName() {     
    return name;     
}    
```

这段代码用于构造这个Bulider并且从相应的config.jelly中获取相应的参数。Hudson使用了一种叫structured form submission的技术，使得可以使用这种方式活动相应的参数。 
```java
public boolean perform(Build build, Launcher launcher, BuildListener listener) {     
     // this is where you 'build' the project     
     // since this is a dummy, we just say 'hello world' and call that a build     
  
     // this also shows how you can consult the global configuration of the builder     
     if(DESCRIPTOR.useFrench())     
         listener.getLogger().println("Bonjour, "+name+"!");     
     else     
         listener.getLogger().println("Hello, "+name+"!");     
    return true;     
}     
```


方法perform（）是个很重要的方法，当插件运行的的时候这个方法会被调用。相应的业务逻辑也可以在这里实现。比如这个perform（）方法就实现了怎么说　“Hello” 

接下来，在HelloBuilder 这个类里面有一个叫 DescriptorImpl 的内部类，它继承了Descriptor。在Hudson 的官方说明文档里说Descriptor包含了一个配置实例的元数据。打个比方，我们在工程配置那里对插件进行了配置，这样就相当于创建了一个插脚的实例，这时候就需要一个类来存储插件的配置数据，这个类就是Descriptor。 
 
```java
public String getDisplayName() {     
    return "Say hello world";     
}
```     
如上面的代码，可以在Descriptor的这个方法下设置插件在工程配置页面下现实的名字 


public boolean configure(StaplerRequest req, JSONObject o) throws FormException {     
     // to persist global configuration information,     
     // set that to properties and call save().     
     useFrench = o.getBoolean("useFrench");     
     save();     
     return super.configure(req);     
}    
如同注释属所说，这个方法用于将全局配置存储到项目中 
 
注意点：
HUDSON_HOME：
Hudson需要一个位置来进行每次构建，保留相关的配置信息，以及保存测试的结果，这就是在部署好了Hudson环境以后，系统就会自动在当前用户下新建一个.hudson，在linux下如：~/.hudson，我们有三种方式来改变这个路径：
1.  在启动servlet容器之前，设置：“HUDSON_HOME”环境变量，指向你需要设定的目录
2.  在servlet容器之中，设定系统属性
3.  设置一个JNDI的环境实体<env-entry>“HUDSON_HOME”指向您所想要设定的目录
目前我们在glassfish中设置jvm-option的方式属于第二种。
当我们设置好这个变量以后想要换个目录，但又不想丢掉以前的配置怎么办，很简单，关闭Hudson，将目录A的内容拷贝的目录B中去，然后重新设定“HUDSON_HOME”的值，然后重启，你会发现之前你所作的所有配置都完好的保留了下来
1、Hudson-home的目录结构：
HUDSON_HOME
 +- config.xml     (hudson的基本配置文件，如：jdk的安装路径)
 +- *.xml          (其他系统相关的配置文件，比如：旺旺插件的全局配置信息)
 +- fingerprints   (储存文件版本跟踪记录信息)
 +- plugins        (存放插件)
 +- jobs
     +- [JOBNAME]      (任务名称，对应页面上的project name)
         +- config.xml     (任务配置文件，类似于CC的config.xml中各个项目的配置)
         +- workspace      (SCM所用到的目录，hudson所下载代码默认存放在这个目录)
         +- builds
             +- [BUILD_ID]     (每一次构建的序号)
                 +- build.xml      (构建结果汇总)
                 +- log            (运行日志)
                 +- changelog.xml  (SCM修改日志)
小提示：如果你使用了e-mail来接受测试消息，并且hudson的迁移设计到不同ip地址机器的迁移的话，可能需要去Hudson的主配置中修改一下Hudson的访问地址
workspace：
刚才在hudson-home的目录结构中已经看到了workspce，假设当前hudson-home为/home/hudson-home，那么当我们在hudson上配置一个项目demo的时候，就会在新建一个目录/home/hudson-home/demo，在第一次运行之前，在jobs下并没有demo这个文件夹,只有当第一次运行以后才会在jobs目录下创建demo目录，当代码顺利从svn上下载下来时才会创建workspace文件夹，所有从svn下载下来的代码都会存放在这个目录下。
1、相对路径：
项目配置过程中，Hudson使用的是相对路径，对于Hudson，在我们新建一个项目比如demo后，假设workspace的目录结构为：
workspace
 +- demo
     +- pom.xml
     +- src
那么测试报告的路径就为demo/target/surefire-reports/*.xml,系统会自动去当前项目的workspace中去寻找这个路径
 
mvn package  -- 完成代码开发之后执行，按照pom.xml 中的配置信息将会打包为hpi 格式的插件文件，这个就是你最终可以拿来上传给你的hudson 平台的玩意
mvn hpi:run   -- 在本地的Jetty 中运行你的hudson 插件，调试专用，当然可以使用Debug 模式，执行之后，在本地访问http://localhost:8080/ 即可见（注意不要占用8080 端口）
mvnDebug hup:run ，debug调试模式

下面贴出一个我自己写的用于项目构建，自动编译打包的Hudson插件源代码。
HelloWorldBuilder.java
```java
package zygroup;  
import hudson.FilePath;  
import hudson.Launcher;  
import hudson.Extension;  
import hudson.Proc;  
import hudson.util.FormValidation;  
import hudson.model.AbstractBuild;  
import hudson.model.BuildListener;  
import hudson.model.AbstractProject;  
import hudson.remoting.Channel;  
import hudson.tasks.Builder;  
import hudson.tasks.BuildStepDescriptor;  
import net.sf.json.JSONObject;  
import org.kohsuke.stapler.DataBoundConstructor;  
import org.kohsuke.stapler.StaplerRequest;  
import org.kohsuke.stapler.QueryParameter;  
  
import javax.servlet.ServletException;  
import java.io.IOException;  
  
  
public class HelloWorldBuilder extends Builder {  
  
    private final String locate;  
    private final String cmd;  
  
    // Fields in config.jelly must match the parameter names in the "DataBoundConstructor"  
    @DataBoundConstructor  
    public HelloWorldBuilder(String locate, String cmd) {  
        this.locate = locate;  
        this.cmd = cmd;  
    }  
  
    /** 
     * We'll use this from the <tt>config.jelly</tt>. 
     */  
    public String getLocate() {  
        return locate;  
    }  
  
    public String getCmd() {  
        return cmd;  
    }  
      
    @Override  
    public boolean perform(AbstractBuild build, Launcher launcher, BuildListener listener) {  
        listener.getLogger().println("The SLiM build home is "+locate+".");  
        listener.getLogger().println("The SLiM build command is "+cmd+".");  
           
        try {  
            FilePath path = new FilePath(Channel.current(),locate);  
            Proc proc = launcher.launch(cmd, build.getEnvVars(), listener.getLogger(),path);  
            int exitCode = proc.join();  
            if (exitCode != 0) return false;  
  
            return true;  
          } catch (IOException e) {  
            e.printStackTrace();  
            listener.getLogger().println("IOException !");  
            return false;  
          } catch (InterruptedException e) {  
            e.printStackTrace();  
            listener.getLogger().println("InterruptedException!");  
            return false;  
          }  
    }  
  
    @Override  
    public DescriptorImpl getDescriptor() {  
        return (DescriptorImpl)super.getDescriptor();  
    }  
  
    @Extension // this marker indicates Hudson that this is an implementation of an extension point.  
    public static final class DescriptorImpl extends BuildStepDescriptor<Builder> {  
  
        public FormValidation doCheckName(@QueryParameter String value) throws IOException, ServletException {  
            if(value.length()==0)  
                return FormValidation.error("Please set a name");  
            if(value.length()<4)  
                return FormValidation.warning("Isn't the name too short?");  
            return FormValidation.ok();  
        }  
  
        public boolean isApplicable(Class<? extends AbstractProject> aClass) {  
            // indicates that this builder can be used with all kinds of project types   
            return true;  
        }  
  
        public String getDisplayName() {  
            return "SLiM build";  
        }  
  
        @Override  
        public boolean configure(StaplerRequest req, JSONObject formData) throws FormException {  
            save();  
            return super.configure(req,formData);  
        }  
  
  
    }  
} 
```
设置插件相关的用户输入页面的文件config.jelly

<j:jelly xmlns:j="jelly:core" xmlns:st="jelly:stapler" xmlns:d="jelly:define" xmlns:l="/lib/layout" xmlns:t="/lib/hudson" xmlns:f="/lib/form">  
  <!--  
    This jelly script is used for per-project configuration.  
  
    See global.jelly for a general discussion about jelly script.  
  -->  
  
  <!--  
    Creates a text field that shows the value of the "name" property.  
    When submitted, it will be passed to the corresponding constructor parameter.  
  -->  
  <f:entry title="Build Home" help="plugin/zyartifact/WEB-INF/classes/zygroup/HelloWorldBuilder/help-buildhome.html">  
    <f:textbox name="locate" type="text" value="${instance.locate}"/>  
  </f:entry>  
   <f:entry title="Build Command" help="plugin/zyartifact/WEB-INF/classes/zygroup/HelloWorldBuilder/help-cmd.html">  
    <f:textbox name="cmd" type="text" value="${instance.cmd}"/>  
  </f:entry>  
</j:jelly>  

其中<f:entry>的help属性指向了一个html文件，位于代码中设置的位置下，可以写入标准的html标记，用于在此输入框右边显示帮助按钮和点出帮助信息。
该插件的主要输入内容是：
locate和cmd两个字符串，传递给build程序使用，成为locate和cmd两个变量。用于用户输入构建代码的目录和需要启动构建的命令。
例如
/opt/CruiseControl/apache-ant-1.7.0/
ant antbuild

build程序得到这两个变量后，就启动shell并在locate目录下执行cmd命令。这个功能在perform函数中实现。

 public boolean perform(AbstractBuild build, Launcher launcher, BuildListener listener) {  
  
/向hudson运行控制台输出日志信息  
     listener.getLogger().println("The SLiM build home is "+locate+".");  
     listener.getLogger().println("The SLiM build command is "+cmd+".");  
        
     try {  
//将locate字符串转化为hudson的FilePath类型  
        FilePath path = new FilePath(Channel.current(),locate);  
  
//在path路径下执行cmd命令  
         Proc proc = launcher.launch(cmd, build.getEnvVars(), listener.getLogger(),path);  
  
//如果shell结果为失败，则返回失败  
         int exitCode = proc.join();  
         if (exitCode != 0) return false;  
  
//返回成功  
         return true;  
       } catch (IOException e) {  
    ......  
       }  
 }  

然后在windows的cmd或者linux的控制台中该项目目录下，键入mvn package，即可自动生成target目录下的文件，包括一个hpi文件和jar文件。
将hpi拷贝到hudson目录的plugin目录下，或者通过hudson的页面上传插件，重启hudson，即可使用。
这个插件是一个build类型的插件，会在hudson的job配置页面，出现在build step下拉菜单中，名字由HelloWorldBuilder.java的下面一个函数控制：

public String getDisplayName() {  
    return "SLiM build";  
}  

插件在hudson已安装插件列表中显示的名字，由该maven项目的poe.xml配置：

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">  
      
    <modelVersion>4.0.0</modelVersion>  
  
    <parent>  
        <groupId>org.jvnet.hudson.plugins</groupId>  
        <artifactId>hudson-plugin-parent</artifactId>  
        <version>2.1.1</version><!-- which version of Hudson is this plugin built against? -->  
    </parent>  
  
    <groupId>zygroup</groupId>  
    <artifactId>zyartifact</artifactId>  
    <version>1.0-SNAPSHOT</version>  
  
    <packaging>hpi</packaging>  
  
    <name>SLiM build</name>  
  
</project>  
```
这样一个实现项目自动构建的简单插件就可以使用了^.^