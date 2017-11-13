

Jenkins插件编写入门 - CSDN博客
 http://blog.csdn.net/kittyboy0001/article/details/18710111

# 一，Jenkins插件的结构
Jenkins插件实际上是一个按照一定规则组织的jar包，其结构如下：
xxx.hpi
+- META-INF
|   +-MANIFEST.MF
+- WEB-INF
|   +- classes
|       +- index.jelly
|       +- XXXX.class
|   +- lib
+-  (static resources)
说明：
1.插件的后缀为".hpi",文件名（xxx部分）是插件的简写名字，用来区分插件。
2.如上图结构所示，它与war包类似，只是缺少web.xml。
3.MANIFEST.MF包含一些入口的配置信息。其中有继承自Jenkins插件的类，用作实例化的入口。类的全名，用作我们去区分其他插件。
4.WEB-INF/classes 用来包含插件需要的.class，jelly页面等内容。它们可以封装成jar包放到WEB-INF/lib下面
5.WEB-INF/lib 包含插件中需要的.jar文件
6.插件需要的静态文件如图片，HTML，css样式文件，JS文件等可以放到文件的根目录下面。
# 二，Jenkins-Plugins的开发
Jenkins插件的开发，使用maven来进行项目的管理和构建。如下罗列了其中需要的步骤。
2.1 Jenkins插件开发时的环境配置
Jenkins插件开发，需要JDK和Maven环境。下面以windows下的环境配置为例说明。
2.1.1 JDK配置
JDK的版本要求在1.6以上，需要在配置文件中配置JDK的变量：
JAVA_HOME = C:\Program Files (x86)\Java\jdk1.6.0_38   
CLASSPATH = ...;%JAVA_HOME%\bin;%JAVA_HOME%\jre\bin;   
PATH = ...;%JAVA_HOME%\bin;%JAVA_HOME%\jre\bin;   
2.1.2 Maven的配置
M2_HOME =  D:\maven
M2 = %M2_HOME%\bin
MAVEN_OPTS  = -Xms256m -Xmx512m

CLASSPATH = ...;%M2%   
PATH = ...;%M2%   
可以通过mvn --version,查看maven是否配置成功。
2.1.3 Maven开发环境的配置
在~/.m2/settings.xml中，或者/maven/conf/settings.xml中，配置如下的Jenkins库依赖：
```xml
<settings>
  <pluginGroups>
    <pluginGroup>org.jenkins-ci.tools</pluginGroup>
  </pluginGroups>

  <profiles>
    <!-- Give access to Jenkins plugins -->
    <profile>
      <id>jenkins</id>
      <activation>
        <activeByDefault>true</activeByDefault> <!-- change this to false, if you don't like to have it on per default -->
      </activation>
      <repositories>
        <repository>
          <id>repo.jenkins-ci.org</id>
          <url>http://repo.jenkins-ci.org/public/</url>
        </repository>
      </repositories>
      <pluginRepositories>
        <pluginRepository>
          <id>repo.jenkins-ci.org</id>
          <url>http://repo.jenkins-ci.org/public/</url>
        </pluginRepository>
      </pluginRepositories>
    </profile>
  </profiles>
  <mirrors>
    <mirror>
      <id>repo.jenkins-ci.org</id>
      <url>http://repo.jenkins-ci.org/public/</url>
      <mirrorOf>m.g.o-public</mirrorOf>
    </mirror>
  </mirrors>
</settings>
```
2.2 生成插件的框架程序
配置好maven后，即可使用maven命令建立插件的框架，并且命令行会提示你输入groupId和artifactId：
mvn hpi:create

Enter the groupId of your plugin: com.baidu.ite.hudson
Enter the artifactId of your plugin: samplePlugin
这样会建立一个工程，名字为samplePlugin,包路径com.baidu.ite.hudson。
或者使用如下的命令：
mvn -U org.jenkins-ci.tools:maven-hpi-plugin:create -DgroupId={your.gound.id} -DartifactId={your.plugin.id}
说明：
1，-u代表jenkins需要更新自己所有的插件内容。
2，jenkins中提供的archetype-resources，文件的名字为HelloWorldBuilder.java。我们需要手工修改成自己需要的内容。
2.2.1 代码结构
使用 hpi:create生成的文件结构如下：
+- src 
|   +- main 
|   |   +- java
|   |   |   +- groupId.HelloWorldBuilder.java 
|   |   +- resources 
|   |   |   +-  groupId.HelloWorldBuilder
|   |   |   |   +- config.jelly
|   |   |   |   +- help-name.html 
|   |   |   +- index.jelly 
Jenkins定义了一些扩展点（Extension Points）,这些扩展点是接口或者抽象类。你可以根据自己的需要来修改文件的名字和扩展点。我们使用命令生成的框架程序中，HelloWorldBuilder继承了Builder。
2.2.2 代码的解释
数据的绑定：   

<!--config.jelly-->
<f:entry title="Name" field="name">
    <f:textbox />
</f:entry>

//--HelloWorldBuilder.java--
@DataBoundConstructor
public HelloWorldBuilder(String name) {
    this.name = name;
}
首先，在config.jelly中包含需要传入的参数配置信息的文本框，field为name，这样可以在Jenkins中进行配置，然后通过DataBoundConstructor的方式，传到类中。
Jenkins插件任务的执行

@Override
public boolean perform(AbstractBuild build, Launcher launcher, BuildListener listener) {
    // This is where you 'build' the project.

    // This also shows how you can consult the global configuration of the builder
        listener.getLogger().println("Hello, "+name+"!");
    return true;
}
根据注释可以了解：该处是你在Job进行构建时进行操作的地方，并且这里可以根据你在配置中的设置执行你需要的工作。通常，根据需要修改perform函数即可。
传入数据的检查

 public FormValidation doCheckName(@QueryParameter String value)
                throws IOException, ServletException {
            if (value.length() == 0)
                return FormValidation.error("Please set a name");
            if (value.length() < 4)
                return FormValidation.warning("Isn't the name too short?");
            return FormValidation.ok();
        }
在该函数中，实现在配置页面中填写内容时，进行校验的过程。如函数所述，当填入内容为空时，提示：Please set a name。你可以根据你的需要进行逻辑的控制。
2.3 转换为eclipse工程
为了便于在编辑器中进行修改，我们需要将生成的maven代码转化为eclipse工程，使用的命令如下：
mvn eclipse:eclipse
或者
mvn -DdownloadSources=true -DdownloadJavadocs=true -DoutputDirectory=target/eclipse-classes eclipse:eclipse
第二条较长的命令中，参数是可选的。
## 2.4 生成hpi文件
使用如下命令可以生成./target/pluginname.hpi:
mvn install
或者
mvn package 
其中mvn install 生成hpi文件，并放置到本地maven仓库中，mvn package只进行打包操作。

## 2.5 使用.hpl进行调试
maven中使用.hpl（hudson plugin link）格式来进行插件的调试。hpl文件中只包含一个链接，链接到类似META-INF/MANIFEST.MF的说明文件../path/to/your/plugin/workspace/manifest-debug.mf。该文件其中额外定义了一些属性来指定文件目录位置,这样资源的修改可以立即生效（需要配置stapler.jelly.noCache=true），不需要重新打包安装。
在maven中可以使用命令：
mvn hpi:hpl -DhudsonHome=/...
2.6 使用.hpi进行测试
在调试通过后，可以使用.hpi文件来启动jenkins,查看结果，命令如下：
mvn hpi:run -DhudsonHome=/...
说明：-DhudsonHome可以不选，默认Jenkins安装到工程的./target目录中。
