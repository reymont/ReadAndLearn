Groovy脚本基础全攻略 - CSDN博客 https://blog.csdn.net/yanbober/article/details/49047515

1 背景

Groovy脚本基于Java且拓展了Java，所以从某种程度来说掌握Java是学习Groovy的前提，故本文适用于不熟悉Groovy却想快速得到Groovy核心基础干货的Java开发者（注意是Java），因为我的目的不是深入学习Groovy语言，所以本文基本都是靠代码来解释，这样最直观，同时也够干货基础入门Groovy的特点和结构。

这里写图片描述

开始介绍前先给一个大法，《官方权威指南》英文好的可以直接略过本文后续内容，我需要的只是Groovy皮毛；再次向Groovy的标志致敬，左手一个Java，右手一个Groovy，不好意思，我技术水平太Low了（T–T__《琅琊榜》看多了！！！）。

这里写图片描述

Groovy是一种动态语言，它和Java类似（算是Java的升级版，但是又具备脚本语言的特点），都在Java虚拟机中运行。当运行Groovy脚本时它会先被编译成Java类字节码，然后通过JVM虚拟机执行这个Java字节码类。

快速安装指南：

安装Groovy在各种Bash下都是通用的，具体如下命令就可搞定：

$ curl -s get.sdkman.io | bash
$ source "$HOME/.sdkman/bin/sdkman-init.sh"
$ sdk install groovy
$ groovy -version
//至此就可以享用了！
1
2
3
4
5
我们在写Groovy代码时可以直接使用自己喜欢的文本编辑器编辑OK以后以.groovy后缀保存，然后在终端执行如下命令即可运行：

$ groovy ./TestFile.groovy
1
或者我们可以通过groovyConsole来进行groovy代码开发运行（由于不需要特别深入学习使用Groovy，所以个人非常喜欢这种模式的开发运行），如下图：

这里写图片描述

再或者我们还可以使用Intellij IDEA等工具安装groovy插件进行groovy开发，这里不再一一叙述了（配置环境点我），直接给出一个读取指定文件内容打印的例子，如下：

这里写图片描述

OK，有了上面这些简单粗暴的基础和环境之后那我们快速开战吧。

【工匠若水 http://blog.csdn.net/yanbober 转载请注明出处。点我开始Android技术交流】

2 语法基础

这里开始我们就来快速简单粗暴的了解一下Groovy语法，其实和Java类似，但也有些区别，下面我们一步一步来看吧，切记对比学习，这才是秘笈。

2-1 注释

Groovy的单行注释、多行注释、文档注释基本都和Java一样，没啥特殊的，不再细说。只有一种特殊的单行注释需要留意一下即可。如下：

#!/usr/bin/env groovy
println "Hello from the shebang line"
1
2
这种注释通常是用来给UNIX系统声明允许脚本运行的类型的，一般都是固定写法，没啥讲究的。

2-2 关键字

Groovy有如下一些关键字，我们些代码命名时要注意：

as、assert、break、case、catch、class、const、continue、def、default、do、else、enum、extends、false、finally、for、goto、if、implements、import、in、instanceof、interface、new、null、package、return、super、switch、this、throw、throws、trait、true、try、while

这玩意和其他语言一样，没啥特殊的，自行脑补。

2-3 标识符

对于Groovy的标示符和Java还是有些共同点和区别的，特别是引用标示符的区别，具体可以往下看。

2-3-1 普通标识符

普通标识符定义和C语言类似，只能以字母、美元符、下划线开始，不能以数字开头。如下例子：

//正确
def name
def $name
def name_type
def foo.assert
//错误
def 5type
def a+b
1
2
3
4
5
6
7
8
2-3-2 引用标识符

引用标识符出现在点后的表达式中，我们可以如下一样使用：

def map = [:]
//引用标示符中出现空格也是对的
map."an identifier with a space and double quotes" = "ALLOWED"
//引用标示符中出现横线也是对的
map.'with-dash-signs-and-single-quotes' = "ALLOWED"

assert map."an identifier with a space and double quotes" == "ALLOWED"
assert map.'with-dash-signs-and-single-quotes' == "ALLOWED"
1
2
3
4
5
6
7
8
当然了，Groovy的所有字符串都可以当作引用标示符定义，如下：

//如下类型字符串作为引用标识符都是对的
map.'single quote'
map."double quote"
map.'''triple single quote'''
map."""triple double quote"""
map./slashy string/
map.$/dollar slashy string/$

//稍微特殊的GString，也是对的
def firstname = "Homer"
map."Simson-${firstname}" = "Homer Simson"

assert map.'Simson-Homer' == "Homer Simson"
1
2
3
4
5
6
7
8
9
10
11
12
13
2-4 字符及字符串

Groovy有java.lang.String和groovy.lang.GString两中字符串对象类型，具体如下细说。

2-4-1 单引号字符串

单引号字符串是java.lang.String类型的，不支持站位符插值操作，譬如：

def name = 'Test Groovy!'
def body = 'Test $name'

assert name == 'Test Groovy!'
assert body == 'Test $name'		//不会替换$name站位符
1
2
3
4
5
Groovy的字符串可以通过”+“直接拼接，譬如：

assert 'ab' == 'a' + 'b'
1
其中涉及转义字符规则同Java，只用特殊注意”’“的转义即可。

2-4-2 三重单引号字符串

三重单引号字符串是java.lang.String类型的，不支持站位符插值操作，可以标示多行字符串，譬如：

def aMultilineString = '''line one
line two
line three'''
1
2
3
三重单引号字符串允许字符串的内容在多行出现，新的行被转换为“\n”，其他所有的空白字符都被完整的按照文本原样保留；字符开头添加“/”表示字符内容不转义反斜杠“\”，只有在反斜杠接下来是一个字符u的时候才需要进行转义，因为\u表示一个unicode转义。如下：

def strippedFirstNewline = '''\
line one
line two
line three
'''

assert !strippedFirstNewline.startsWith('\n')
1
2
3
4
5
6
7
2-4-3 双引号字符串

双引号字符串支持站位插值操作，如果双引号字符串中不包含站位符则是java.lang.String类型的，如果双引号字符串中包含站位符则是groovy.lang.GString类型的。

对于插值占位符我们可以用${}或者$来标示，${}用于一般替代字串或者表达式，$主要用于A.B的形式中，具体如下例子：

def name = 'Guillaume' // a plain string
def greeting = "Hello ${name}"
assert greeting.toString() == 'Hello Guillaume'

def sum = "The sum of 2 and 3 equals ${2 + 3}"
assert sum.toString() == 'The sum of 2 and 3 equals 5'

def person = [name: 'Guillaume', age: 36]
assert "$person.name is $person.age years old" == 'Guillaume is 36 years old'
1
2
3
4
5
6
7
8
9
特别注意，$只对A.B等有效，如果表达式包含括号（像方法调用）、大括号、闭包等符号则是无效的。譬如：

def number = 3.14
shouldFail(MissingPropertyException) {
    println "$number.toString()"
}

//该代码运行抛出groovy.lang.MissingPropertyException异常，因为Groovy认为去寻找number的名为toString的属性，所以异常
1
2
3
4
5
6
注意，在表达式中访问属性前必须保证属性已经定义好(值为空也可以)，如果使用了未定义的属性会抛出groovy.lang.MissingPropertyException异常。 GString还支持延迟运算，譬如在GString中使用闭包，闭包在调用GString的toString()方法时被延迟执行；闭包中可以有0或1个参数，若指定一个参数，则参数会被传入一个Writer对象，我们可以利用这个Writer对象来写入字符，若没有参数，闭包返回值的toString()方法被调用。譬如：

//无参数闭包
def sParameterLessClosure = "1 + 2 == ${-> 3}" 
assert sParameterLessClosure == '1 + 2 == 3'
//一个参数闭包
def sOneParamClosure = "1 + 2 == ${ w -> w << 3}" 
assert sOneParamClosure == '1 + 2 == 3'
1
2
3
4
5
6
上面了解了GString的推迟运算特性，下面我们再来看一个牛逼的特性，如下：

def number = 1 
def eagerGString = "value == ${number}"
def lazyGString = "value == ${ -> number }"

assert eagerGString == "value == 1" 
assert lazyGString ==  "value == 1" 

number = 2 
assert eagerGString == "value == 1" 
assert lazyGString ==  "value == 2" 
1
2
3
4
5
6
7
8
9
10
可以看见，eagerGString是普通的双引号插值站位替换，lazyGString是双引号闭包插值替换，我们可以发现在number变为2以后他们的运算结果就有了差异。可以明显推理到结论，一个普通插值表达式值替换实际是在GString创建的时刻，一个包含闭包的表达式由于延迟运算调运toString()方法，所以会产生一个新的字符串值。

当然了，GString和String即使字符串一样他们的HashCode也不会一样，譬如：

assert "one: ${1}".hashCode() != "one: 1".hashCode()
1
由于相同字符串的String与GString的HashCode不同，所以我们一定要避免使用GString作为MAP的key，譬如：

def key = "a"
def m = ["${key}": "letter ${key}"]     

assert m["a"] == null   //由于key的HashCode不同，所以取不到
1
2
3
4
其中涉及转义字符规则同Java，只用特殊注意””“的转义即可。

2-4-4 多重双引号字符串

多重双引号字符串也支持站位插值操作，我们要特别注意在多重双引号字符串中的单引号和双引号转换问题。譬如：

def name = 'Groovy'
def template = """
    Dear Mr ${name},

    You're the winner of the lottery!

    Yours sincerly,

    Dave
"""

assert template.toString().contains('Groovy')
1
2
3
4
5
6
7
8
9
10
11
12
2-4-5 斜线字符串

斜线字符串其实和双引号字符串很类似，通常用在正则表达式中，下面我们看几个例子，如下：

//普通使用
def fooPattern = /.*foo.*/
assert fooPattern == '.*foo.*'
//含转义字符使用
def escapeSlash = /The character \/ is a forward slash/
assert escapeSlash == 'The character / is a forward slash'
//多行支持
def multilineSlashy = /one
    two
    three/

assert multilineSlashy.contains('\n')
//含站位符使用支持
def color = 'blue'
def interpolatedSlashy = /a ${color} car/

assert interpolatedSlashy == 'a blue car'
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
特别注意，一个空的斜线字符串会被Groovy解析器解析为一注释。

2-4-6 字符Characters

不像Java，Groovy没有明确的Characters。但是我们可以有如下三种不同的方式来将字符串作为字符处理，譬如：

char c1 = 'A' 
assert c1 instanceof Character

def c2 = 'B' as char 
assert c2 instanceof Character

def c3 = (char)'C' 
assert c3 instanceof Character
1
2
3
4
5
6
7
8
2-5 数字Numbers

Groovy支持各种类型的整型和数值类型，通常支持Java支持的那些，下面我们仔细来说说。

2-5-1 整型

Groovy像Java一样支持如下一些整型，byte、char、short、int、long、java.lang.BigInteger。我们在使用中可以像下面例子一样：

// primitive types
byte  b = 1
char  c = 2
short s = 3
int   i = 4
long  l = 5

// infinite precision
BigInteger bi =  6


int xInt = 077
assert xInt == 63

int xInt = 0x77
assert xInt == 119

int xInt = 0b10101111
assert xInt == 175
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
2-5-2 浮点型

Groovy像Java一样支持如下一些浮点型，float、double、java.lang.BigDecimal。我们在使用中可以像下面例子一样：

// primitive types
float  f = 1.234
double d = 2.345

// infinite precision
BigDecimal bd =  3.456


assert 1e3  ==  1_000.0
assert 2E4  == 20_000.0
assert 3e+1 ==     30.0
assert 4E-2 ==      0.04
1
2
3
4
5
6
7
8
9
10
11
12
2-6 Booleans类型

Boolean类型没啥解释的，和其他语言一样，就两个值，如下：

def myBooleanVariable = true
boolean untypedBooleanVar = false
booleanField = true
1
2
3
比较简单，没啥特例，自行脑补。

2-7 Lists类型

Groovy同样支持java.util.List类型，在Groovy中同样允许向列表中增加或者删除对象，允许在运行时改变列表的大小，保存在列表中的对象不受类型的限制；此外还可以通过超出列表范围的数来索引列表。如下例子：

//使用动态List
def numbers = [1, 2, 3]         
assert numbers instanceof List  
assert numbers.size() == 3

//List中存储任意类型
def heterogeneous = [1, "a", true]

//判断List默认类型
def arrayList = [1, 2, 3]
assert arrayList instanceof java.util.ArrayList

//使用as强转类型
def linkedList = [2, 3, 4] as LinkedList    
assert linkedList instanceof java.util.LinkedList

//定义指定类型List
LinkedList otherLinked = [3, 4, 5]          
assert otherLinked instanceof java.util.LinkedList

//定义List使用
def letters = ['a', 'b', 'c', 'd']
//判断item值
assert letters[0] == 'a'     
assert letters[1] == 'b'
//负数下标则从右向左index
assert letters[-1] == 'd'    
assert letters[-2] == 'c'
//指定item赋值判断
letters[2] = 'C'             
assert letters[2] == 'C'
//给List追加item
letters << 'e'               
assert letters[ 4] == 'e'
assert letters[-1] == 'e'
//获取一段List子集
assert letters[1, 3] == ['b', 'd']         
assert letters[2..4] == ['C', 'd', 'e'] 

//多维List支持
def multi = [[0, 1], [2, 3]]     
assert multi[1][0] == 2 
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
2-8 Arrays类型

Groovy中数组和Java类似，具体如下：

//定义初始化String数组
String[] arrStr = ['Ananas', 'Banana', 'Kiwi']  
assert arrStr instanceof String[]    
assert !(arrStr instanceof List)

//使用def定义初始化int数组
def numArr = [1, 2, 3] as int[]      
assert numArr instanceof int[]       
assert numArr.size() == 3

//声明定义多维数组指明宽度
def matrix3 = new Integer[3][3]         
assert matrix3.size() == 3

//声明多维数组不指定宽度
Integer[][] matrix2                     
matrix2 = [[1, 2], [3, 4]]
assert matrix2 instanceof Integer[][]

//数组的元素使用及赋值操作
String[] names = ['Cédric', 'Guillaume', 'Jochen', 'Paul']
assert names[0] == 'Cédric'     
names[2] = 'Blackdrag'          
assert names[2] == 'Blackdrag'
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
2-9 Maps类型

Map是“键-值”对的集合，在Groovy中键key不一定是String，可以是任何对象(实际上Groovy中的Map就是java.util.Linke dHashMap)。如下：

//定义一个Map
def colors = [red: '#FF0000', green: '#00FF00', blue: '#0000FF']   
//获取一些指定key的value进行判断操作
assert colors['red'] == '#FF0000'    
assert colors.green  == '#00FF00'
//给指定key的对赋值value操作与判断    
colors['pink'] = '#FF00FF'           
colors.yellow  = '#FFFF00'           
assert colors.pink == '#FF00FF'
assert colors['yellow'] == '#FFFF00'
//判断Map的类型
assert colors instanceof java.util.LinkedHashMap
//访问Map中不存在的key为null
assert colors.unknown == null

//定义key类型为数字的Map
def numbers = [1: 'one', 2: 'two']
assert numbers[1] == 'one'
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
对于Map需要特别注意一种情况，如下：

//把一个定义的变量作为Map的key，访问Map的该key是失败的
def key = 'name'
def person = [key: 'Guillaume']      
assert !person.containsKey('name')   
assert person.containsKey('key') 

//把一个定义的变量作为Map的key的正确写法---添加括弧，访问Map的该key是成功的
person = [(key): 'Guillaume']        
assert person.containsKey('name')    
assert !person.containsKey('key') 
1
2
3
4
5
6
7
8
9
10
【工匠若水 http://blog.csdn.net/yanbober 转载请注明出处。点我开始Android技术交流】

3 运算符

关于Groovy的运算符介绍类似于上面一样，我们重点突出与Java的不同点，相同点自行脑补。

Groovy支持**次方运算符，如下：

assert  2 ** 3 == 8

def f = 3
f **= 2
assert f == 9
1
2
3
4
5
Groovy非运算符如下：

assert (!true)    == false                      
assert (!'foo')   == false                      
assert (!'')      == true 
1
2
3
Groovy支持?.安全占位符，这个运算符主要用于避免空指针异常，譬如：

def person = Person.find { it.id == 123 }    
def name = person?.name                      
assert name == null  
1
2
3
Groovy支持.@直接域访问操作符，因为Groovy自动支持属性getter方法，但有时候我们有一个自己写的特殊getter方法，当不想调用这个特殊的getter方法则可以用直接域访问操作符。如下：

class User {
    public final String name                 
    User(String name) { this.name = name}
    String getName() { "Name: $name" }       
}
def user = new User('Bob')

assert user.name == 'Name: Bob'
assert user.@name == 'Bob'  
1
2
3
4
5
6
7
8
9
Groovy支持.&方法指针操作符，因为闭包可以被作为一个方法的参数，如果想让一个方法作为另一个方法的参数则可以将一个方法当成一个闭包作为另一个方法的参数。如下：

    def list = ['a','b','c']  
    //常规写法 
    list.each{  
        println it  
    }  

    String printName(name){  
        println name  
    }  

    //方法指针操作符写法
    list.each(this.&printName)  
1
2
3
4
5
6
7
8
9
10
11
12
Groovy支持将?:三目运算符简化为二目，如下：

displayName = user.name ? user.name : 'Anonymous'   
displayName = user.name ?: 'Anonymous' 
1
2
Groovy支持*.展开运算符，一个集合使用展开运算符可以得到一个元素为原集合各个元素执行后面指定方法所得值的集合，如下：

cars = [
   new Car(make: 'Peugeot', model: '508'),
   null,                                              
   new Car(make: 'Renault', model: 'Clio')]
assert cars*.make == ['Peugeot', null, 'Renault']     
assert null*.make == null 
1
2
3
4
5
6
关于Groovy的其他运算符就不多说，类比Java吧。

【工匠若水 http://blog.csdn.net/yanbober 转载请注明出处。点我开始Android技术交流】

4 程序结构

这里主要讨论Groovy的代码组成结构，具体如下细则。

4-1 包名

包名的定义和作用及含义完全和Java一样，不再介绍，如下：

// defining a package named com.yoursite
package com.yoursite
1
2
4-2 Imports引入

常规的imports导包操作和Java一样，如下：

//例1：
import groovy.xml.MarkupBuilder

// using the imported class to create an object
def xml = new MarkupBuilder()
assert xml != null

//例2：
import groovy.xml.*

def markupBuilder = new MarkupBuilder()
assert markupBuilder != null
assert new StreamingMarkupBuilder() != null

//例3：
import static Boolean.FALSE

assert !FALSE

//例4：特殊的，相当于用as取别名
import static Calendar.getInstance as now

assert now().class == Calendar.getInstance().class
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
不过要特别注意，Groovy与Java类似，已经帮我们默认导入了一些常用的包，所以在我们使用这些包的类时就不用再像上面那样导入了，如下是自动导入的包列表：

import java.lang.*
import java.util.*
import java.io.*
import java.net.*
import groovy.lang.*
import groovy.util.*
import java.math.BigInteger
import java.math.BigDecimal
1
2
3
4
5
6
7
8
4-3 脚本与类（脚本的实质）

相对于传统的Java类，一个包含main方法的Groovy类可以如下书写：

class Main {                                    
    static void main(String... args) {          
        println 'Groovy world!'                 
    }
}
1
2
3
4
5
和Java一样，程序会从这个类的main方法开始执行，这是Groovy代码的一种写法，实际上执行Groovy代码完全可以不需要类或main方法，所以更简单的写法如下：

println 'Groovy world!'
1
上面这两中写法其实是一样的，具体我们可以通过如下命令进行编译为class文件：

groovyc demo.groovy //编译Groovy源码为class
1
我们使用反编译工具可以查看到这个demo.groovy类源码如下：

import org.codehaus.groovy.runtime.InvokerHelper
class Main extends Script {                     
    def run() {                                 
        println 'Groovy world!'                 
    }
    static void main(String[] args) {           
        InvokerHelper.runScript(Main, args)     
    }
}
1
2
3
4
5
6
7
8
9
可以看见，上面我们写的groovy文件编译后的class其实是Java类，该类从Script类派生而来（查阅API）；可以发现，每个脚本都会生成一个static main方法，我们执行groovy脚本的实质其实是执行的这个Java类的main方法，脚本源码里所有代码都被放到了run方法中，脚本中定义的方法（该例暂无）都会被定义在Main类中。

通过上面可以发现，Groovy的实质就是Java的class，也就是说他一定会和Java一样存在变量作用域！对哦，前面我们解释变量时竟然没说到这个东东，这里说下吧。看下面例子：

//单个Groovy源码文件，运行会报错找不到num变量
def num = 1 
def printNum(){  
    println num  
}

//单个Groovy源码文件，运行会报错找不到num变量
int num = 1 
def printNum(){  
    println num  
}  

//单个Groovy源码文件，运行OK成功
num = 1 
def printNum(){  
    println num  
}  
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
上面的例子可以发现，我们如果想要在Groovy的方法中使用Groovy的变量则不能有修饰符。然而，如果我们想在B.groovy文件访问A.groovy文件的num变量咋办呢，我们可以使用Field注解，具体操作如下：

import groovy.transform.Field;
@Field num = 1
1
2
哈哈，这就是Groovy的变量作用域了，如果你想知道上面这些写法为啥出错，很简单，自己动手整成Java源码相信你一定可以看懂为啥鸟。

【工匠若水 http://blog.csdn.net/yanbober 转载请注明出处。点我开始Android技术交流】

5 闭包

Groovy的闭包（closure）是一个非常重要的概念，闭包是可以用作方法参数的代码块，Groovy的闭包更象是一个代码块或者方法指针，代码在某处被定义然后在其后的调用处执行。

5-1 语法

定义一个闭包：

{ [closureParameters -> ] statements }

//[closureparameters -> ]是可选的逗号分隔的参数列表，参数类似于方法的参数列表，这些参数可以是类型化或非类型化的。
1
2
3
如下给出几个有效的闭包定义例子：

//最基本的闭包
{ item++ }                                          
//使用->将参数与代码分离
{ -> item++ }                                       
//使用隐含参数it（后面有介绍）
{ println it }                                      
//使用明确的参数it替代
{ it -> println it }                                
//使用显示的名为参数
{ name -> println name }                            
//接受两个参数的闭包
{ String x, int y ->                                
    println "hey ${x} the value is ${y}"
}
//包含一个参数多个语句的闭包
{ reader ->                                         
    def line = reader.readLine()
    line.trim()
}
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
闭包对象：

一个闭包其实就是一个groovy.lang.Closure类型的实例，如下：

//定义一个Closure类型的闭包
def listener = { e -> println "Clicked on $e.source" }      
assert listener instanceof Closure
//定义直接指定为Closure类型的闭包
Closure callback = { println 'Done!' }                      
Closure<Boolean> isTextFile = {
    File it -> it.name.endsWith('.txt')                     
}
1
2
3
4
5
6
7
8
调运闭包：

其实闭包和C语言的函数指针非常像，我们定义好闭包后调用的方法有如下两种形式：

闭包对象.call(参数)

闭包对象(参数)

如下给出例子：

def code = { 123 }
assert code() == 123
assert code.call() == 123

def isOdd = { int i-> i%2 == 1 }                            
assert isOdd(3) == true                                     
assert isOdd.call(2) == false
1
2
3
4
5
6
7
特别注意，如果闭包没定义参数则默认隐含一个名为it的参数，如下例子：

def isEven = { it%2 == 0 }                                  
assert isEven(3) == false                                   
assert isEven.call(2) == true 
1
2
3
5-2 参数

普通参数：

一个闭包的普通参数定义必须遵循如下一些原则：

参数类型可选
参数名字
可选的参数默认值
参数必须用逗号分隔
如下是一些例子：

def closureWithOneArg = { str -> str.toUpperCase() }
assert closureWithOneArg('groovy') == 'GROOVY'

def closureWithOneArgAndExplicitType = { String str -> str.toUpperCase() }
assert closureWithOneArgAndExplicitType('groovy') == 'GROOVY'

def closureWithTwoArgs = { a,b -> a+b }
assert closureWithTwoArgs(1,2) == 3

def closureWithTwoArgsAndExplicitTypes = { int a, int b -> a+b }
assert closureWithTwoArgsAndExplicitTypes(1,2) == 3

def closureWithTwoArgsAndOptionalTypes = { a, int b -> a+b }
assert closureWithTwoArgsAndOptionalTypes(1,2) == 3

def closureWithTwoArgAndDefaultValue = { int a, int b=2 -> a+b }
assert closureWithTwoArgAndDefaultValue(1) == 3
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
隐含参数：

当一个闭包没有显式定义一个参数列表时，闭包总是有一个隐式的it参数。如下：

def greeting = { "Hello, $it!" }
assert greeting('Patrick') == 'Hello, Patrick!'
1
2
上面的类似下面这个例子：

def greeting = { it -> "Hello, $it!" }
assert greeting('Patrick') == 'Hello, Patrick!'
1
2
当然啦，如果你想声明一个不接受任何参数的闭包，且必须限定为没有参数的调用，那么你必须将它声明为一个空的参数列表，如下：

def magicNumber = { -> 42 }
// this call will fail because the closure doesn't accept any argument
magicNumber(11)
1
2
3
可变长参数：

Groovy的闭包支持最后一个参数为不定长可变长度的参数，具体用法如下：

def concat1 = { String... args -> args.join('') }           
assert concat1('abc','def') == 'abcdef'                     
def concat2 = { String[] args -> args.join('') }            
assert concat2('abc', 'def') == 'abcdef'

def multiConcat = { int n, String... args ->                
    args.join('')*n
}
assert multiConcat(2, 'abc','def') == 'abcdefabcdef'
1
2
3
4
5
6
7
8
9
5-3 闭包省略调运

很多方法的最后一个参数都是一个闭包，我们可以在这样的方法调运时进行略写括弧。比如：

def debugClosure(int num, String str, Closure closure){  
      //dosomething  
}  

debugClosure(1, "groovy", {  
   println"hello groovy!"  
})
1
2
3
4
5
6
7
可以看见，当闭包作为闭包或方法的最后一个参数时我们可以将闭包从参数圆括号中提取出来接在最后，如果闭包是唯一的一个参数，则闭包或方法参数所在的圆括号也可以省略；对于有多个闭包参数的，只要是在参数声明最后的，均可以按上述方式省略。

【工匠若水 http://blog.csdn.net/yanbober 转载请注明出处。点我开始Android技术交流】

6 GDK(Groovy Development Kit)

Groovy除了可以直接使用Java的JDK以外还有自己的一套GDK，其实也就是对JDK的一些类的二次封装罢了；一样，这是GDK官方API文档，写代码中请自行查阅。

6-1 I/O操作

Groovy提供了很多IO操作的方法，你可以使用Java的那写IO方法，但是没有Groovy的GDK提供的简单牛逼。

读文件操作：

我们先来看一个例子：


//读文件打印脚本
new File('/home/temp', 'haiku.txt').eachLine { line ->
    println line
}

//读文件打印及打印行号脚本
new File(baseDir, 'haiku.txt').eachLine { line, nb ->
    println "Line $nb: $line"
}
1
2
3
4
5
6
7
8
9
10
可以看见，这是一个读文件打印每行的脚本，eachLine方法是GDK中File的方法，eachLine的参数是一个闭包，这里采用了简写省略括弧。

当然了，有时候你可能更加喜欢用Reader来操作，使用Reader时即使抛出异常也会自动关闭IO。如下：

def count = 0, MAXSIZE = 3
new File(baseDir,"haiku.txt").withReader { reader ->
    while (reader.readLine()) {
        if (++count > MAXSIZE) {
            throw new RuntimeException('Haiku should only have 3 verses')
        }
    }
}
1
2
3
4
5
6
7
8
接着我们再看几个关于读文件的操作使用，如下：

//把读到的文件行内容全部存入List列表中
def list = new File(baseDir, 'haiku.txt').collect {it}
//把读到的文件行内容全部存入String数组列表中
def array = new File(baseDir, 'haiku.txt') as String[]
//把读到的文件内容全部转存为byte数组
byte[] contents = file.bytes

//把读到的文件转为InputStream，切记此方式需要手动关闭流
def is = new File(baseDir,'haiku.txt').newInputStream()
// do something ...
is.close()

//把读到的文件以InputStream闭包操作，此方式不需要手动关闭流
new File(baseDir,'haiku.txt').withInputStream { stream ->
    // do something ...
}
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
上面介绍了一些常用的文件读操作，其它的具体参见API和GDK吧。

写文件操作：

有了上面的读操作，接下来直接看几个写操作的例子得了，如下：

//向一个文件以utf-8编码写三行文字
new File(baseDir,'haiku.txt').withWriter('utf-8') { writer ->
    writer.writeLine 'Into the ancient pond'
    writer.writeLine 'A frog jumps'
    writer.writeLine 'Water’s sound!'
}
//上面的写法可以直接替换为此写法
new File(baseDir,'haiku.txt') << '''Into the ancient pond
A frog jumps
Water’s sound!'''
//直接以byte数组形式写入文件
file.bytes = [66,22,11]
//类似上面读操作，可以使用OutputStream进行输出流操作，记得手动关闭
def os = new File(baseDir,'data.bin').newOutputStream()
// do something ...
os.close()
//类似上面读操作，可以使用OutputStream闭包进行输出流操作，不用手动关闭
new File(baseDir,'data.bin').withOutputStream { stream ->
    // do something ...
}
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
上面介绍了一些常用的文件写操作，其它的具体参见API和GDK吧。

文件树操作：

在脚本环境中，遍历一个文件树是很常见的需求，Groovy提供了多种方法来满足这个需求。如下：

//遍历所有指定路径下文件名打印
dir.eachFile { file ->                      
    println file.name
}
//遍历所有指定路径下符合正则匹配的文件名打印
dir.eachFileMatch(~/.*\.txt/) { file ->     
    println file.name
}
//深度遍历打印名字
dir.eachFileRecurse { file ->                      
    println file.name
}
//深度遍历打印名字，只包含文件类型
dir.eachFileRecurse(FileType.FILES) { file ->      
    println file.name
}
//允许设置特殊标记规则的遍历操作
dir.traverse { file ->
    if (file.directory && file.name=='bin') {
        FileVisitResult.TERMINATE                   
    } else {
        println file.name
        FileVisitResult.CONTINUE                    
    }
}
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
执行外部程序：

Groovy提供一种简单方式来处理执行外部命令行后的输出流操作。如下：

def process = "ls -l".execute()             
println "Found text ${process.text}"
1
2
execute方法返回一个java.lang.Process对象，支持in、out、err的信息反馈。在看一个例子，如下：

def process = "ls -l".execute()             
process.in.eachLine { line ->               
    println line                            
}
1
2
3
4
上面使用闭包操作打印出执行命令行的输入流信息。

6-2 有用的工具类操作

ConfigSlurper配置：

ConfigSlurper是一个配置管理文件读取工具类，类似于Java的*.properties文件，如下：

def config = new ConfigSlurper().parse('''
    app.date = new Date()  
    app.age  = 42
    app {                  
        name = "Test${42}"
    }
''')

assert config.app.date instanceof Date
assert config.app.age == 42
assert config.app.name == 'Test42'
1
2
3
4
5
6
7
8
9
10
11
上面介绍了一些常用的属性配置操作，其它的具体参见API和GDK吧。

Expando扩展：

def expando = new Expando()
expando.toString = { -> 'John' }
expando.say = { String s -> "John says: ${s}" }

assert expando as String == 'John'
assert expando.say('Hi') == 'John says: Hi'
1
2
3
4
5
6
上面介绍了一些常用的拓展操作，其它的具体参见API和GDK吧。

6-2 其他操作

还有很多其他操作，这里就不一一列举，详情参考官方文档即可，譬如JSON处理、XML解析啥玩意的，自行需求摸索吧。

【工匠若水 http://blog.csdn.net/yanbober 转载请注明出处。点我开始Android技术交流】

7 DSL(Domain Specific Languages)领域相关语言

这个就不特殊说明了，只在这里提一下，因为我们前边很多地方已经用过它了，加上我们只是干货基础掌握，所以不做深入探讨。

DSL是一种特定领域的语言（功能领域、业务领域），Groovy是通用的编程语言，所以不是DSL，但是Groovy却对编写全新的DSL提供了很好的支持，这些支持来自于Groovy自身语法的特性，如下：

Groovy不需用定义CLASS类就可以直接执行脚本；

Groovy语法省略括弧和语句结尾分号等操作；

所以说这个基础入门没必要特别深入理解，简单的前面都用过了，理解DSL作用即可，点到为止，详情参考官方文档。

【工匠若水 http://blog.csdn.net/yanbober 转载请注明出处。点我开始Android技术交流】

8 Groovy脚本基础总结

其实没啥总结的，Groovy其实可以当做Java来看待，只是它提供的支持比Java还好而已，在学习Groovy是一定要和Java进行对比学习，这样才能速成基础。