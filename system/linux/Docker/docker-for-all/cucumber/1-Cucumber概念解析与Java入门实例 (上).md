Cucumber概念解析与Java入门实例 (上) - CSDN博客 http://blog.csdn.net/macdowellliu/article/details/74906590

以下概念及实例有部分参考自Cucumber官方书籍The Cucumber for Java Book

概念解析

自动化验收测试-Automated Acceptance Tests 
自动化验收测试的想法源于极限编程（XP-Extreme Programming），特别是在测试驱动开发（TDD-Test-Driven Development）的实践中。 
客户（stakeholder）不再仅仅将业务需求传递给开发团队却没有反馈的机会，而是通过开发人员和客户合作编写表达客户希望的结果的自动化测试，我们把这一点称为验收测试，因为它表达了软件需要实现什么才能使客户认为它可以接受。 
这些测试与单元测试（Unit Test）不同，单元测试针对开发人员，并帮助其检查软件的设计。有时候，单位测试确保我们在做正确的事情，而验收测试确保我们事情的做法是正确的。 
Unit tests ensure you build the thing right, whereas acceptance tests ensure you build the right thing. 
自动验收测试可帮助开发团队保持专注，确保工作的推进，每次迭代都是团队可能做的最有价值的事情。

行为驱动开发-Behavior-Driven Development 
最佳的TDD实现者从外部工作，从客户的角度出发，从客户验收测试失败来描述系统的行为。 作为BDD实现者，则需要谨慎地将验收测试写为团队中任何人都可以阅读的示例。 我们利用编写这些例子的过程，从客户获得有关我们在开始之前是否在做正确的事情的反馈。 在这样做的时候，会刻意地开发一种共同的，无所不在的语言来谈论系统。

Cucumber原理 
Cucumber正是一种出众的验收测试工具，并借助Gherkin作为编写这些验收测试的辅助语言。 
当运行Cucumber时，它会从简单的语言文本文件（称为feature）读取您的需求，检查它们以供测试场景（称为scenario），并针对您的系统运行这些scenario。 每个scenario都是Cucumber工作的步骤清单。 
所以Cucumber可以理解这些feature文件，他们必须遵循一些基本的语法规则，这套规则的名称便是Gherkin。 
如果步骤（称为step）定义中的代码执行没有错误，Cucumber进行到scenario的下一个step。 如果在scenario结束时没有任何出现错误的step，则会将该scenario标记为已通过。 但是，如果方案中的任何step失败，则Cucumber将scenario标记为失败并移至下一个step。 随着scenario的运行，Cucumber打印出结果，显示出哪些是可以通过的，而哪些存在错误。 
Cucumber原理

Cucumber入门实例

希望通过这个实例，使初次接触Cucumber的Java开发者体会借助其进行自动化测试的整个流程，并理解各关键思想的意义。

准备工作

这次我采用命令行的方式来进行这套Java实例的开发，本机系统是macOS，与Windows下cmd基本完全相同，有所差异的地方我会做说明。
需要下载的Jar包是： 
cucumber-core
cucumber-java
cucumber-jvm-deps
gherkin 
以上四个均可以在Cucumber的Maven仓库得到: http://repo1.maven.org/maven2/info/cukes/
实例目标

我们的目标是编写一个Java库，用于计算购物的商品结账价格，结帐将跟踪总成本。 
例如，如果可售商品的价格如下所示： 
banana 40c 
apple 25c 
我们在结帐时选购的商品只是： 
1 banana 
那么输出将为 
40 c 
同样，如果我们购买了多个商品： 
3 苹果 
那么输出将为 
75 c

Step 1: 构建feature

Cucumber测试以feature为分组。 使用这个名称因为我们希望其可以描述用户在使用程序时可以享受的功能。 
我们需要做的第一件事是创建一个文件夹，用来将存储我们的新项目以及我们将要编写的feature：

$ mkdir checkout
$ cd checkout
1
2
接下来我们需要创建一个文件夹，并拷贝进刚刚下载好的四个Jar包：

$ mkdir jars
1
我希望这个项目的编写是借助Cucumber的帮助，因此让我们先使用Cucumber指令运行一下看一看：

$ java -cp "jars/*" cucumber.api.cli.Main -p pretty .
1
终端输出： 
output

出现了以上的提示。我们先来仔细看看执行的指令。 
首先，我们调用Java解释器，并使用指定的类路径来执行cucumber.api.cli.Main类中包含的入口点。该类包含实现Cucumber命令行界面（CLI）的代码，它允许我们控制Cucumber如何搜索要运行的测试。其中，将两条信息传给Cucumber： 
1. -p pretty告诉Cucumber使用漂亮的格式化程序插件 
2. 指向我们的feature文件所在位置的路径

不过我们还没有写任何feature文件，这就是为什么当我们运行Cucumber时，它给了我们有用的错误信息：No features found at [.]

这条指令会逐渐增长，所以我们把它放到一个shell脚本文件中吧！在项目根路径（在我这里是/checkout）中，使用任一个你善用的文本编辑器创建一个名为cucumber的文件，（注意：如果使用Windows系统，则应命名为cucumber.bat）。 
输入以下文字：

java -cp "jars/*" cucumber.api.cli.Main -p pretty .
1
如果你正在使用包括macOS的*nix系统，需要将cucmber文件变为可执行文件，再运行这个cucumber文件：

$ chmod u+x cucumber
$ ./cucumber
1
2
如果正在使用Windows系统，可只需要直接执行这个batch类型的文件即可：

$ cucumber.bat
1
终端的输出会和第一次一模一样： 
output

所以喽，是时候创建我们的第一个feature了！在项目根目录下创建一个新文件夹：

$ mkdir features
$ cd features
1
2
创建一个空的feature文件，*nix系统下使用：

$ touch checkout.feature
1
Windows下使用：

$ type nul > checkout.feature
1
让我们来修改之前创建的名为cucumber的shell文件，用来告诉Cucumber哪里可以找到我们的feature文件：

java -cp "jars/*" cucumber.api.cli.Main -p pretty features
1
再次运行cucumber文件：

$ ./cucumber
1
终端输出： 
output

每个Cucumber测试称为scenario，每个scenario包含告诉Cucumber要做什么的step。 而上方输出代表着Cucumber扫描了features目录，但没有找到任何可运行的scenario。于是我们就来创建一个吧！ 
使用任一编辑器修改刚刚创建的空的文件，checkout.feature：

Feature: Checkout
  Scenario: Checkout a banana
     Given the price of a "banana" is 40c
     When I checkout 1 "banana"
     Then the total price should be 40c
1
2
3
4
5
注意：Given, When, Then这样的关键词后没有冒号。 
这个feature文件包含我们的checkout类的第一个scenario。我们可以将实例一开始提到的购物结算需求转化为Cucumber的scenario。你可能会开始有所体会，Cucumber希望在我们做编写的feature文件遵循一定的结构。 关键字Feature, Scenario, Given, When, Then是结构，其他的都是文档。而该结构就称为小黄瓜Gherkin : )

保存此文件并在此运行cucumber时，会看到比上次更多的输出： 
output

唔哦，突然有很多的输出！我们来看看这里发生了什么。 
首先，我们可以看到，Cucumber已经发现了我们的feature，并试图运行它。我们可以确信这一点，是因为Cucumber已经将feature的内容复述给了我们。可能还注意到，摘要输出部分已经从“0 scenarios”变更为“1 scenario (1 undefined)“，这意味着Cucumber已经阅读了我们的feature中的scenario，只是不知道如何运行它。 
其次，Cucumber打印出三个代码片段，这些是用Java编写的step定义的示例代码，它告诉Cucumber如何将feature中的普通的英文step转换为针对应用程序的操作。我们的下一步是将这些片段放入Java文件中，我们可以开始将它们整理出来。但首先，由于遵循Java编码标准，我们注意到这些step定义是使用snake case3而不是camel case。不过别担心，我们不需要手工编辑它们，而是只需要告诉Cucumber我们的需求是什么。

进一步修改cucumber文件：

java -cp "jars/*" cucumber.api.cli.Main -p pretty --snippets camelcase features
1
再次运行：

$ ./cucumber
1
这一次，它会生成符合Java标准的带有方法名称的片段： 
output

在我们深入探索面向业务的Gherkin features之前，有必要仔细观察下方这幅图片，它让我们可以明白各个要素是如何结合在一起的。最先从Features开始，其中包含我们的scenario和step。 scenario的每一个step称为Step Definitions，其提供了Gherkin features和正在构建的应用程序之间的连接。 
main layers of cucumber

在下一篇《Cucumber概念解析与Java入门实例 (中)》中，我们将继续实现我们的实例，先来实现一些Step Definitions，以使我们的step不再是”undefined”的状态。
