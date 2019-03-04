

1. https://blog.csdn.net/lxlmycsdnfree/article/details/80166335
2. https://blog.csdn.net/autoperson/article/details/13507717



Architecture

1.      Architecture---Total Quality Plugin    架构质量

ARCH = 100 – TI（复杂度指标）

 

Complexity

2.      Complexity--- Quality Index Plugin  圈复杂度

也被称为McCabe度量。它简单归结为一个方法中’if’，‘for’，’while’等块的数目。当一个方法的控制流分割，圈计数器加1. 除不被认为是方法的访问器外，每个方法默认有最小的值1，所以不会增加复杂度。对于以下的每一个java关键字/语句，圈复杂度均会加1。注意else, default及finally不会增加CCN的值。另一方面，一个含switch语句及很大块case语句的简单方法可以拥有一个令人惊讶的高的CCN值（同时，当将switch块转化为等效的if语句时，它具有相同的CCN值）。

 

3.     Averagecomplexity by method  方法的平均圈复杂度

 

4.     Complexitydistribution by method  方法复杂度的分布

 

5.     Averagecomplexity by class  类的平均圈复杂度

 

6.     Complexitydistribution by class  类复杂度的分布

 

7.     Averagecomplexity by file  文件平均复杂度

 

8.      ComplexityFactor--- Quality Index Plugin  复杂度因素

CF = (5 * Complexity>30) * 100 / (Complexity>1 +Complexity>10 + Complexity>20 + Complexity>30)

 

9.      QIComplexity---Quality Index Plugin  复杂度质量指标

QIC = (Complexity>30*10 + Complexity>20 * 5 + Complexity>10 * 3 + Complexity>1) /validLines

 

Design

10.  DesignClasses and Methods Complexity--- Total Quality Plugin 类和方法复杂度

NOM = (1 -(class_complexity - 12) / (acel * 12)) * 50 + (1 - (method_complexity - 2.5) /(acel * 2.5)) * 50

 

11.  DesignCoupling Between Objects--- Total Quality Plugin  对象间耦合度

CBO = (1 - (efferent_coupling - 5) / (acel * 5)) * 100 

 

12.    Design Depth of Inheritance Tree--- TotalQuality Plugin  继承树深度

继承树深度（DIT）度量为每个类提供一个从对象层次结构开始的继承等级度量。在Java中，所有的类继承于Object，DIT最小值是1.

DIT = (1 - (depth_of_inheritance_tree - 5) / (acel * 5)) *100

 

13.  DesignLack of Cohesion of Methods--- Total Quality Plugin  方法内聚度

用来说明class内部方法和变量之间的关系,值越大, 说明内聚性越差. 一般情况下 LCOM4=1是内聚性最佳的，2说明可以拆成两个类，依次类推。

LCOM4= (1 - (lack_of_cohesion_of_method - 1) / (acel * 1))* 100

 

14.   Design Response for Class--- Total QualityPlugin  类的响应集合

类的响应集合是 在响应被类的某个对象接收到的一条信息时，可能被执行的方法集合。RFC是这个方法集合里面方法的数量。

RFC = (1 - (response_for_class - 50)/ (acel * 50)) * 100

 

15.   Design Quality--- Total Quality Plugin  设计质量

DES = 0.15*NOM + 0.15*LCOM4 + 0.25*RFC +0.25*CBO + 0.20*DIT

 

16.   Package tangle index  包复杂指数

此参数为包的复杂等级，最好的值为0%，意味着包之间没有圈依赖；最差的值为100%，意味着包与包之间的关系特别的复杂。

PCI = 2 * (package_tangles / package_edges_weight) * 100

 

Documentation

17.   Physicalline  物理行数

回车数目

 

18.  Linesof code 有效代码行数

Lines of code  = physical lines - blank lines - comment lines- header file comments - commented-out lines of code

 

19.   Comment lines  注释行数

Javadoc、多行注释、单行注释的总数。不包括空注释行、头文件中的注释（主要用于定义许可证）以及commented-out行。

 

20.   Commented-out LOC  注释代码行数

注释掉的代码行数。Javadoc块不会被扫描。

 

21.   Comments (%)  注释率

Comments = comment lines / (lines of code + comments lines) * 100%

 

22.   Public documented API (%)  添加注释的公有API百分比

(public API -undocumented public API) / public API * 100%

 

23.   Public undocumented API  未添加注释API数

 

 

Duplication

24.   DRYness –-- Total Quality Plugin 重复度

DRYNESS = 100 - Duplicated lines density

 

25.    Duplicated blocks  重复块数

 

26.    Duplicated files  重复文件数

 

27.   Duplicated lines  重复行数

 

28.   Duplicated lines (%)  重复行占总行数的百分比

 

29.   Useless Duplicated Lines---Useless CodeTracker 无用的重复行数

当前的Sonar告诉你有50重复的行数，但是不能告诉你是有两块25行的代码重复（这样你可以节省25行代码）还是有5块10行（这样你可以节省40行代码）的代码重复；通过这个插件，你可以获取到额外的信息。

 

General

30.  AnalysabilityValue--- SIG Maintainability Model  可理解性

 

31.   Changeability Value--- SIG MaintainabilityModel 可扩展性

 

32.   Stability Value--- SIG Maintainability Model 稳定性

 

33.   Testability Value--- SIG Maintainability Model可测试性

 

SoftwareImprovement Group(SIG) 是一个可维护性模型，通过Analysability ，Changeability ，Stability ，Testability 4个代表软件可维护性四维的先进指标，可以得到可维护性排名。

 

这个模型需要两步: 计算基数的指标，然后结合他们计算出更高层面上的数值。每一个指标被分成5级别排名：从--（很糟糕）到++（非常好）

 

第一步得到基数的指标。

Volume: 基于代码的行数

Rank
LOC
--
> 1310000
-
> 655000
0
> 246000
+
> 66000
++
> 0
Duplications: 基于代码重复的密度

Rank
Duplication
--
> 20%
-
> 10%
0
> 5%
+
> 3%
++
> 0%
Unit tests:  基于单元测试覆盖率

Rank
Coverage
++
> 95%
+
> 80%
0
> 60%
-
> 20%
--
> 0%
Complexity: 基于方法的圈复杂度

(1)    根据圈复杂度的范围确定在方法代码行中的百分比。

Eval
Complexity
Very high
> 50
High
> 20
Medium
> 10
Low
> 0
(2)    根据分布，我们使用下面的表格来计算等级：

Rank
Medium
High
Very High
++
< 25%
< 0%
< 0%
+
< 30%
< 5%
< 0%
0
< 40%
< 10%
< 0%
-
< 50%
< 15%
< 5%
--
Unit size: 基于方法代码的行数

(1)    根据行数的范围确定方法代码行数的百分比。

Eval
LOCs
Very high
> 100
High
> 50
Medium
> 10
Low
> 0
(2)    根据分布，使用下面的表格来计算等级：

Rank
Medium
High
Very High
++
< 25%
< 0%
< 0%
+
< 30%
< 5%
< 0%
0
< 40%
< 10%
< 0%
-
< 50%
< 15%
< 5%
--
 

第二步是通过一个简单的平均，将他们结合起来，使用以下映射表来确定最终等级.

Volume
Complexity
Duplications
Unit size
Unit tests
analysability
changeability
stability
testability
通过将4个指标简单的结合在一块，可以得到可维护性排名。需要注意的是，图表的颜色代表实际结合后的值，从红色=--到绿色=++。

 

34.    QualityIndex--- Quality Index Plugin  质量指标

QI = 10 - 4.5 * coding - 2 * complexity - 2 * coverage -1.5 * style

 

35.  TechnicalDebt ($)---Technical Debt Plugin  清除所有技术债务需要的花费

 

36.  TechnicalDebt in days---Technical Debt Plugin  需要多少人日去解决技术债务

 

37.  TechnicalDebt ratio---Technical Debt Plugin  技术债务占整个项目的比例

 

38.  TotalQuality--- Total Quality Plugin  总体质量

TQ= 0.25*ARCH + 0.25*DES + 0.25*CODE + 0.25*TS

 

39.  Lastcommit date  最近一次提交的时间

 

40.  Revision  资源的最新版本号

 

41.  Authorsby line  每行代码最后的提交者

 

42.  Revisionsby line  每行代码最新的版本号

 

Management

43.  Burnedbudget  燃尽预算

 

44.  Businessvalue  商业价值

 

45.  Teamsize  团队规模

 

Rules

46.  Blockerviolations  阻碍性违规

 

47.  CodeQuality--- Total Quality Plugin  代码质量

Code = 0.15*DOC + 0.45*RULES + 0.40*DRYNESS

DOC = Documented API density

RULES = Rules compliance index

DRYNESS = 100 - Duplicated lines density

 

48.  Criticalviolations  严重违规

 

49.  DeadCode--- Useless Code Tracker  无作用程序代码

 

50.  Infoviolations  建议级别违规

 

51.   Major violations  重要违规

 

52.   Minor violations  次要违规

 

53.  PotentialDead Code--- Useless Code Tracker  代码未使用的protected方法数

此参数可通过 PMD :UnusedProtectedMethod 或者 SQUID : UnusedProtectedMethod 获取到。计算他们行数的和值。

 

54.  QICoding Violations---Quality Index Plugin 代码违规质量指标(PMD指数)

(Blocker * 10 + Critical * 5 + Major * 3 + Minor + Info) /validLines

 

55.  QICoding Weighted Violations---Quality Index Plugin  代码违规权重指标

通过每个级别的相关系数，违规权重的总和（Sum(xxxxx_violations *xxxxx_weight)）

 

56.  QIStyle Violations---Quality Index Plugin  风格违规质量指标(CheckStyle规则指数)

Style = (Errors*10 + Warnings) / ValidLines * 10

QI = 10 - 4.5 * coding - 2 * complexity - 2 * coverage -1.5 * style

 

57.  QIStyle Weighted Violations---Quality Index Plugin  风格违规权重质量指标

 

58.  Rulescompliance  遵守规则率

100 - weighted_violations / Linesof code * 100

 

59.  Securityrules compliance--- Security Rules Plugin Security规则遵守率

 

60.   Security violations--- Security Rules Plugin  符合Security规则数目

 

61.  Violations  违规总数

 

62.  WeightedSecurity Violations--- Security Rules Plugin Security规则权重值（总数）

 

63.  Accessors   Getter及setter方法的数量

 

64.  ArtifactSize (Kb)--- Artifact Size Plugin记录最终产品大小

 

65.  Classes  类总数

 

66.  Files  文件数

 

67.  Lines  文件中行数

 

68.  Linesof code代码行数

 

69.  Methods  方法数目

 

70.  Packages  包数目

 

71.  Packageedges weight  包之间的文件依赖总数

 

72.  Packagetangle index  包的复杂度指标

给出包的复杂等级，最好的值为0%，意味着没有一个循环依赖；最坏的值为100%，意味着包与包之间存在大量的循环依赖。

2 * (package_tangles / package_edges_weight)* 100

 

73.  PublicAPI  公共类、公共方法（不包括访问器）以及公共属性（不包括publicfinal static类型的）的数目

 

74.  Filecycles一个包内被检测到的文件循环依赖的最小数目

以便于确定所有不需要的依赖。

 

75.  Suspectfile dependencies可去除的文件依赖数

以去除包内文件之间的循环依赖。警告：包内文件的循环依赖不一定是不好的。

 

76.  Fileedges weight  包内文件依赖的总数

 

77.  Filetangle index  包内文件复杂度

2 * (file_tangles /file_edges_weight) * 100.

 

78.  Statements  Java语言规范中没有块定义的语句数目

此数目在遇到含有if,else, while, do, for, switch, break, continue, return, throw, synchronized,catch, finally等关键字的语句时增加, 语句数目不会随着以下情况增加，类、方法、字段、注释定义、包以及import定义。

 

79.  TotalUseless Code-- Useless Code Tracker可以删除的代码行数

 

Tests

80.   Coverage 覆盖率

coverage = (CT + CF + LC)/(2*B +EL)

CT -条件至少一次为“true”的分支

CF -条件至少一次为“false”的分支

LC -覆盖的行数(lines_to_cover - uncovered_lines)

B -分支的总数量(2*B = conditions_to_cover)

EL –可执行代码的总行数 (lines_to_cover)

 

81.  Linecoverage  行覆盖率

Line coverage = LC / EL

LC – 覆盖的行数 (lines_to_cover - uncovered_lines)

EL – 可执行的代码行数 (lines_to_cover)

 

82.  QITest Coverage---Quality Index Plugin  测试覆盖率质量指标

 

83.  Branchcoverage 分支覆盖率

Branch coverage = (CT + CF) /(2*B)

CT – 条件至少一次为“true”的分支

CF – 条件至少一次为“false”的分支

(CT + CF = conditions_to_cover -uncovered_conditions)

B –分支的总数量 (2*B = conditions_to_cover)

 

84.  Skippedunit tests  忽略的单元测试数

 

85.  TestingQuality--- Total Quality Plugin 测试质量

Test = 0.80*COV + 0.20*SUC

COV = Code coverage

SUC = Unit Tests success density

 

86.   Uncovered lines  未覆盖行数

 

87.   Unit test errors  单元测试出错数

 

88.   Unit test failures  单元测试失败数

 

89.   Unit test success (%)  单元测试成功率

 

90.   Unit tests 单元测试个数

 

91.   Unit tests duration  单元测试需要的时间

版权声明：本文为博主原创文章，未经博主允许不得转载。 https://blog.csdn.net/wwlast/article/details/13507717