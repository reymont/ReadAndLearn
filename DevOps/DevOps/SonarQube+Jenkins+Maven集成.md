

SonarQube+Jenkins+Maven集成_用户2803485501_新浪博客 
http://blog.sina.com.cn/s/blog_a719cb3d0102wce9.html

目录
SonarQube+Jenkins+Maven集成
一、简单介绍
1.1、SonarQube简介
1.2、Jenkins简介
二、操作流程
2.1、配置pom.xml
2.2、配置jenkins
2.3、查看代码质量
2.4、步骤总结
三、SonarQube的具体使用
3.1、SonarQube的项目名称
3.2、SonarQube的“问题”
3.3、SonarQube的指标
3.4、SonarQube的质量配置和质量阈


一、简单介绍

1.1、SonarQube简介

       SonarQube是一个用于代码质量管理的开源平台，用于管理源代码的质量。SonarQube可以通过插件的形式，支持JAVA、C#、C/C++、PL/SQL、Cobol、JavaScrip、Groovy等多种变成语言的代码质量管理与检测。
       Sonar可以从以下几个维度检测代码质量，而作为开发人员，至少需要处理前5钟代码质量问题：
       1、是否遵循代码标准：
SonarQube可以通过Findbugs、CheckStyle等代码规则检测工具规范代码的编写；
       2、潜在的缺陷：         
SonarQube可以通过Findbugs、CheckStyle等代码规则检测工具检测出潜在的缺陷；
       3、糟糕的复杂度分布：
文件、类、方法等，如果复杂度过高将难以改变，这会使得开发人员难以理解他们。如果没有自动化的单元测试，对于程序中的任何组件的改变都将可能导致需要全面的回归测试；
       4、重复：
显然程序中包含大量复制粘贴的代码是质量低下的表现，SonarQube可以展示源码中重复严重的地方；
       5、注释不足或过多：
没有注释将使代码可读性变差，特别是当不可避免的出现人员变动时，程序的可读性将大幅下降。而过多的注释又会使得开发人员将精力过多的花费在阅读注释上，亦违背初衷；、
       6、缺乏单元测试：
              Sonar可以很方便的统计并展示单元测试覆盖率；
       7、糟糕的设计：
通过Sonar可以招出循环，展示包与包、类与类之间的相互以来关系，可以检测自定义的架构规则。通过Sonar可以管理第三方的jar包，可以利用LCOM4检测单个任务规则的应用情况，检测耦合。
 
1.2、Jenkins简介

       Jenkins是一个开源软件项目，旨在提供一个开放易用的软件平台，使软件的持续集成变成可能。Jenkins不仅提供友好的用户界面，而且内置的功能提供了极大的便利，不论是新建一个build，还是日常使用，你需要做的大部分时候仅仅是在用户界面上点击而已。Jenkins作为一个欣欣向荣的开源项目，有大批的plugin。当你发现需要一个jenkins本身不提供的功能时，搜索一下plugin，总会有收货。
 
二、操作流程

2.1、配置pom.xml

       由于我们使用的是maven项目，maven项目的标准结构如图2-1所示，
SonarQube+Jenkins+Maven集成         SonarQube+Jenkins+Maven集成  
                       图2-1                                                       图2-2
而我们的项目结构可能和标准结构有些不同，如图2-2所示。尽管结构不一样，我们还是能够很清楚的分辨出每一个包都是做什么的。但是对于sonar来说，它就识别不了。它只能找到我们的java source，却找不到test source。因此，我们需要在pom.xml的build标签中添加如下代码，如图2-3。这样做之后，sonar便能正常找到我们的测试代码，并执行它们，执行的结果也将被一一记录下来。
 
SonarQube+Jenkins+Maven集成
图2-3
2.2、配置jenkins

       在配置了pom文件之后，我们只需要将最新的代码上传到gitlab就好了，之后都不会对项目进行操作了。
       现在我们需要到jenkins上对项目进行一些配置。
使用账号密码进行登陆过后，我们点击页面左边的新建。
SonarQube+Jenkins+Maven集成
进入到如下页面后，输入项目名称，并选择“构建一个maven项目”，点击“OK“进入配置页面。
SonarQube+Jenkins+Maven集成
进入配置页面后，点击上方的“源码管理”。
SonarQube+Jenkins+Maven集成
之后选择在页面上选择“git”，弹出如下界面。
SonarQube+Jenkins+Maven集成
Respository url部分为gitlab中的项目的url。
 SonarQube+Jenkins+Maven集成
如果是第一次在jenkins中导入gitlab项目，需要点击credentials最右边的“add”按钮，通过输入gitlab的账号密码来添加认证，以让jenkins通过gitlab的权限认证。
SonarQube+Jenkins+Maven集成
输入完成后，在下拉菜单中选择相应的选项即可。
之后便是确定项目的分支。
SonarQube+Jenkins+Maven集成
Gitlab配置完成过后点击上方的“build”选项。
SonarQube+Jenkins+Maven集成
       页面跳转到如下页面后，在“Goals and options”中输入以下内容即可。
clean org.jacoco:jacoco-maven-plugin:prepare-agent install -Dmaven.test.failure.ignore=true
SonarQube+Jenkins+Maven集成
之后在下方的Post Steps中点击“Add post-build step”选择“Execute shell”，并在弹出的框体中输入：mvn org.sonarsource.scanner.maven:sonar-maven-plugin:3.2:sonar
SonarQube+Jenkins+Maven集成
SonarQube+Jenkins+Maven集成
之后点击最下方的保存即可。
这些配置项是随时都可以更改的，只要在项目中点击左边的“配置”即可。
SonarQube+Jenkins+Maven集成
 
在确定配置完成后，点击左边的“立即构建”即可。
SonarQube+Jenkins+Maven集成
Jenkins会自动编译我们的代码，执行代码中的单元测试（不能同时执行junit和testng，如果有testng，junit则不会被执行）。代码运行的结果我们可以在左下角的构建历史中找到。
点击左下角的序号，可以进入到相应的构建结果中。再点击左边的“Console Outout0”可以看见代码的构建和运行过程。如果构建失败，我们可以从中知道为什么失败，是在哪一步失败了。
SonarQube+Jenkins+Maven集成
SonarQube+Jenkins+Maven集成
2.3、查看代码质量

构建成功过后，我们就可以到SonarQube的页面上查看我们的代码的质量了。
SonarQube+Jenkins+Maven集成
红色部分就是刚刚生成的结果。点进去过后，就可以看到一个关于代码的大致的质量情况。其中会有bug、覆盖率、代码重复段、代码复杂度、代码大小和编码习惯的一些粗略的指标，并且会有一个代码质量是否通过的判断结果。
SonarQube+Jenkins+Maven集成
点击左上角的“问题”过后，可以看到一个关于bug、漏洞、习惯的详细界面。
SonarQube+Jenkins+Maven集成
点击“指标”可以看到各项指标的详细情况。
SonarQube+Jenkins+Maven集成
点击“代码”可以看到每一部分代码的总体情况和具体情况。
SonarQube+Jenkins+Maven集成
SonarQube+Jenkins+Maven集成
“仪盘表”是一个展示页面，这个页面可以自己配置要展示的内容。
SonarQube+Jenkins+Maven集成
 
2.4、步骤总结

       1、在pom文件的build标签下配置测试源代码路径。
              SonarQube+Jenkins+Maven集成
2、在jenkins中新建maven项目。
3、配置新建项目：
1）、源码管理中选择git，并填入相应的url，选择相应的gitlab账号密码对，选择相应的分支；
2）、在build的Goals and options的输入框中输入 clean org.jacoco:jacoco-maven-plugin:prepare-agent install -Dmaven.test.failure.ignore=true
3）、在Post Steps中点击Add post-build step，选择Execute shell，并在出现的输入框中输入 mvn org.sonarsource.scanner.maven:sonar-maven-plugin:3.2:sonar
4）、点击保存
       4、配置完成后，点击“立即构建”构建项目。
       5、项目构建成功后，到SonarQube页面中查看结果。
 
三、SonarQube的具体使用

3.1、SonarQube的项目名称

对于每一个项目，在SonarQube上都有一个对应的项目名称。SonarQube的项目名称是在生成项目的时候根据pom文件中的配置自动生成的。项目名称由projectKey和projectName组成，projectKey又由pom文件中的groupId和artifactId以groupId:artifactId的形式决定，projectName由pom文件中的name决定。
SonarQube+Jenkins+Maven集成  SonarQube+Jenkins+Maven集成
ProjectKey是每个项目的唯一标识，即当projectKey确定了过后，不管projectName如何改变，它都是同一个项目。不同的项目需要有不同的projectKey。
 
3.2、SonarQube的“问题”

SonarQube提供对所有项目的代码的问题总览和对单个项目的代码的问题总览。在“问题”栏中，我们可以看到“bug”、“漏洞”、“坏味道”的数量，处理和未处理的数量，以及问题出在哪，违反了什么规则，如何处理等。
SonarQube+Jenkins+Maven集成
在“问题”栏下，我们还可以对这些问题进行人员分配，以及该人员对bug是否确认、是否修复。在管理权权限下，我们还可以定义该bug是否属于bug，以及bug的重要性。
3.3、SonarQube的指标

在“指标”栏下，我们可以看见代码的详细情况，比如可靠性、安全性、可维护性、覆盖率、重复、大小、复杂度、注释和问题。
可靠性是关于bug的数量和bug数量与代码数量形成的可靠性比率等级的展示。这里我们也可以看到修复这些bug所需要的大致时间。
SonarQube+Jenkins+Maven集成
安全性是关于漏洞的数量和漏洞数量与代码数量形成的可靠性比率等级的展示。这里我们也可以看到修复这些漏洞所需要的大致时间。
SonarQube+Jenkins+Maven集成
关于漏洞和bug的区别，我个人的理解是bug在现在或者将来可能导致程序抛出异常，而漏洞不会抛出异常，只是影响以后对程序运行状况的影响。
可维护性是关于“坏味道”的数量和“坏味道”数量与代码数量形成的评级的展示。这里我们也可以看到修复这些所需要的大致时间。所谓的“坏味道”是指和一定的程度上的不良好的编码习惯，和违背了一些规范的编码，它不影响代码的正常运行。
SonarQube+Jenkins+Maven集成
覆盖率是关于单元测试的运行状况的展示。这里可以看到单元测试的数量，测试代码的覆盖率，以及单元测试运行的情况（成功或失败）。
SonarQube+Jenkins+Maven集成
重复是关于代码中重复代码的展示。这里有重复代码的百分比和重复代码的行数、块数和文件数。
SonarQube+Jenkins+Maven集成
大小是对于项目的大小的描述。
SonarQube+Jenkins+Maven集成
复杂度是对于代码复杂情况的描述。每有一个方法复杂度就会+1，每有一个if复杂度就会+1，if里面每多一个判断条件复杂度也会+1。总之就是对代码复杂情况的描述。
SonarQube+Jenkins+Maven集成
文档数对代码中注释的描述。这里展示了代码中含有注释部分的百分比。如果百分比过低，那么将会严重影响代码的可读性。
SonarQube+Jenkins+Maven集成
3.4、SonarQube的质量配置和质量阈

       对于管理员来说，这里还有质量配置和质量阈需要注意。质量配置就是规定什么是bug、什么是漏洞、什么是坏味道的地方。Sonar提供了默认配置，当然我们也可以手动进行配置。
SonarQube+Jenkins+Maven集成
质量阈是决定代码质量是否通过的地方。这里可以对每一个指标进行设置，规定一个阈值，如果代码的这个值小于或者大于这个阈值，那么代码将视为通过，反之，则视为不通过，需要重新修改。
SonarQube+Jenkins+Maven集成
这里也提供了默认的情况，我们也可以手动进行修改阈值或者增加判定的指标。