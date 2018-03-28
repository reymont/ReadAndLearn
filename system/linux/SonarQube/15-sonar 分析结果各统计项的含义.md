

https://blog.csdn.net/zhanlanlubai/article/details/7763169

Sonar是一个开源的代码质量管理平台。它集成了各种插件或者工具来对我们的项目进行质量分析，并能直观地产生相应的分析结果

 

本文主要对Sonar的各个分析结果项的含义进行概要解释，以上图为例，下为详细内容。

代码行

623 lines： 623行代码；

197 statements： 197语句；

10 files： 10个文件；

类

8 packages：共8个包；

42 methods：共42个方法；

0 accessors：0个存取；

注释

15.9% ：注释占代码行总量的百分比；

78 lines：78行注释；

43.2% docu.API：43.2%的方法（API）含有文档注释

25 undocu.API：25个方法（API）没有加文档注释

：代码重复度

0.0% ：无代码重复

0 lines ：0行重复；

0 blocks：0代码块重复；

0 files：0文件重复

2.5 Violations：代码违反规则

23： 共有23处违规；

Rules compliance ： 规则遵从度；

85.2% ： 85.2%的代码遵从各项规则；

 

Blocker：阻断块。最严重的错误类型；

Critical：严重的错误类型；

Major：重要的错误类型；

Minor：次要的错误类型；

Info：一般信息；

2.6 Package tangle index：包耦合指数

0.0%：耦合度；

> 0 cycles ：0循环；

包耦合指数反映了包的耦合级别，最好的值为0%，意味着包之间没有圈依赖；最差的值为100%，意味着包与包之间的关系特别的复杂。

2.7 Dependencies to cut： 依赖切割

含义：多少个packages或者files需要做依赖性切割。

 

0 between packages：包之间无可切割的依赖

0 between files：文件之间无可切割的依赖

2.8 Complexity： 复杂度

3.2/method :  方法的平均复杂度是3.2

13.4/class:  类的平均复杂度的是13.4

13.4/file: 文件的平均复杂度是13.4

Total:134: 复杂的之和为134

 

右侧的小图表如下：

可以选择从class角度或者method角度来看（建议），其中x轴是复杂度，y轴是数量。上图表示：

复杂度为1的method约有28个；

复杂度为2的method约有1个；

复杂度为4的method约有5个；

……….

 

以method为计算单位的复杂度建议值：

1~10：够简单，风险低；

11~20：有点复杂，有点风险；

21~50：很复杂，高风险；

>50：只有上帝才能看懂的方法；

2.9 LCOM4： 缺乏内聚度

1.0/class:类内聚程度的平均值；

0.0% file having LCOM4>1： 0.0%的文件LCOM4值大于1。

2.9.1详细解释LCOM4：

LCOM4：Lack of cohesion of methods（缺乏内聚性的方法），用来度量类的内聚性。这是因为在设计上，我们尽量保证类是高内聚，低耦合。

内聚是指一个类中的方法的紧密程度。当一个类中的两个方法不使用一个共同属性或者方法，如果遵守单一职责原则，这意味着它们没有共用任何东西或者它们就不属于同一个类。换句话说，你应该把这个类分解为多个新类来达到类级别模块化的目的。

对于Sonar的LCOM4，值1表示这个类只有一个职责(好)，值X代码这个类有X个职责（差），值X的类应该重构/分割。

2.10 Response for Class： 类的响应

15/class: 平均每一个类有15个响应；

下侧的小图表如下所示：


X轴是RFC的值，y轴是class的数量，RFC数量愈小愈好。

0~50：建议值；

>50：类太过复杂。

2.11 Code coverage：代码覆盖率

2.4%：2.4%行的代码被测试到；

3.5% line coverage：3.5%的普通代码行被测试到；

0.0% branch coverage：0.0%的分支代码行被测试到；(如if - elseif - else如果只測到if內的code就只有33%，若測到 if - elseif就是66%，if - elseif - else全測到就是100%）

 

2.12 Unit test success： 单元测试成功度

100.0%: 测试成功率

0 failures: 0失败

0 errors：0错误

1 tests： 1个单元测试

146ms：单元测试共消耗146毫秒

 

其他补充说明