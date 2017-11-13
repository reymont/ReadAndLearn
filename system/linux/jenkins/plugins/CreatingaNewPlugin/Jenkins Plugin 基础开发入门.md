
* [Jenkins Plugin 基础开发入门 - CSDN博客 ](http://blog.csdn.net/xiaosongluo/article/details/52355956)

引子：Jenkins 是目前阶段各大公司运用持续集成的主要轮子，而 Jenkins 能否发挥如此神威的主要原因即在于其众多的 Plugins 可以快速实现定制化需求。笔者因工作需要，体验了一把从零入门 Jenkins Plugin 开发。现把经验总结形成本文。

## 0x00 弄清 Jenkins 的主要概念

先来看看 Jenkins 自己搭建的 CI 环境：Jenkins on Jenkins ，再结合下面这张官网给出的解释持续交付工作流程的示意图，简单学习 & 增加感性认识。



Pipeline Flow

IBM 给出资料指出 Jenkins 在实现上有三个重要概念：

Stapler

Stapler 可以自动为应用程序对象绑定 URL，并创建直观的 URL 层次结构。而Jenkins 的类对象和 URL 绑定就是通过 Stapler 来实现的，通过该技术我们可以快速访问对应的Job及其相应资源。
持久化

Jenkins 使用文件来存储数据（所有数据都存储在$JENKINS_HOME）。
插件

Jenkins 的对象模型是可扩展的，通过 Jenkins 提供的可扩展点，我们可以开发插件扩展 Jenkins 的功能。
所有的 Plugin 都是在 Jenkins Master 上运行的。

## 0x01 选择 Jenkins 的扩展功能接口

* 扩展功能接口Jenkins Extension Points
  * 插件的开发都是基于 Jenkins 的扩展功能接口
  * https://wiki.jenkins-ci.org/display/JENKINS/Extension+points
* 一次构建过程的个步骤： 
  * 1.SCM checkout：检出源码，用于指定构建的目标。 
  * 2.Pre-build steps：预编译。 
  * 3.Build wrapper set up：构建环境准备。 
  * 4.Builder runs：执行构建的核心过程，例如调用Ant，Make等。 
  * 5.Recorder runs：记录构建过程中的输出，例如测试结果等。 
  * 6.Notifier runs：根据结果发送通知。
* Pre－build 仅仅是 huson.tasks 的一个 Interface
* 五个扩展功能接口
  * hudson.scm.SCM
  * hudson.tasks.BuildWrapper
  * hudson.tasks.Builder
  * hudson.tasks.Recorder
  * hudson.tasks.Notifier


当然，如果想实现其他更复杂的功能，可以直接参考 官方文档 以及 官方提供的插件源码列表。

## 0x02 搭建 Jenkins 开发环境

创建插件工程目录

按照 Jenkins 插件开发的要求配置完 maven 的 settings.xml 配置文件之后，执行以下命令：

mvn -U org.jenkins-ci.tools:maven-hpi-plugin:create -DgroupId={your.gound.id} -DartifactId={your.plugin.id}

其中，your.groud.id 和 your.plugin.id 填你插件的具体对应的值。命令执行之后，该目录下会产生一个名称是 {your.plugin.id} 的 HelloWorld 插件工程目录。

调试插件

由于我们的 Plugin 的相关配置已由 Maven 工程的 pom.xml 定义好了，所以我们的仅需执行如下命令即可进行调试：

mvn hpi:run

这句简单的命令就已经包含了诸如启动 Jetty 服务器，将 Jenkins 作为一个 Web 服务增加至上诉服务器以及在 Jenkins 中安装我们刚写生成的 HelloWorld 插件等一系列任务。

一旦上述过程成功执行，我们就可以可以在浏览器中通过下面的 URL 访问我们刚刚搭建好的 Jenkins 的主页：

http://localhost:8080

这时我们就可以检查我们编写的插件是否满足我们的设计需要了。

发布及安装插件

Jenkins 的插件通过 hpi 文件格式发布，所以在发布前，需要通过如下命令进行打包：

mvn package

命令执行完成之后，即可在target目录下的生成插件的 hpi 文件和 jar 文件。

然后，我们无论是选择将 hpi 文件拷贝到 Jenkins Home 路径下的 plugin 目录中，或者选择通过 Jenkins 插件管理上传安装该 hpi 文件，均可完成插件的安装。

0x03 梳理 Jenkins Plugin 工程结构

虽然 Jenkins 也支持Groovy 进行UI 开发，Jenkins 主要是用 Jelly 来进行 UI 管理。而 Jelly UI 技术的主要原理是通过服务端的渲染引擎将 Jelly 定义好的 XML 文件渲染成客户端需要的 HTML，Javascript 和 Ajax 等。

初步入门 Jenkins Plugin 的人（例如笔者自己）往往最困惑的一点就是如何理清 Jenkins Plugin 的工程结构以及 Plugin 的Jelly到底该怎么写。

通过上面的 mvn 指令我们生存的工程目录具有如下的布局结构：

pom.xml - Maven POM 文件，用于配置插件的设定
src/main/java - 插件的 Java 源文件
src/main/resources - 插件的 Jelly 视图文件
src/main/webapp - 插件的静态资源，如图片或 HTLM 等
0x04 Jelly UI 入门

弄清楚了工程结构，剩下的事情就是到底怎么用 jelly 来写插件的 UI 了。而这无非也就是需要弄明白三件事情：

如何为指定对象创建一个 Jelly UI 页面；
如何读取 Jelly 中的用户输入；
如何操控 Jelly 反馈信息。
如何为指定对象创建一个 Jelly UI 页面

前面说到，工程的目录结构中：

src/main/java - 插件的 Java 源文件
src/main/resources - 插件的 Jelly 视图文件
而 Jenkins 如何将两者之前建立起对应关系的呢？简单来说根据路径结构的一致性来建立关系。

假设你建立了一个java类，路径为

src/main/java/org/sample/HelloWorldBuilder.java

则增加Jelly文件需要在resources文件夹中建立与类同名的目录:

src/main/resources/org/sample/HelloWorldBuilder/

需要说明的是，Jenkins 通过固定的命名方式来确定页面文件属于局部配置还是全局配置：config.jelly 为局部配置；global.jelly 为全局配置。

这里它们的区别在有点类似于局部变量与全局变量的区别。gloabal.jelly 更多的用于读取存储与某个具体构建无关的配置信息。而具体的构建本身的相关参数基本都由 config.jelly 进行处理。

如果我们需要创建的是一个局部的配置（大多数情况），那么我们就在上述路径下增加文件config.jelly，路径如下:

src/main/resources/org/sample/HelloWorldBuilder/config.jelly

如何读取 Jelly 中的用户输入

那么我们有如何访问 Jelly 中的信息呢？最为基础的方法就是通过 Descriptor 进行页面和数据的绑定了。

假设我们在 jelly 按如下方式进行定义：

<f:entry title="Name" field="name">

那么与之对应的，我们就可以在对应的类里进行如下配置了：

@DataBoundConstructor
public HelloWorldBuilder(String name) {
   this.name = name;
}

那么当 UI 中的数据提交之时， Jenkins 会根据传过来的具体数据调用构造函数来创建对象。

在类中增加getter方法，或者将变量设置为public final。这样可以还让Jelly脚本将数值显示到配置信息页面。

public String getName() {
   return name;
}

在内部实现的DescriptorImpl类中，我们也可以选择增加doCheckFIELD()函数，来进行配置检查。在参数上可以增加@QueryParameter注解来传入附近位置的数据。

public FormValidation doCheckName(@QueryParameter String value) 
    throws IOException, ServletException {
  if (value.length() == 0) {
    return FormValidation.error("Please set a name");
  }
  if (value.length() &lt; 4) {
    return FormValidation.warning("Isn't the name too short?");
  }
  return FormValidation.ok();
}

当然，我们也可以使用各种 Jelly 控件，如textbox，checkbox 以及 validateButton等等。具体的使用方法，可以参考以下文档，这里就不一一展开了。

参考文档：jenkinsci/ui-samples-plugin

如何操控 Jelly 反馈信息

首先，我们先来看看 Jelly 如何访问项目中的其它资源。默认情况下， Jenkins 已经定义了以下对象：

app － Jenkins
it － Jelly UI 绑定的类
instance － Jelly UI 所对应的正在被配置的对象
descriptor －与 instance 所对应的 Descriptor
h － husdon.Functions 的实例
所以我们如果在类中配置了：

public String getMyString() {
    return "Hello Jenkins!";
}

而按如下方法编写其对应的 jelly 文件：

<j:jelly xmlns:j="jelly:core" xmlns:st="jelly:stapler" xmlns:d="jelly:define" xmlns:l="/lib/layout" xmlns:t="/lib/hudson" xmlns:f="/lib/form">
    ${it.myString}
</j:jelly>

那么，页面上就能调用出类的方法，显示出”Hello Jenkins！”了。