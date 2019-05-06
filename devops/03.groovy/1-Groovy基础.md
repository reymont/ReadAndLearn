Groovy基础 - CSDN博客 https://blog.csdn.net/michael__li/article/details/51475990

Groovy是基于JVM虚拟机的一种动态语言，它的语法和Java非常相似，由Java入门Groovy，基本上没有任何障碍。Groovy完全兼容Java，又在此基础上增加了很多动态类型和灵活的特性，比如支持闭包，支持DSL，可以说它是一门非常灵活的动态脚本语言。

Groovy的特性虽然不多，但也有一些，我们不可能在这里都讲完，这也不是这本书的初衷，在这里我挑一些和Gradle有关的知识讲，让大家很快的入门Groovy，并且能看懂这门脚本语言，知道在Gradle为什么这么写。其次是每个Gradle的build脚本文件都是一个Groovy脚本文件，你可以在里面写任何符合Groovy的代码，比如定义类，生命函数，定义变量等等，而Groovy又完全兼容Java，这就意味着你可以在build脚本文件里写任何的Java代码，非常灵活方便。

字符串

字符串，每一门语言都会有对字符串的处理，Java相对要稍微复杂一些，限制比较多，相比而言，Groovy非常方便，比如字符串的运算、求值、正则等等。

从现在开始我们算是正式的介绍Groovy了，在此之前我们先要知道，在Groovy中，分号不是必须的。相信很多用Java的朋友都习惯了，没一行的结束必须有分号，但是Groovy每这个强制规定，所以你看到的Gradle脚本很多都没有分号，其实这个是Groovy的特性，而不是Gradle的。没有分号的时候，我们阅读的时候没一行默认为有分号就好了。

在Groovy中，单引号和双引号都可以定义一个字符串常量（Java里单引号定义一个字符），不同的是单引号标记的是纯粹的字符串常量，而不是对字符串里的表达式做运算，但是双引号可以。

task printStringClass << {
    defstr1 = '单引号'
    defstr2 = "双引号"

    println"单引号定义的字符串类型:"+str1.getClass().name
    println"双引号定义的字符串类型:"+str2.getClass().name
}

./gradlew printStringClass运行后我们能可以看到输出：

单引号定义的字符串类型:java.lang.String
双引号定义的字符串类型:java.lang.String
1
2
不管是单引号定义的还是双引号定义的都是String类型。 
刚刚我们讲了单引号不能对字符串里的表达式做运算，下面我们看个例子：

task printStringVar << {
    defname = "张三"

    println'单引号的变量计算:${name}'
    println"单引号的变量计算:${name}"
}
1
2
3
4
5
6
./gradlew printStringVar运行后输出：

单引号的变量计算:${name}
单引号的变量计算:张三
1
2
可以看到，双引号标记的输出了我们想要的结果，但是单引号没有，所以大家可以记住了，单引号没有运算的能力，它里面的所有都是常量字符串。

双引号可以直接进行表达式计算的这个能力非常好用，我们可以用这种方式进行字符串链接运算，再也不用Java中繁琐的+号了。记住这个嵌套的规则，一个美元符号紧跟着一对花括号，花括号里放表达式，比如name,name,{1+1}等等，只有一个变量的时候可以省略花括号，比如$name。

集合

集合，也是我们在Java中经常用到的，Groovy完全兼容了Java的集合，并且进行了扩展，使得生命一个集合，迭代一个集合、查找集合的元素等等操作变得非常容易。常见的集合有List、Set、Map和Queue，这里我们只介绍常用的List和Map。

List

在Java里，定义一个List，需要New一个实现了List接口的类，太繁琐，在Groovy中则非常简单。

task printList << {
    def numList =[1,2,3,4,5,6];
    println numList.getClass().name

}
1
2
3
4
5
可以通过输出看到numList是一个ArrayList类型。

定义好集合了，怎么访问它里面的元素呢，像Java一样，使用get方法？太Low了，Groovy提供了非常简便的方法。

task printList << {
    def numList =[1,2,3,4,5,6];
    println numList.getClass().name

    println numList[1]//访问第二个元素
    println numList[-1]//访问最后一个元素
    println numList[-2]//访问倒数第二个元素
    println numList[1..3]//访问第二个到第四个元素
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
Groovy提供下标索引的方式访问，就像数组一样，除此之外，还提供了负下标和范围索引。负下标索引代表从右边开始数，-1就代表从右侧数第一个，-2代表右侧数第二个，以此类推；1..3这种是一个范围索引，中间用两个.分开，这个会经常遇到。

除了访问方便之外，Groovy还为List提供了非常方便的迭代操作，这就是each方法，该方法接受一个闭包作为参数，可以访问List里的每个元素。

task printList << {
    def numList =[1,2,3,4,5,6];
    println numList.getClass().name

    println numList[1]//访问第二个元素
    println numList[-1]//访问最后一个元素
    println numList[-2]//访问倒数第二个元素
    println numList[1..3]//f访问第二个到第四个元素

    numList.each {
        println it
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
it变量就是正在迭代的元素，这里有闭包的知识，我们可以先这么记住，后面详细讲。

Map

Map和List很像，只不过它的值是一个K:V键值对，所以在Groovy中Map的定义也非常简单。

task printlnMap << {
    def map1 =['width':1024,'height':768]
    println map1.getClass().name
}
1
2
3
4
访问也非常灵活容易，采用map[key]或者map.key的方式都可以。

task printlnMap << {
    def map1 =['width':1024,'height':768]
    println map1.getClass().name

    println map1['width']
    println map1.height
}
1
2
3
4
5
6
7
这两种方式都能快速的取出指定key的值，怎么样，比Java方便的多吧。

对于Map的迭代，当然也少不了each方法，只不过被迭代的元素是一个Map.Entry的实例。

task printlnMap << {
    def map1 =['width':1024,'height':768]
    println map1.getClass().name

    println map1['width']
    println map1.height

    map1.each {
        println "Key:${it.key},Value:${it.value}"
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
对于集合，Groovy还提供了诸如collect、find、findAll等便捷的方法，有兴趣的朋友可以找相关文档看一下，这里就不一一讲了。

方法

方法大家都不陌生，这里特别用一节讲的目的主要是讲Groovy方法和Java的不同，然后我们才能看明白我们的Gradle脚本里的代码，突然发现，原来这是一个方法调用啊！

括号是可以省略的

我们在Java中调用一个方法都是invokeMethod(parm1,parm2)，非常规范，Java就是这么中规中矩的语言，在Groovy中就要灵活的多，可以省略()变成这样invokeMethod parm1，parm2 是不是觉得非常简洁，这在定义DSL的时候非常有用，书写也非常方便。

task invokeMethod << {
    method1(1,2)
    method1 1,2
}

def method1(int a,int b){
    println a+b
}
1
2
3
4
5
6
7
8
上例中这两种调用方式的结果是一样的，有没有觉得第二种更简洁的多，Gradle中的方法调用都是这种写法。

return是可以不写的

在Groovy中，我们定义有返回值的方法时，return语句不是必须的，当没有return的时候，Groovy会把方法执行过程中的最后一句代码作为其返回值。

task printMethodReturn << {
    def add1 = method2 1,2
    def add2 = method2 5,3
    println "add1:${add1},add2:${add2}"
}

def method2(int a,int b){
    if(a>b){
        a
    }else{
        b
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
执行./gradlew printMethodReturn后可以看到输出：

add1:2,add2:5
1
从例子中可以看出，当a作为最后一行被执行的代码时，a就是该方法的返回值，反之则是b。

代码块是可以作为参数传递的

代码块–一段被花括号包围的代码，其实就是我们后面要将的闭包，Groovy是允许其作为参数传递的，但是结合这我们上面方法的特性，最后的基于闭包的方法调用就会非常优雅、易读。以我们的集合的each方法为例，它接受的参数其实就是一个闭包。

//基于死板的写法其实是这样
numList.each({println it})
//我们格式化一下，是不是好看一些
numList.each({
    println it
})
//好看一些，Groovy规定，如果方法的最后一个参数是闭包，可以放到方法外面
numList.each(){
    println it
}
//然后方法可以省略，就变成我们经常看到的啦
numList.each {
    println it
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
了解了这个演进方式，你再看到类似的这样的写法就明白了，原来是一个方法调用，以此类推，你也知道怎么定义一个方法，让别人这么调用。

JavaBean

JavaBean是一个非常好的概念，你现在看到的组件化、插件化、配置集成等都是基于JavaBean。在Java中为了访问和修改JavaBean的属性，我们不得不重复的生成getter/setter方法，并且使用他们，太麻烦，太繁琐，这在Groovy中得到很大的改善。

task helloJavaBean << {
    Person p = new Person()

    println "名字是：${p.name}"
    p.name = "张三"
    println "名字是：${p.name}"
}

class Person {
    private String name
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
在没有给name属性赋值的时候，输出是null，赋值后，输出的就是“张三”了，通过上面例子，我们发现，我们在Groovy可以非常容易的访问和修改JavaBean的属性值，而不用借助getter/setter方法，这是因为Groovy都帮我们搞定了。

在Groovy中，并不是一定要定义成员变量，才能作为类的属性访问，我们直接getter/setter方法，也一样可以当做属性访问。

task helloJavaBean << {
    Person p = new Person()

    println "名字是：${p.name}"
    p.name = "张三"
    println "名字是：${p.name}"
    println "年龄是：${p.age}"
}

class Person {
    private String name

    public int getAge(){
        12
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
通过上面的例子我们可以发现，我并没有定义一个age的成员变量，但是我一样可以通过p.age获取到该值，这是因为我们定义了getAge()方法。那么这时候我们能不能修改age的值呢？答案是不能的，因为我们没有为其定义setter方法。

在Gradle中你会见到很多这种写法，你开始以为这是该对象的一个属性，其实只是因为该对象里定义了相应的getter/setter方法而已。

闭包

闭包是Groovy的一个非常重要的特性，可以说他是DSL的基础。闭包不是Groovy的首创，但是它支持这一重要特性，这就使用我们的代码灵活、轻量、可复用，再也不用像Java一样动不动就要搞一个类了，虽然Java后来有了匿名内部类，但是一样冗余不灵活。

初识闭包

前面我们讲过，闭包其实就是一段代码块，下面我们就一步步实现自己的闭包，了解闭包的it变量的由来。集合的each方法我们已经非常熟悉了，我们就以其为例，实现一个类似的闭包功能。

task helloClosure << {
    //使用我们自定义的闭包
    customEach {
        println it
    }
}

def customEach(closure){
    //模拟一个有10个元素的集合，开始迭代
    for(int i in 1..10){
        closure(i)
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
在上面的例子中我们定义了一个方法customEach，它只有一个参数，用于接收一个闭包（代码块），那么这个闭包如何执行呢？很简单，跟一对括号就是执行了，会JavaScript的朋友是不是觉得很熟悉，把它当做一个方法调用，括号里的参数就是该闭包接收的参数，如果只有一个参数，那么就是我们的it变量了。

向闭包传递参数

上一节我们讲了，当闭包有一个参数时，默认就是it；当有多个参数是，it就不能表示了，我们需要把参数一一列出。

task helloClosure << {
    //多个参数
    eachMap {k,v ->
        println "${k} is ${v}"
    }
}

def eachMap(closure){
    def map1 = ["name":"张三","age":18]
    map1.each {
        closure(it.key,it.value)
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
从例子中我们可以看到，我们为闭包传递了两个参数，一个key，一个value，便于我们演示。这是我们我们就不能使用it了，必须要显式的声明出来，如例子中的k，v，符号->用于把闭包的参数和主体区分开来。

闭包委托

Groovy闭包的强大之处在于它支持闭包方法的委托。Groovy的闭包有thisObject、owner、delegate三个属性，当你在闭包内调用方法时，由他们来确定使用哪个对象来处理。默认情况下delegate和owner是相等的，但是delegate是可以被修改的，这个功能是非常强大的，Gradle中的很闭包的很多功能都是通过修改delegate实现的。

task helloDelegate << {
    new Delegate().test {
        println "thisObject:${thisObject.getClass()}"
        println "owner:${owner.getClass()}"
        println "delegate:${delegate.getClass()}"
        method1()
        it.method1()
    }
}

def method1(){
    println "Context this:${this.getClass()} in root"
    println "method1 in root"
}
class Delegate {
    def method1(){
        println "Delegate this:${this.getClass()} in Delegate"
        println "method1 in Delegate"
    }

    def test(Closure<Delegate> closure){
        closure(this)
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
运行我们可以看到输出：

thisObject:class build_e27c427w88bo0afju9niqltzf
owner:class build_e27c427w88bo0afju9niqltzf$_run_closure2
delegate:class build_e27c427w88bo0afju9niqltzf$_run_closure2
this:class build_e27c427w88bo0afju9niqltzf in root
method1 in root
this:class Delegate in Delegate
method1 in Delegate
1
2
3
4
5
6
7
通过上面的例子我们发现，thisObject的优先级最高，默认情况下，优先使用thisObject来处理闭包中调用的方法，如果有则执行。从输出中我们也可以看到这个thisObject其实就是这个构建脚本的上下文，他和脚本中的this对象是相等的。

从例子中也证明了delegate和owner是相等的，他们两个的优先级是owner要比delegate高，所以对于闭包内方法的处理顺序是thisObject>owner>delegate。

在DSL中，比如Gradle，我们一般会指定delegate为当前的it，这样我们在闭包内就可以对该it进行配置，或者调用其方法。

task configClosure << {
    person {
        personName = "张三"
        personAge = 20
        dumpPerson()
    }
}

class Person {
    String personName
    int personAge

    def dumpPerson(){
        println "name is ${personName},age is ${personAge}"
    }
}

def person(Closure<Person> closure){
    Person p = new Person();
    closure.delegate = p
    //委托模式优先
    closure.setResolveStrategy(Closure.DELEGATE_FIRST);
    closure(p)
}

例子中我们设置了委托对象为当前创建的Person实例，并且设置了委托模式优先，所以我们在试用person方法创建一个Person的实例时，可以在闭包里直接对该Person实例配置，有没有发现和我们在Gradle试用task创建一个Task的用法很像，其实在Gradle中有很多类似的用法，在Gradle也基本上都是使用delegate的方式使用闭包进行配置等操作。

DSL

DSL(Domain Specific Language),领域特定语言，说白了就是专门关注某一领域专门语言，在于专，而不是全，所以才叫领域特定的，而不是像Java这种通用全面的语言。

Gradle就是一门DSL，他是基于Groovy的，专门解决自动化构建的DSL。自动化构建太复杂、太麻烦、太专业，我们理解不了，没问题，专家们就开发了DSL–Gradle，我们作为开发者只要按照Gradle DSL定义的，书写相应的Gradle脚本就可以达到我们自动化构建的目的，这也是DSL的初衷。

DSL涉及的东西还有很多，这里我们简单的提一下概念，让大家有个了解，关于这方便更详细的可以阅读世界级软件开发大师Martin Fowler的《领域特定语言》，这本书介绍的非常详细。