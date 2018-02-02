http://blog.csdn.net/henni_719/article/details/53586051

第1章Cucumber简介与环境设置
1.1 BDD简述
         BDD（BehaviorDriven Development：行为驱动开发）为用户提供了从开发人员和客户的需求创建测试脚本的机会。因此，开始时，开发人员，项目经理，质量保证，用户验收测试人员和产品所有者（股东）都齐聚一堂，集思广益，讨论应该传递哪些测试场景，以便成功调用此软件/应用程序。这样他们想出了一组测试场景。所有这些测试脚本都是简单的英语语言，所以它也服务于文档的目的。
1.2 例子
  如果正在开发一个用户认证功能，这是可能有如下几个关键测试场景，为了能成功调用它这些场景必须测试通过。
1. 用户使用正确的用户名、正确的密码登录成功
2. 用户使用错误的用户、正确的密码不能成功登录
3. 用户使用正确的用户名、错误的密码不能成功登录
4. 用户使用错误的用户名、错误的密码不能成功登录
1.3 BDD工作流程
         代码必须通过在BDD中定义的测试脚本。如果没有发生，将需要代码重构。只有在成功执行定义的测试脚本后，代码才被冻结。测试流程：
          
         Cucumber是一个支持行为驱动的开发的开源工具。 更准确地说，Cucumber可以定义为一个测试框架，由简单的英语文本驱动。它作为文档、自动化测试和开发帮助。
它可以在以下步骤中描述：Cucumber读取在要素文件中以纯英语文本编写的代码；它找到步骤定义中完全匹配的每个步骤。
         这部分被执行的代码可以是不同的软件框像Selenium、Ruby on Rails等。不是每个BDD框架工具都支持每个工具。这也是Cucumber比那些框架受欢迎的原因，因为它支持：JBehave、JDave、Easyb等。
         Cucumber支持数十种不同的软件平台，例如：Ruby on Rails、Selenium、PicoContainer、Spring Framework、Watir。
1.4 Cucumber优于其他工具的优点
Ø  Cucumber支持不同的语言，例如Java、.net、Ruby
Ø  它充当业务与技术间桥梁的角色。可以通过在纯英文文本中创建一个测试用例来实现这一点。
Ø  它允许在不知道任何代码的情况下编写测试脚本，它允许非程序员参与。
Ø  它以端到端测试框架为目的
Ø  由于简单的测试脚本架构，Cucumber提供了代码可重用性
1.5 Cucumber环境设置
         在Window机器上部署Cucumber环境，语言是java，平台是Selenium。
         关于Java安装与环境变量设置，从网上自己查找，并设置成，设置完成，验证是否成功！
           
         java安装成功之后，安装Eclipse用于编译Cucumber，到官网下载相应版本，解压缩找到exe程序直接运行即可：http://www.eclipse.org/downloads
         之后是Maven安装设置：Maven是一个主要用于java项目自动化编译工具。它提供一个通用的平台来执行活动，如生成源代码，编译代码，打包代码到jar等。之后，如果任何软件版本被改变，Maven提供了一个简单的方法来相应地修改测试项目。
         Maven下载链接：https://maven.apache.org/download.cgi，从网上搜索如何Maven环境设置。
         Jave与Maven环境配置成功，启动Eclipse，进入到“Help -> EclipseMarketplace -> Search Maven -> Maven Integration for Eclipse ->INSTALL”。
         之后，使用Maven配置Cucumber的步骤如下：
         Step_1：创建一个Maven项目
      进入到“File -> New -> Others -> Maven-> Maven Project -> Next”,填写“group Id”(group Id是在所有项目中的唯一的标识)，填写"artifact Id"(artifact Id不带有版本的jar的名称，用户可以选择任何名称（小写字母），点击完成。
        
      Step_2：打开pom.xml
       进入到项目浏览列表，扩展开项目名，找到pom.xml文件，打开该文件。
          
      Step_3：添加selenium、JUnit、Cucumber-JUnit、Cucumber-Java依赖
       这将指示Maven哪些r文件将从中央存储库下载到本地存储库。打开pom.xml文件，在项目tag里创建依赖tag(<dependencies></dependencies>)。在dependencies tag里创建dependency tag(<dependency></dependency>)，在dependency tag提供如下信息：
          
      Step_4:验证binaries
      pom.xml编辑成功并保存，然后进入Project -> Clean 将花费几分钟。
           
         将能够看到一个Maven仓库，如下面的截图所示
           
         环境搭建成功，之后将创建一个功能文件、一个步骤定义文件、一个Junit runner运行test。