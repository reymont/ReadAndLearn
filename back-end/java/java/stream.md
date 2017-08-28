
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [Java8初体验（一）lambda表达式语法 | 并发编程网 – ifeve.com](#java8初体验一lambda表达式语法-并发编程网-ifevecom)
* [Java8初体验（二）Stream语法详解 | 并发编程网 – ifeve.com](#java8初体验二stream语法详解-并发编程网-ifevecom)
* [【译】Java 8的新特性—终极版 - 简书](#译java-8的新特性终极版-简书)
* [Java 8: joining strings with Stream API | Developer writing about stuff](#java-8-joining-strings-with-stream-api-developer-writing-about-stuff)

<!-- /code_chunk_output -->





# Java8初体验（一）lambda表达式语法 | 并发编程网 – ifeve.com 
http://ifeve.com/lambda/

感谢同事【天锦】的投稿。投稿请联系 tengfei@ifeve.com
本文主要记录自己学习Java8的历程，方便大家一起探讨和自己的备忘。因为本人也是刚刚开始学习Java8，所以文中肯定有错误和理解偏差的地方，希望大家帮忙指出，我会持续修改和优化。本文是该系列的第一篇，主要介绍Java8对屌丝码农最有吸引力的一个特性—lambda表达式。
java8的安装
工欲善其器必先利其器，首先安装JDK8。过程省略，大家应该都可以自己搞定。但是有一点这里强调一下（Windows系统）：目前我们工作的版本一般是java 6或者java 7，所以很多人安装java8基本都是学习为主。这样就在自己的机器上会存在多版本的JDK。而且大家一般是希望在命令行中执行java命令是基于老版本的jdk。但是在安装完jdk8并且没有设置path的情况下，你如果在命令行中输入：java -version，屏幕上会显示是jdk 8。这是因为jdk8安装的时候，会默认在C:/Windows/System32中增加java.exe，这个调用的优先级比path设置要高。所以即使path里指定是老版本的jdk，但是执行java命令显示的依然是新版本的jdk。这里我们要做的就是删除C:/Windows/System32中的java.exe文件（不要手抖！）。
Lambda初体验
下面进入本文的正题–lambda表达式。首先我们看一下什么是lambda表达式。以下是维基百科上对于”Lambda expression”的解释：
 a function (or a subroutine) defined, and possibly called, without being bound to an identifier。
简单点说就是：一个不用被绑定到一个标识符上，并且可能被调用的函数。这个解释还不够通俗，lambda表达式可以这样定义（不精确，自己的理解）：一段带有输入参数的可执行语句块。这样就比较好理解了吧？一例胜千言。有读者反馈：不理解Stream的含义，所以这里先提供一个没用stream的lambda表达式的例子。
1	//这里省略list的构造
2	List<String> names = ...;
3	Collections.sort(names, (o1, o2) -> o1.compareTo(o2));
 
1	//这里省略list的构造
2	List<String> names = ...;
3	Collections.sort(names, new Comparator<String>() {
4	  @Override
5	  public int compare(String o1, String o2) {
6	    return o1.compareTo(o2);
7	  }
8	});
上面两段代码分别是：使用lambda表达式来排序和使用匿名内部类来排序。这个例子可以很明显的看出lambda表达式简化代码的效果。接下来展示lambda表达式和其好基友Stream的配合。
1	List<String> names = new ArrayList<>();
2	names.add("TaoBao");
3	names.add("ZhiFuBao");
4	List<String> lowercaseNames = names.stream().map((String name) -> {returnname.toLowerCase();}).collect(Collectors.toList());
这段代码就是对一个字符串的列表，把其中包含的每个字符串都转换成全小写的字符串（熟悉Groovy和Scala的同学肯定会感觉很亲切）。注意代码第四行的map方法调用，这里map方法就是接受了一个lambda表达式（其实是一个java.util.function.Function的实例，后面会介绍）。
为什么需要Lambda表达式呢？在尝试回答这个问题之前，我们先看看在Java8之前，如果我们想做上面代码的操作应该怎么办。
先看看普通青年的代码：
1	List<String> names = new ArrayList<>();
2	names.add("TaoBao");
3	names.add("ZhiFuBao");
4	List<String> lowercaseNames = new ArrayList<>();
5	for (String name : names) {
6	  lowercaseNames.add(name.toLowerCase());
7	}
接下来看看文艺青年的代码（借助Guava）：
1	List<String> names = new ArrayList<>();
2	names.add("TaoBao");
3	names.add("ZhiFuBao");
4	List<String> lowercaseNames = FluentIterable.from(names).transform(newFunction<String, String>() {
5	  @Override
6	  public String apply(String name) {
7	    return name.toLowerCase();
8	  }
9	}).toList();
在此，我们不再讨论普通青年和文艺青年的代码风格孰优孰劣（有兴趣的可以去google搜索“命令式编程vs声明式编程”）。本人更加喜欢声明式的编程风格，所以偏好文艺青年的写法。但是在文艺青年代码初看起来看起来干扰信息有点多，Function匿名类的构造语法稍稍有点冗长。所以Java8的lambda表达式给我们提供了创建SAM（Single Abstract Method）接口更加简单的语法糖。

Lambda语法详解
我们在此抽象一下lambda表达式的一般语法：
1	(Type1 param1, Type2 param2, ..., TypeN paramN) -> {
2	  statment1;
3	  statment2;
4	  //.............
5	  return statmentM;
6	}
从lambda表达式的一般语法可以看出来，还是挺符合上面给出的非精确版本的定义–“一段带有输入参数的可执行语句块”。
上面的lambda表达式语法可以认为是最全的版本，写起来还是稍稍有些繁琐。别着急，下面陆续介绍一下lambda表达式的各种简化版：
1. 参数类型省略–绝大多数情况，编译器都可以从上下文环境中推断出lambda表达式的参数类型。这样lambda表达式就变成了：
1	(param1,param2, ..., paramN) -> {
2	  statment1;
3	  statment2;
4	  //.............
5	  return statmentM;
6	}
所以我们最开始的例子就变成了（省略了List的创建）：
1	List<String> lowercaseNames = names.stream().map((name) -> {returnname.toLowerCase();}).collect(Collectors.toList());
2. 当lambda表达式的参数个数只有一个，可以省略小括号。lambda表达式简写为：
1	param1 -> {
2	  statment1;
3	  statment2;
4	  //.............
5	  return statmentM;
6	}
所以最开始的例子再次简化为：
1	List<String> lowercaseNames = names.stream().map(name -> {returnname.toLowerCase();}).collect(Collectors.toList());
3. 当lambda表达式只包含一条语句时，可以省略大括号、return和语句结尾的分号。lambda表达式简化为：
1	param1 -> statment
所以最开始的例子再次简化为：
1	List<String> lowercaseNames = names.stream().map(name -> name.toLowerCase()).collect(Collectors.toList());
4. 使用Method Reference(具体语法后面介绍)
1	//注意，这段代码在Idea 13.0.2中显示有错误，但是可以正常运行
2	List<String> lowercaseNames = names.stream().map(String::toLowerCase).collect(Collectors.toList());
Lambda表达式眼中的外部世界
我们前面所有的介绍，感觉上lambda表达式像一个闭关锁国的家伙，可以访问给它传递的参数，也能自己内部定义变量。但是却从来没看到其访问它外部的变量。是不是lambda表达式不能访问其外部变量？我们可以这样想：lambda表达式其实是快速创建SAM接口的语法糖，原先的SAM接口都可以访问接口外部变量，lambda表达式肯定也是可以（不但可以，在java8中还做了一个小小的升级，后面会介绍）。
1	String[] array = {"a", "b", "c"};
2	for(Integer i : Lists.newArrayList(1,2,3)){
3	  Stream.of(array).map(item -> Strings.padEnd(item, i,'@')).forEach(System.out::println);
4	}
上面的这个例子中，map中的lambda表达式访问外部变量Integer i。并且可以访问外部变量是lambda表达式的一个重要特性，这样我们可以看出来lambda表达式的三个重要组成部分：
•	输入参数
•	可执行语句
•	存放外部变量的空间
不过lambda表达式访问外部变量有一个非常重要的限制：变量不可变（只是引用不可变，而不是真正的不可变）。
1	String[] array = {"a", "b", "c"};
2	for(int i = 1; i<4; i++){
3	  Stream.of(array).map(item -> Strings.padEnd(item, i,'@')).forEach(System.out::println);
4	}
上面的代码，会报编译错误。因为变量i被lambda表达式引用，所以编译器会隐式的把其当成final来处理（ps：大家可以想象问什么上一个例子不报错，而这个报错。）细心的读者肯定会发现不对啊，以前java的匿名内部类在访问外部变量的时候，外部变量必须用final修饰。Bingo，在java8对这个限制做了优化（前面说的小小优化），可以不用显示使用final修饰，但是编译器隐式当成final来处理。
lambda眼中的this
在lambda中，this不是指向lambda表达式产生的那个SAM对象，而是声明它的外部对象。
方法引用（Method reference）和构造器引用（construct reference）
方法引用
前面介绍lambda表达式简化的时候，已经看过方法引用的身影了。方法引用可以在某些条件成立的情况下，更加简化lambda表达式的声明。方法引用语法格式有以下三种：
•	objectName::instanceMethod
•	ClassName::staticMethod
•	ClassName::instanceMethod
前两种方式类似，等同于把lambda表达式的参数直接当成instanceMethod|staticMethod的参数来调用。比如System.out::println等同于x->System.out.println(x)；Math::max等同于(x, y)->Math.max(x,y)。
最后一种方式，等同于把lambda表达式的第一个参数当成instanceMethod的目标对象，其他剩余参数当成该方法的参数。比如String::toLowerCase等同于x->x.toLowerCase()。
构造器引用
构造器引用语法如下：ClassName::new，把lambda表达式的参数当成ClassName构造器的参数 。例如BigDecimal::new等同于x->new BigDecimal(x)。
吐槽一下方法引用
表面上看起来方法引用和构造器引用进一步简化了lambda表达式的书写，但是个人觉得这方面没有Scala的下划线语法更加通用。比较才能看出，翠花，上代码！
1	List<String> names = new ArrayList<>();
2	names.add("TaoBao");
3	names.add("ZhiFuBao");
4	names.stream().map(name -> name.charAt(0)).collect(Collectors.toList());
上面的这段代码就是给定一个String类型的List，获取每个String的首字母，并将其组合成新的List。这段代码就没办法使用方法引用来简化。接下来，我们简单对比一下Scala的下划线语法（不必太纠结Scala的语法，这里只是做个对比）：
1	//省略List的初始化
2	List[String] names = ....
3	names.map(_.charAt(0))
在Scala中基本不用写lambda表达式的参数声明。
下期预告
Java8初体（二）Sream语法详解
引用文档
1.	《Java SE 8 for the Really Impatient》
2.	Java 8 Tutorial
3.	Java 8 API doc




# Java8初体验（二）Stream语法详解 | 并发编程网 – ifeve.com 
http://ifeve.com/stream/


Java8初体验（二）Stream语法详解
感谢同事【天锦】的投稿。投稿请联系 tengfei@ifeve.com
上篇文章Java8初体验（一）lambda表达式语法比较详细的介绍了lambda表达式的方方面面，细心的读者会发现那篇文章的例子中有很多Stream的例子。这些Stream的例子可能让你产生疑惑，本文将会详细讲解Stream的使用方法（不会涉及Stream的原理，因为这个系列的文章还是一个快速学习如何使用的）。

1. Stream初体验
我们先来看看Java里面是怎么定义Stream的：
A sequence of elements supporting sequential and parallel aggregate operations.
我们来解读一下上面的那句话：
1.	Stream是元素的集合，这点让Stream看起来用些类似Iterator；
2.	可以支持顺序和并行的对原Stream进行汇聚的操作；
大家可以把Stream当成一个高级版本的Iterator。原始版本的Iterator，用户只能一个一个的遍历元素并对其执行某些操作；高级版本的Stream，用户只要给出需要对其包含的元素执行什么操作，比如“过滤掉长度大于10的字符串”、“获取每个字符串的首字母”等，具体这些操作如何应用到每个元素上，就给Stream就好了！（这个秘籍，一般人我不告诉他：））大家看完这些可能对Stream还没有一个直观的认识，莫急，咱们来段代码。
1	//Lists是Guava中的一个工具类
2	List<Integer> nums = Lists.newArrayList(1,null,3,4,null,6);
3	nums.stream().filter(num -> num != null).count();
上面这段代码是获取一个List中，元素不为null的个数。这段代码虽然很简短，但是却是一个很好的入门级别的例子来体现如何使用Stream，正所谓“麻雀虽小五脏俱全”。我们现在开始深入解刨这个例子，完成以后你可能可以基本掌握Stream的用法！
1.1 剖析Stream通用语法
 
图片就是对于Stream例子的一个解析，可以很清楚的看见：原本一条语句被三种颜色的框分割成了三个部分。红色框中的语句是一个Stream的生命开始的地方，负责创建一个Stream实例；绿色框中的语句是赋予Stream灵魂的地方，把一个Stream转换成另外一个Stream，红框的语句生成的是一个包含所有nums变量的Stream，进过绿框的filter方法以后，重新生成了一个过滤掉原nums列表所有null以后的Stream；蓝色框中的语句是丰收的地方，把Stream的里面包含的内容按照某种算法来汇聚成一个值，例子中是获取Stream中包含的元素个数。如果这样解析以后，还不理解，那就只能动用“核武器”–图形化，一图抵千言！
 
在此我们总结一下使用Stream的基本步骤：
1.	创建Stream；
2.	转换Stream，每次转换原有Stream对象不改变，返回一个新的Stream对象（**可以有多次转换**）；
3.	对Stream进行聚合（Reduce）操作，获取想要的结果；
2. 创建Stream
最常用的创建Stream有两种途径：
1.	通过Stream接口的静态工厂方法（注意：Java8里接口可以带静态方法）；
2.	通过Collection接口的默认方法（默认方法：Default method，也是Java8中的一个新特性，就是接口中的一个带有实现的方法，后续文章会有介绍）–stream()，把一个Collection对象转换成Stream
2.1 使用Stream静态方法来创建Stream
1. of方法：有两个overload方法，一个接受变长参数，一个接口单一值
1	Stream<Integer> integerStream = Stream.of(1, 2, 3, 5);
2	Stream<String> stringStream = Stream.of("taobao");
2. generator方法：生成一个无限长度的Stream，其元素的生成是通过给定的Supplier（这个接口可以看成一个对象的工厂，每次调用返回一个给定类型的对象）
1	Stream.generate(new Supplier<Double>() {
2	    @Override
3	    public Double get() {
4	        return Math.random();
5	    }
6	});
7	Stream.generate(() -> Math.random());
8	Stream.generate(Math::random);
三条语句的作用都是一样的，只是使用了lambda表达式和方法引用的语法来简化代码。每条语句其实都是生成一个无限长度的Stream，其中值是随机的。这个无限长度Stream是懒加载，一般这种无限长度的Stream都会配合Stream的limit()方法来用。
3. iterate方法：也是生成无限长度的Stream，和generator不同的是，其元素的生成是重复对给定的种子值(seed)调用用户指定函数来生成的。其中包含的元素可以认为是：seed，f(seed),f(f(seed))无限循环
1	Stream.iterate(1, item -> item + 1).limit(10).forEach(System.out::println);
这段代码就是先获取一个无限长度的正整数集合的Stream，然后取出前10个打印。千万记住使用limit方法，不然会无限打印下去。
2.2 通过Collection子类获取Stream
这个在本文的第一个例子中就展示了从List对象获取其对应的Stream对象，如果查看Java doc就可以发现Collection接口有一个stream方法，所以其所有子类都都可以获取对应的Stream对象。
1	public interface Collection<E> extends Iterable<E> {
2	    //其他方法省略
3	    default Stream<E> stream() {
4	        return StreamSupport.stream(spliterator(), false);
5	    }
6	}
3. 转换Stream
转换Stream其实就是把一个Stream通过某些行为转换成一个新的Stream。Stream接口中定义了几个常用的转换方法，下面我们挑选几个常用的转换方法来解释。
1. distinct: 对于Stream中包含的元素进行去重操作（去重逻辑依赖元素的equals方法），新生成的Stream中没有重复的元素；
distinct方法示意图(**以下所有的示意图都要感谢[RxJava](https://github.com/Netflix/RxJava)项目的doc中的图片给予的灵感, 如果示意图表达的有错误和不准确的地方，请直接联系我。**)：
 
2. filter: 对于Stream中包含的元素使用给定的过滤函数进行过滤操作，新生成的Stream只包含符合条件的元素；
filter方法示意图：
 
3. map: 对于Stream中包含的元素使用给定的转换函数进行转换操作，新生成的Stream只包含转换生成的元素。这个方法有三个对于原始类型的变种方法，分别是：mapToInt，mapToLong和mapToDouble。这三个方法也比较好理解，比如mapToInt就是把原始Stream转换成一个新的Stream，这个新生成的Stream中的元素都是int类型。之所以会有这样三个变种方法，可以免除自动装箱/拆箱的额外消耗；
map方法示意图：
 
4. flatMap：和map类似，不同的是其每个元素转换得到的是Stream对象，会把子Stream中的元素压缩到父集合中；
flatMap方法示意图：
 
5. peek: 生成一个包含原Stream的所有元素的新Stream，同时会提供一个消费函数（Consumer实例），新Stream每个元素被消费的时候都会执行给定的消费函数；
peek方法示意图：
 
6. limit: 对一个Stream进行截断操作，获取其前N个元素，如果原Stream中包含的元素个数小于N，那就获取其所有的元素；
limit方法示意图：
 
7. skip: 返回一个丢弃原Stream的前N个元素后剩下元素组成的新Stream，如果原Stream中包含的元素个数小于N，那么返回空Stream；
skip方法示意图：
 
8. 在一起,在一起！
1	List<Integer> nums = Lists.newArrayList(1,1,null,2,3,4,null,5,6,7,8,9,10);
2	System.out.println(“sum is:”+nums.stream().filter(num -> num != null).
3	            distinct().mapToInt(num -> num * 2).
4	            peek(System.out::println).skip(2).limit(4).sum());
这段代码演示了上面介绍的所有转换方法（除了flatMap），简单解释一下这段代码的含义：给定一个Integer类型的List，获取其对应的Stream对象，然后进行过滤掉null，再去重，再每个元素乘以2，再每个元素被消费的时候打印自身，在跳过前两个元素，最后去前四个元素进行加和运算(解释一大堆，很像废话，因为基本看了方法名就知道要做什么了。这个就是声明式编程的一大好处！)。大家可以参考上面对于每个方法的解释，看看最终的输出是什么。
9. 性能问题
有些细心的同学可能会有这样的疑问：在对于一个Stream进行多次转换操作，每次都对Stream的每个元素进行转换，而且是执行多次，这样时间复杂度就是一个for循环里把所有操作都做掉的N（转换的次数）倍啊。其实不是这样的，转换操作都是lazy的，多个转换操作只会在汇聚操作（见下节）的时候融合起来，一次循环完成。我们可以这样简单的理解，Stream里有个操作函数的集合，每次转换操作就是把转换函数放入这个集合中，在汇聚操作的时候循环Stream对应的集合，然后对每个元素执行所有的函数。
4. 汇聚（Reduce）Stream
汇聚这个词，是我自己翻译的，如果大家有更好的翻译，可以在下面留言。在官方文档中是reduce，也叫fold。
在介绍汇聚操作之前，我们先看一下Java doc中对于其定义：
A reduction operation (also called a fold) takes a sequence of input elements and combines them into a single summary result by repeated application of a combining operation, such as finding the sum or maximum of a set of numbers, or accumulating elements into a list. The streams classes have multiple forms of general reduction operations, called reduce() and collect(), as well as multiple specialized reduction forms such as sum(), max(), or count().
简单翻译一下：汇聚操作（也称为折叠）接受一个元素序列为输入，反复使用某个合并操作，把序列中的元素合并成一个汇总的结果。比如查找一个数字列表的总和或者最大值，或者把这些数字累积成一个List对象。Stream接口有一些通用的汇聚操作，比如reduce()和collect()；也有一些特定用途的汇聚操作，比如sum(),max()和count()。注意：sum方法不是所有的Stream对象都有的，只有IntStream、LongStream和DoubleStream是实例才有。
下面会分两部分来介绍汇聚操作：
1.	可变汇聚：把输入的元素们累积到一个可变的容器中，比如Collection或者StringBuilder；
2.	其他汇聚：除去可变汇聚剩下的，一般都不是通过反复修改某个可变对象，而是通过把前一次的汇聚结果当成下一次的入参，反复如此。比如reduce，count，allMatch；
4.1 可变汇聚
可变汇聚对应的只有一个方法：collect，正如其名字显示的，它可以把Stream中的要有元素收集到一个结果容器中（比如Collection）。先看一下最通用的collect方法的定义（还有其他override方法）：
1	<R> R collect(Supplier<R> supplier,
2	                  BiConsumer<R, ? super T> accumulator,
3	                  BiConsumer<R, R> combiner);
先来看看这三个参数的含义：Supplier supplier是一个工厂函数，用来生成一个新的容器；BiConsumer accumulator也是一个函数，用来把Stream中的元素添加到结果容器中；BiConsumer combiner还是一个函数，用来把中间状态的多个结果容器合并成为一个（并发的时候会用到）。看晕了？来段代码！
1	List<Integer> nums = Lists.newArrayList(1,1,null,2,3,4,null,5,6,7,8,9,10);
2	    List<Integer> numsWithoutNull = nums.stream().filter(num -> num != null).
3	            collect(() -> new ArrayList<Integer>(),
4	                    (list, item) -> list.add(item),
5	                    (list1, list2) -> list1.addAll(list2));
上面这段代码就是对一个元素是Integer类型的List，先过滤掉全部的null，然后把剩下的元素收集到一个新的List中。进一步看一下collect方法的三个参数，都是lambda形式的函数（*上面的代码可以使用方法引用来简化，留给读者自己去思考*）。
•	第一个函数生成一个新的ArrayList实例；
•	第二个函数接受两个参数，第一个是前面生成的ArrayList对象，二个是stream中包含的元素，函数体就是把stream中的元素加入ArrayList对象中。第二个函数被反复调用直到原stream的元素被消费完毕；
•	第三个函数也是接受两个参数，这两个都是ArrayList类型的，函数体就是把第二个ArrayList全部加入到第一个中；
但是上面的collect方法调用也有点太复杂了，没关系！我们来看一下collect方法另外一个override的版本，其依赖[Collector](http://docs.oracle.com/javase/8/docs/api/java/util/stream/Collector.html)。
1	<R, A> R collect(Collector<? super T, A, R> collector);
这样清爽多了！少年，还有好消息，Java8还给我们提供了Collector的工具类–[Collectors](http://docs.oracle.com/javase/8/docs/api/java/util/stream/Collectors.html)，其中已经定义了一些静态工厂方法，比如：Collectors.toCollection()收集到Collection中, Collectors.toList()收集到List中和Collectors.toSet()收集到Set中。这样的静态方法还有很多，这里就不一一介绍了，大家可以直接去看JavaDoc。下面看看使用Collectors对于代码的简化：
1	List<Integer> numsWithoutNull = nums.stream().filter(num -> num != null).
2	                collect(Collectors.toList());
4.2 其他汇聚
– reduce方法：reduce方法非常的通用，后面介绍的count，sum等都可以使用其实现。reduce方法有三个override的方法，本文介绍两个最常用的，最后一个留给读者自己学习。先来看reduce方法的第一种形式，其方法定义如下：
1	Optional<T> reduce(BinaryOperator<T> accumulator);
接受一个BinaryOperator类型的参数，在使用的时候我们可以用lambda表达式来。
1	List<Integer> ints = Lists.newArrayList(1,2,3,4,5,6,7,8,9,10);
2	System.out.println("ints sum is:" + ints.stream().reduce((sum, item) -&gt; sum + item).get());
可以看到reduce方法接受一个函数，这个函数有两个参数，第一个参数是上次函数执行的返回值（也称为中间结果），第二个参数是stream中的元素，这个函数把这两个值相加，得到的和会被赋值给下次执行这个函数的第一个参数。要注意的是：**第一次执行的时候第一个参数的值是Stream的第一个元素，第二个参数是Stream的第二个元素**。这个方法返回值类型是Optional，这是Java8防止出现NPE的一种可行方法，后面的文章会详细介绍，这里就简单的认为是一个容器，其中可能会包含0个或者1个对象。
这个过程可视化的结果如图：
 
reduce方法还有一个很常用的变种：
1	T reduce(T identity, BinaryOperator<T> accumulator);
这个定义上上面已经介绍过的基本一致，不同的是：它允许用户提供一个循环计算的初始值，如果Stream为空，就直接返回该值。而且这个方法不会返回Optional，因为其不会出现null值。下面直接给出例子，就不再做说明了。
1	List<Integer> ints = Lists.newArrayList(1,2,3,4,5,6,7,8,9,10);
2	System.out.println("ints sum is:" + ints.stream().reduce(0, (sum, item) -> sum + item));
– count方法：获取Stream中元素的个数。比较简单，这里就直接给出例子，不做解释了。
1	List<Integer> ints = Lists.newArrayList(1,2,3,4,5,6,7,8,9,10);
2	System.out.println("ints sum is:" + ints.stream().count());
– 搜索相关
– allMatch：是不是Stream中的所有元素都满足给定的匹配条件
– anyMatch：Stream中是否存在任何一个元素满足匹配条件
– findFirst: 返回Stream中的第一个元素，如果Stream为空，返回空Optional
– noneMatch：是不是Stream中的所有元素都不满足给定的匹配条件
– max和min：使用给定的比较器（Operator），返回Stream中的最大|最小值
下面给出allMatch和max的例子，剩下的方法读者当成练习。
1	List<Integer&gt; ints = Lists.newArrayList(1,2,3,4,5,6,7,8,9,10);
2	System.out.println(ints.stream().allMatch(item -> item < 100));
3	ints.stream().max((o1, o2) -&gt; o1.compareTo(o2)).ifPresent(System.out::println);
5. 下期预告
Functional Interface
6. 引用文档
1. 《Java SE 8 for the Really Impatient》
2. Java 8 API doc
原创文章，转载请注明： 转载自并发编程网 – ifeve.com本文链接地址: Java8初体验（二）Stream语法详解




# 【译】Java 8的新特性—终极版 - 简书 
http://www.jianshu.com/p/5b800057f2d8



声明：本文翻译自Java 8 Features Tutorial – The ULTIMATE Guide，翻译过程中发现并发编程网已经有同学翻译过了：Java 8 特性 – 终极手册，我还是坚持自己翻译了一版（写作驱动学习，加深印象），有些地方参考了该同学的。
________________________________________
 
Java 8
前言： Java 8 已经发布很久了，很多报道表明Java 8 是一次重大的版本升级。在Java Code Geeks上已经有很多介绍Java 8新特性的文章，例如Playing with Java 8 – Lambdas and Concurrency、Java 8 Date Time API Tutorial : LocalDateTime和Abstract Class Versus Interface in the JDK 8 Era。本文还参考了一些其他资料，例如：15 Must Read Java 8 Tutorials和The Dark Side of Java 8。本文综合了上述资料，整理成一份关于Java 8新特性的参考教材，希望你有所收获。
1. 简介
毫无疑问，Java 8是Java自Java 5（发布于2004年）之后的最重要的版本。这个版本包含语言、编译器、库、工具和JVM等方面的十多个新特性。在本文中我们将学习这些新特性，并用实际的例子说明在什么场景下适合使用。
这个教程包含Java开发者经常面对的几类问题：
•	语言
•	编译器
•	库
•	工具
•	运行时（JVM）
2. Java语言的新特性
Java 8是Java的一个重大版本，有人认为，虽然这些新特性领Java开发人员十分期待，但同时也需要花不少精力去学习。在这一小节中，我们将介绍Java 8的大部分新特性。
2.1 Lambda表达式和函数式接口
Lambda表达式（也称为闭包）是Java 8中最大和最令人期待的语言改变。它允许我们将函数当成参数传递给某个方法，或者把代码本身当作数据处理：函数式开发者非常熟悉这些概念。很多JVM平台上的语言（Groovy、Scala等）从诞生之日就支持Lambda表达式，但是Java开发者没有选择，只能使用匿名内部类代替Lambda表达式。
Lambda的设计耗费了很多时间和很大的社区力量，最终找到一种折中的实现方案，可以实现简洁而紧凑的语言结构。最简单的Lambda表达式可由逗号分隔的参数列表、->符号和语句块组成，例如：
Arrays.asList( "a", "b", "d" ).forEach( e -> System.out.println( e ) );
在上面这个代码中的参数e的类型是由编译器推理得出的，你也可以显式指定该参数的类型，例如：
Arrays.asList( "a", "b", "d" ).forEach( ( String e ) -> System.out.println( e ) );
如果Lambda表达式需要更复杂的语句块，则可以使用花括号将该语句块括起来，类似于Java中的函数体，例如：
Arrays.asList( "a", "b", "d" ).forEach( e -> {
    System.out.print( e );
    System.out.print( e );
} );
Lambda表达式可以引用类成员和局部变量（会将这些变量隐式得转换成final的），例如下列两个代码块的效果完全相同：
String separator = ",";
Arrays.asList( "a", "b", "d" ).forEach( 
    ( String e ) -> System.out.print( e + separator ) );
和
final String separator = ",";
Arrays.asList( "a", "b", "d" ).forEach( 
    ( String e ) -> System.out.print( e + separator ) );
Lambda表达式有返回值，返回值的类型也由编译器推理得出。如果Lambda表达式中的语句块只有一行，则可以不用使用return语句，下列两个代码片段效果相同：
Arrays.asList( "a", "b", "d" ).sort( ( e1, e2 ) -> e1.compareTo( e2 ) );
和
Arrays.asList( "a", "b", "d" ).sort( ( e1, e2 ) -> {
    int result = e1.compareTo( e2 );
    return result;
} );
Lambda的设计者们为了让现有的功能与Lambda表达式良好兼容，考虑了很多方法，于是产生了函数接口这个概念。函数接口指的是只有一个函数的接口，这样的接口可以隐式转换为Lambda表达式。java.lang.Runnable和java.util.concurrent.Callable是函数式接口的最佳例子。在实践中，函数式接口非常脆弱：只要某个开发者在该接口中添加一个函数，则该接口就不再是函数式接口进而导致编译失败。为了克服这种代码层面的脆弱性，并显式说明某个接口是函数式接口，Java 8 提供了一个特殊的注解@FunctionalInterface（Java 库中的所有相关接口都已经带有这个注解了），举个简单的函数式接口的定义：
@FunctionalInterface
public interface Functional {
    void method();
}
不过有一点需要注意，默认方法和静态方法不会破坏函数式接口的定义，因此如下的代码是合法的。
@FunctionalInterface
public interface FunctionalDefaultMethods {
    void method();

    default void defaultMethod() {            
    }        
}
Lambda表达式作为Java 8的最大卖点，它有潜力吸引更多的开发者加入到JVM平台，并在纯Java编程中使用函数式编程的概念。如果你需要了解更多Lambda表达式的细节，可以参考官方文档。
2.2 接口的默认方法和静态方法
Java 8使用两个新概念扩展了接口的含义：默认方法和静态方法。默认方法使得接口有点类似traits，不过要实现的目标不一样。默认方法使得开发者可以在 不破坏二进制兼容性的前提下，往现存接口中添加新的方法，即不强制那些实现了该接口的类也同时实现这个新加的方法。
默认方法和抽象方法之间的区别在于抽象方法需要实现，而默认方法不需要。接口提供的默认方法会被接口的实现类继承或者覆写，例子代码如下：
private interface Defaulable {
    // Interfaces now allow default methods, the implementer may or 
    // may not implement (override) them.
    default String notRequired() { 
        return "Default implementation"; 
    }        
}

private static class DefaultableImpl implements Defaulable {
}

private static class OverridableImpl implements Defaulable {
    @Override
    public String notRequired() {
        return "Overridden implementation";
    }
}
Defaulable接口使用关键字default定义了一个默认方法notRequired()。DefaultableImpl类实现了这个接口，同时默认继承了这个接口中的默认方法；OverridableImpl类也实现了这个接口，但覆写了该接口的默认方法，并提供了一个不同的实现。
Java 8带来的另一个有趣的特性是在接口中可以定义静态方法，例子代码如下：
private interface DefaulableFactory {
    // Interfaces now allow static methods
    static Defaulable create( Supplier< Defaulable > supplier ) {
        return supplier.get();
    }
}
下面的代码片段整合了默认方法和静态方法的使用场景：
public static void main( String[] args ) {
    Defaulable defaulable = DefaulableFactory.create( DefaultableImpl::new );
    System.out.println( defaulable.notRequired() );

    defaulable = DefaulableFactory.create( OverridableImpl::new );
    System.out.println( defaulable.notRequired() );
}
这段代码的输出结果如下：
Default implementation
Overridden implementation
由于JVM上的默认方法的实现在字节码层面提供了支持，因此效率非常高。默认方法允许在不打破现有继承体系的基础上改进接口。该特性在官方库中的应用是：给java.util.Collection接口添加新方法，如stream()、parallelStream()、forEach()和removeIf()等等。
尽管默认方法有这么多好处，但在实际开发中应该谨慎使用：在复杂的继承体系中，默认方法可能引起歧义和编译错误。如果你想了解更多细节，可以参考官方文档。
2.3 方法引用
方法引用使得开发者可以直接引用现存的方法、Java类的构造方法或者实例对象。方法引用和Lambda表达式配合使用，使得java类的构造方法看起来紧凑而简洁，没有很多复杂的模板代码。
西门的例子中，Car类是不同方法引用的例子，可以帮助读者区分四种类型的方法引用。
public static class Car {
    public static Car create( final Supplier< Car > supplier ) {
        return supplier.get();
    }              

    public static void collide( final Car car ) {
        System.out.println( "Collided " + car.toString() );
    }

    public void follow( final Car another ) {
        System.out.println( "Following the " + another.toString() );
    }

    public void repair() {   
        System.out.println( "Repaired " + this.toString() );
    }
}
第一种方法引用的类型是构造器引用，语法是Class::new，或者更一般的形式：Class<T>::new。注意：这个构造器没有参数。
final Car car = Car.create( Car::new );
final List< Car > cars = Arrays.asList( car );
第二种方法引用的类型是静态方法引用，语法是Class::static_method。注意：这个方法接受一个Car类型的参数。
cars.forEach( Car::collide );
第三种方法引用的类型是某个类的成员方法的引用，语法是Class::method，注意，这个方法没有定义入参：
cars.forEach( Car::repair );
第四种方法引用的类型是某个实例对象的成员方法的引用，语法是instance::method。注意：这个方法接受一个Car类型的参数：
final Car police = Car.create( Car::new );
cars.forEach( police::follow );
运行上述例子，可以在控制台看到如下输出（Car实例可能不同）：
Collided com.javacodegeeks.java8.method.references.MethodReferences$Car@7a81197d
Repaired com.javacodegeeks.java8.method.references.MethodReferences$Car@7a81197d
Following the com.javacodegeeks.java8.method.references.MethodReferences$Car@7a81197d
如果想了解和学习更详细的内容，可以参考官方文档
2.4 重复注解
自从Java 5中引入注解以来，这个特性开始变得非常流行，并在各个框架和项目中被广泛使用。不过，注解有一个很大的限制是：在同一个地方不能多次使用同一个注解。Java 8打破了这个限制，引入了重复注解的概念，允许在同一个地方多次使用同一个注解。
在Java 8中使用@Repeatable注解定义重复注解，实际上，这并不是语言层面的改进，而是编译器做的一个trick，底层的技术仍然相同。可以利用下面的代码说明：
package com.javacodegeeks.java8.repeatable.annotations;

import java.lang.annotation.ElementType;
import java.lang.annotation.Repeatable;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

public class RepeatingAnnotations {
    @Target( ElementType.TYPE )
    @Retention( RetentionPolicy.RUNTIME )
    public @interface Filters {
        Filter[] value();
    }

    @Target( ElementType.TYPE )
    @Retention( RetentionPolicy.RUNTIME )
    @Repeatable( Filters.class )
    public @interface Filter {
        String value();
    };

    @Filter( "filter1" )
    @Filter( "filter2" )
    public interface Filterable {        
    }

    public static void main(String[] args) {
        for( Filter filter: Filterable.class.getAnnotationsByType( Filter.class ) ) {
            System.out.println( filter.value() );
        }
    }
}
正如我们所见，这里的Filter类使用@Repeatable(Filters.class)注解修饰，而Filters是存放Filter注解的容器，编译器尽量对开发者屏蔽这些细节。这样，Filterable接口可以用两个Filter注解注释（这里并没有提到任何关于Filters的信息）。
另外，反射API提供了一个新的方法：getAnnotationsByType()，可以返回某个类型的重复注解，例如Filterable.class.getAnnoation(Filters.class)将返回两个Filter实例，输出到控制台的内容如下所示：
filter1
filter2
如果你希望了解更多内容，可以参考官方文档。
2.5 更好的类型推断
Java 8编译器在类型推断方面有很大的提升，在很多场景下编译器可以推导出某个参数的数据类型，从而使得代码更为简洁。例子代码如下：
package com.javacodegeeks.java8.type.inference;

public class Value< T > {
    public static< T > T defaultValue() { 
        return null; 
    }

    public T getOrDefault( T value, T defaultValue ) {
        return ( value != null ) ? value : defaultValue;
    }
}
下列代码是Value<String>类型的应用：
package com.javacodegeeks.java8.type.inference;

public class TypeInference {
    public static void main(String[] args) {
        final Value< String > value = new Value<>();
        value.getOrDefault( "22", Value.defaultValue() );
    }
}
参数Value.defaultValue()的类型由编译器推导得出，不需要显式指明。在Java 7中这段代码会有编译错误，除非使用Value.<String>defaultValue()。
2.6 拓宽注解的应用场景
Java 8拓宽了注解的应用场景。现在，注解几乎可以使用在任何元素上：局部变量、接口类型、超类和接口实现类，甚至可以用在函数的异常定义上。下面是一些例子：
package com.javacodegeeks.java8.annotations;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import java.util.ArrayList;
import java.util.Collection;

public class Annotations {
    @Retention( RetentionPolicy.RUNTIME )
    @Target( { ElementType.TYPE_USE, ElementType.TYPE_PARAMETER } )
    public @interface NonEmpty {        
    }

    public static class Holder< @NonEmpty T > extends @NonEmpty Object {
        public void method() throws @NonEmpty Exception {            
        }
    }

    @SuppressWarnings( "unused" )
    public static void main(String[] args) {
        final Holder< String > holder = new @NonEmpty Holder< String >();        
        @NonEmpty Collection< @NonEmpty String > strings = new ArrayList<>();        
    }
}
ElementType.TYPE_USER和ElementType.TYPE_PARAMETER是Java 8新增的两个注解，用于描述注解的使用场景。Java 语言也做了对应的改变，以识别这些新增的注解。
3. Java编译器的新特性
3.1 参数名称
为了在运行时获得Java程序中方法的参数名称，老一辈的Java程序员必须使用不同方法，例如Paranamer liberary。Java 8终于将这个特性规范化，在语言层面（使用反射API和Parameter.getName()方法）和字节码层面（使用新的javac编译器以及-parameters参数）提供支持。
package com.javacodegeeks.java8.parameter.names;

import java.lang.reflect.Method;
import java.lang.reflect.Parameter;

public class ParameterNames {
    public static void main(String[] args) throws Exception {
        Method method = ParameterNames.class.getMethod( "main", String[].class );
        for( final Parameter parameter: method.getParameters() ) {
            System.out.println( "Parameter: " + parameter.getName() );
        }
    }
}
在Java 8中这个特性是默认关闭的，因此如果不带-parameters参数编译上述代码并运行，则会输出如下结果：
Parameter: arg0
如果带-parameters参数，则会输出如下结果（正确的结果）：
Parameter: args
如果你使用Maven进行项目管理，则可以在maven-compiler-plugin编译器的配置项中配置-parameters参数：
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-compiler-plugin</artifactId>
    <version>3.1</version>
    <configuration>
        <compilerArgument>-parameters</compilerArgument>
        <source>1.8</source>
        <target>1.8</target>
    </configuration>
</plugin>
4. Java官方库的新特性
Java 8增加了很多新的工具类（date/time类），并扩展了现存的工具类，以支持现代的并发编程、函数式编程等。
4.1 Optional
Java应用中最常见的bug就是空值异常。在Java 8之前，Google Guava引入了Optionals类来解决NullPointerException，从而避免源码被各种null检查污染，以便开发者写出更加整洁的代码。Java 8也将Optional加入了官方库。
Optional仅仅是一个容易：存放T类型的值或者null。它提供了一些有用的接口来避免显式的null检查，可以参考Java 8官方文档了解更多细节。
接下来看一点使用Optional的例子：可能为空的值或者某个类型的值：
Optional< String > fullName = Optional.ofNullable( null );
System.out.println( "Full Name is set? " + fullName.isPresent() );        
System.out.println( "Full Name: " + fullName.orElseGet( () -> "[none]" ) ); 
System.out.println( fullName.map( s -> "Hey " + s + "!" ).orElse( "Hey Stranger!" ) );
如果Optional实例持有一个非空值，则isPresent()方法返回true，否则返回false；orElseGet()方法，Optional实例持有null，则可以接受一个lambda表达式生成的默认值；map()方法可以将现有的Opetional实例的值转换成新的值；orElse()方法与orElseGet()方法类似，但是在持有null的时候返回传入的默认值。
上述代码的输出结果如下：
Full Name is set? false
Full Name: [none]
Hey Stranger!
再看下另一个简单的例子：
Optional< String > firstName = Optional.of( "Tom" );
System.out.println( "First Name is set? " + firstName.isPresent() );        
System.out.println( "First Name: " + firstName.orElseGet( () -> "[none]" ) ); 
System.out.println( firstName.map( s -> "Hey " + s + "!" ).orElse( "Hey Stranger!" ) );
System.out.println();
这个例子的输出是：
First Name is set? true
First Name: Tom
Hey Tom!
如果想了解更多的细节，请参考官方文档。
4.2 Streams
新增的Stream API（java.util.stream）将生成环境的函数式编程引入了Java库中。这是目前为止最大的一次对Java库的完善，以便开发者能够写出更加有效、更加简洁和紧凑的代码。
Steam API极大得简化了集合操作（后面我们会看到不止是集合），首先看下这个叫Task的类：
public class Streams  {
    private enum Status {
        OPEN, CLOSED
    };

    private static final class Task {
        private final Status status;
        private final Integer points;

        Task( final Status status, final Integer points ) {
            this.status = status;
            this.points = points;
        }

        public Integer getPoints() {
            return points;
        }

        public Status getStatus() {
            return status;
        }

        @Override
        public String toString() {
            return String.format( "[%s, %d]", status, points );
        }
    }
}
Task类有一个分数（或伪复杂度）的概念，另外还有两种状态：OPEN或者CLOSED。现在假设有一个task集合：
final Collection< Task > tasks = Arrays.asList(
    new Task( Status.OPEN, 5 ),
    new Task( Status.OPEN, 13 ),
    new Task( Status.CLOSED, 8 ) 
);
首先看一个问题：在这个task集合中一共有多少个OPEN状态的点？在Java 8之前，要解决这个问题，则需要使用foreach循环遍历task集合；但是在Java 8中可以利用steams解决：包括一系列元素的列表，并且支持顺序和并行处理。
// Calculate total points of all active tasks using sum()
final long totalPointsOfOpenTasks = tasks
    .stream()
    .filter( task -> task.getStatus() == Status.OPEN )
    .mapToInt( Task::getPoints )
    .sum();

System.out.println( "Total points: " + totalPointsOfOpenTasks );
运行这个方法的控制台输出是：
Total points: 18
这里有很多知识点值得说。首先，tasks集合被转换成steam表示；其次，在steam上的filter操作会过滤掉所有CLOSED的task；第三，mapToInt操作基于每个task实例的Task::getPoints方法将task流转换成Integer集合；最后，通过sum方法计算总和，得出最后的结果。
在学习下一个例子之前，还需要记住一些steams（点此更多细节）的知识点。Steam之上的操作可分为中间操作和晚期操作。
中间操作会返回一个新的steam——执行一个中间操作（例如filter）并不会执行实际的过滤操作，而是创建一个新的steam，并将原steam中符合条件的元素放入新创建的steam。
晚期操作（例如forEach或者sum），会遍历steam并得出结果或者附带结果；在执行晚期操作之后，steam处理线已经处理完毕，就不能使用了。在几乎所有情况下，晚期操作都是立刻对steam进行遍历。
steam的另一个价值是创造性地支持并行处理（parallel processing）。对于上述的tasks集合，我们可以用下面的代码计算所有任务的点数之和：
// Calculate total points of all tasks
final double totalPoints = tasks
   .stream()
   .parallel()
   .map( task -> task.getPoints() ) // or map( Task::getPoints ) 
   .reduce( 0, Integer::sum );

System.out.println( "Total points (all tasks): " + totalPoints );
这里我们使用parallel方法并行处理所有的task，并使用reduce方法计算最终的结果。控制台输出如下：
Total points（all tasks）: 26.0
对于一个集合，经常需要根据某些条件对其中的元素分组。利用steam提供的API可以很快完成这类任务，代码如下：
// Group tasks by their status
final Map< Status, List< Task > > map = tasks
    .stream()
    .collect( Collectors.groupingBy( Task::getStatus ) );
System.out.println( map );
控制台的输出如下：
{CLOSED=[[CLOSED, 8]], OPEN=[[OPEN, 5], [OPEN, 13]]}
最后一个关于tasks集合的例子问题是：如何计算集合中每个任务的点数在集合中所占的比重，具体处理的代码如下：
// Calculate the weight of each tasks (as percent of total points) 
final Collection< String > result = tasks
    .stream()                                        // Stream< String >
    .mapToInt( Task::getPoints )                     // IntStream
    .asLongStream()                                  // LongStream
    .mapToDouble( points -> points / totalPoints )   // DoubleStream
    .boxed()                                         // Stream< Double >
    .mapToLong( weigth -> ( long )( weigth * 100 ) ) // LongStream
    .mapToObj( percentage -> percentage + "%" )      // Stream< String> 
    .collect( Collectors.toList() );                 // List< String > 

System.out.println( result );
控制台输出结果如下：
[19%, 50%, 30%]
最后，正如之前所说，Steam API不仅可以作用于Java集合，传统的IO操作（从文件或者网络一行一行得读取数据）可以受益于steam处理，这里有一个小例子：
final Path path = new File( filename ).toPath();
try( Stream< String > lines = Files.lines( path, StandardCharsets.UTF_8 ) ) {
    lines.onClose( () -> System.out.println("Done!") ).forEach( System.out::println );
}
Stream的方法onClose 返回一个等价的有额外句柄的Stream，当Stream的close（）方法被调用的时候这个句柄会被执行。Stream API、Lambda表达式还有接口默认方法和静态方法支持的方法引用，是Java 8对软件开发的现代范式的响应。
4.3 Date/Time API(JSR 310)
Java 8引入了新的Date-Time API(JSR 310)来改进时间、日期的处理。时间和日期的管理一直是最令Java开发者痛苦的问题。java.util.Date和后来的java.util.Calendar一直没有解决这个问题（甚至令开发者更加迷茫）。
因为上面这些原因，诞生了第三方库Joda-Time，可以替代Java的时间管理API。Java 8中新的时间和日期管理API深受Joda-Time影响，并吸收了很多Joda-Time的精华。新的java.time包包含了所有关于日期、时间、时区、Instant（跟日期类似但是精确到纳秒）、duration（持续时间）和时钟操作的类。新设计的API认真考虑了这些类的不变性（从java.util.Calendar吸取的教训），如果某个实例需要修改，则返回一个新的对象。
我们接下来看看java.time包中的关键类和各自的使用例子。首先，Clock类使用时区来返回当前的纳秒时间和日期。Clock可以替代System.currentTimeMillis()和TimeZone.getDefault()。
// Get the system clock as UTC offset 
final Clock clock = Clock.systemUTC();
System.out.println( clock.instant() );
System.out.println( clock.millis() );
这个例子的输出结果是：
2014-04-12T15:19:29.282Z
1397315969360
第二，关注下LocalDate和LocalTime类。LocalDate仅仅包含ISO-8601日历系统中的日期部分；LocalTime则仅仅包含该日历系统中的时间部分。这两个类的对象都可以使用Clock对象构建得到。
// Get the local date and local time
final LocalDate date = LocalDate.now();
final LocalDate dateFromClock = LocalDate.now( clock );

System.out.println( date );
System.out.println( dateFromClock );

// Get the local date and local time
final LocalTime time = LocalTime.now();
final LocalTime timeFromClock = LocalTime.now( clock );

System.out.println( time );
System.out.println( timeFromClock );
上述例子的输出结果如下：
2014-04-12
2014-04-12
11:25:54.568
15:25:54.568
LocalDateTime类包含了LocalDate和LocalTime的信息，但是不包含ISO-8601日历系统中的时区信息。这里有一些关于LocalDate和LocalTime的例子：
// Get the local date/time
final LocalDateTime datetime = LocalDateTime.now();
final LocalDateTime datetimeFromClock = LocalDateTime.now( clock );

System.out.println( datetime );
System.out.println( datetimeFromClock );
上述这个例子的输出结果如下：
2014-04-12T11:37:52.309
2014-04-12T15:37:52.309
如果你需要特定时区的data/time信息，则可以使用ZoneDateTime，它保存有ISO-8601日期系统的日期和时间，而且有时区信息。下面是一些使用不同时区的例子：
// Get the zoned date/time
final ZonedDateTime zonedDatetime = ZonedDateTime.now();
final ZonedDateTime zonedDatetimeFromClock = ZonedDateTime.now( clock );
final ZonedDateTime zonedDatetimeFromZone = ZonedDateTime.now( ZoneId.of( "America/Los_Angeles" ) );

System.out.println( zonedDatetime );
System.out.println( zonedDatetimeFromClock );
System.out.println( zonedDatetimeFromZone );
这个例子的输出结果是：
2014-04-12T11:47:01.017-04:00[America/New_York]
2014-04-12T15:47:01.017Z
2014-04-12T08:47:01.017-07:00[America/Los_Angeles]
最后看下Duration类，它持有的时间精确到秒和纳秒。这使得我们可以很容易得计算两个日期之间的不同，例子代码如下：
// Get duration between two dates
final LocalDateTime from = LocalDateTime.of( 2014, Month.APRIL, 16, 0, 0, 0 );
final LocalDateTime to = LocalDateTime.of( 2015, Month.APRIL, 16, 23, 59, 59 );

final Duration duration = Duration.between( from, to );
System.out.println( "Duration in days: " + duration.toDays() );
System.out.println( "Duration in hours: " + duration.toHours() );
这个例子用于计算2014年4月16日和2015年4月16日之间的天数和小时数，输出结果如下：
Duration in days: 365
Duration in hours: 8783
对于Java 8的新日期时间的总体印象还是比较积极的，一部分是因为Joda-Time的积极影响，另一部分是因为官方终于听取了开发人员的需求。如果希望了解更多细节，可以参考官方文档。
4.4 Nashorn JavaScript引擎
Java 8提供了新的Nashorn JavaScript引擎，使得我们可以在JVM上开发和运行JS应用。Nashorn JavaScript引擎是javax.script.ScriptEngine的另一个实现版本，这类Script引擎遵循相同的规则，允许Java和JavaScript交互使用，例子代码如下：
ScriptEngineManager manager = new ScriptEngineManager();
ScriptEngine engine = manager.getEngineByName( "JavaScript" );

System.out.println( engine.getClass().getName() );
System.out.println( "Result:" + engine.eval( "function f() { return 1; }; f() + 1;" ) );
这个代码的输出结果如下：
jdk.nashorn.api.scripting.NashornScriptEngine
Result: 2
4.5 Base64
对Base64编码的支持已经被加入到Java 8官方库中，这样不需要使用第三方库就可以进行Base64编码，例子代码如下：
package com.javacodegeeks.java8.base64;

import java.nio.charset.StandardCharsets;
import java.util.Base64;

public class Base64s {
    public static void main(String[] args) {
        final String text = "Base64 finally in Java 8!";

        final String encoded = Base64
            .getEncoder()
            .encodeToString( text.getBytes( StandardCharsets.UTF_8 ) );
        System.out.println( encoded );

        final String decoded = new String( 
            Base64.getDecoder().decode( encoded ),
            StandardCharsets.UTF_8 );
        System.out.println( decoded );
    }
}
这个例子的输出结果如下：
QmFzZTY0IGZpbmFsbHkgaW4gSmF2YSA4IQ==
Base64 finally in Java 8!
新的Base64API也支持URL和MINE的编码解码。
(Base64.getUrlEncoder() / Base64.getUrlDecoder(), Base64.getMimeEncoder() /Base64.getMimeDecoder())。
4.6 并行数组
Java8版本新增了很多新的方法，用于支持并行数组处理。最重要的方法是parallelSort()，可以显著加快多核机器上的数组排序。下面的例子论证了parallexXxx系列的方法：
package com.javacodegeeks.java8.parallel.arrays;

import java.util.Arrays;
import java.util.concurrent.ThreadLocalRandom;

public class ParallelArrays {
    public static void main( String[] args ) {
        long[] arrayOfLong = new long [ 20000 ];        

        Arrays.parallelSetAll( arrayOfLong, 
            index -> ThreadLocalRandom.current().nextInt( 1000000 ) );
        Arrays.stream( arrayOfLong ).limit( 10 ).forEach( 
            i -> System.out.print( i + " " ) );
        System.out.println();

        Arrays.parallelSort( arrayOfLong );        
        Arrays.stream( arrayOfLong ).limit( 10 ).forEach( 
            i -> System.out.print( i + " " ) );
        System.out.println();
    }
}
上述这些代码使用parallelSetAll()方法生成20000个随机数，然后使用parallelSort()方法进行排序。这个程序会输出乱序数组和排序数组的前10个元素。上述例子的代码输出的结果是：
Unsorted: 591217 891976 443951 424479 766825 351964 242997 642839 119108 552378 
Sorted: 39 220 263 268 325 607 655 678 723 793
4.7 并发性
基于新增的lambda表达式和steam特性，为Java 8中为java.util.concurrent.ConcurrentHashMap类添加了新的方法来支持聚焦操作；另外，也为java.util.concurrentForkJoinPool类添加了新的方法来支持通用线程池操作（更多内容可以参考我们的并发编程课程）。
Java 8还添加了新的java.util.concurrent.locks.StampedLock类，用于支持基于容量的锁——该锁有三个模型用于支持读写操作（可以把这个锁当做是java.util.concurrent.locks.ReadWriteLock的替代者）。
在java.util.concurrent.atomic包中也新增了不少工具类，列举如下：
•	DoubleAccumulator
•	DoubleAdder
•	LongAccumulator
•	LongAdder
5. 新的Java工具
Java 8提供了一些新的命令行工具，这部分会讲解一些对开发者最有用的工具。
5.1 Nashorn引擎：jjs
jjs是一个基于标准Nashorn引擎的命令行工具，可以接受js源码并执行。例如，我们写一个func.js文件，内容如下：
function f() { 
     return 1; 
}; 

print( f() + 1 );
可以在命令行中执行这个命令：jjs func.js，控制台输出结果是：
2
如果需要了解细节，可以参考官方文档。
5.2 类依赖分析器：jdeps
jdeps是一个相当棒的命令行工具，它可以展示包层级和类层级的Java类依赖关系，它以.class文件、目录或者Jar文件为输入，然后会把依赖关系输出到控制台。
我们可以利用jedps分析下Spring Framework库，为了让结果少一点，仅仅分析一个JAR文件：org.springframework.core-3.0.5.RELEASE.jar。
jdeps org.springframework.core-3.0.5.RELEASE.jar
这个命令会输出很多结果，我们仅看下其中的一部分：依赖关系按照包分组，如果在classpath上找不到依赖，则显示"not found".
org.springframework.core-3.0.5.RELEASE.jar -> C:\Program Files\Java\jdk1.8.0\jre\lib\rt.jar
   org.springframework.core (org.springframework.core-3.0.5.RELEASE.jar)
      -> java.io                                            
      -> java.lang                                          
      -> java.lang.annotation                               
      -> java.lang.ref                                      
      -> java.lang.reflect                                  
      -> java.util                                          
      -> java.util.concurrent                               
      -> org.apache.commons.logging                         not found
      -> org.springframework.asm                            not found
      -> org.springframework.asm.commons                    not found
   org.springframework.core.annotation (org.springframework.core-3.0.5.RELEASE.jar)
      -> java.lang                                          
      -> java.lang.annotation                               
      -> java.lang.reflect                                  
      -> java.util
更多的细节可以参考官方文档。
6. JVM的新特性
使用Metaspace（JEP 122）代替持久代（PermGen space）。在JVM参数方面，使用-XX:MetaSpaceSize和-XX:MaxMetaspaceSize代替原来的-XX:PermSize和-XX:MaxPermSize。
7. 结论
通过为开发者提供很多能够提高生产力的特性，Java 8使得Java平台前进了一大步。现在还不太适合将Java 8应用在生产系统中，但是在之后的几个月中Java 8的应用率一定会逐步提高（PS:原文时间是2014年5月9日，现在在很多公司Java 8已经成为主流，我司由于体量太大，现在也在一点点上Java 8，虽然慢但是好歹在升级了）。作为开发者，现在应该学习一些Java 8的知识，为升级做好准备。
关于Spring：对于企业级开发，我们也应该关注Spring社区对Java 8的支持，可以参考这篇文章——Spring 4支持的Java 8新特性一览
8. 参考资料
•	What’s New in JDK 8
•	The Java Tutorials
•	WildFly 8, JDK 8, NetBeans 8, Java EE
•	Java 8 Tutorial
•	JDK 8 Command-line Static Dependency Checker
•	The Illuminating Javadoc of JDK
•	The Dark Side of Java 8
•	Installing Java™ 8 Support in Eclipse Kepler SR2
•	Java 8
•	Oracle Nashorn. A Next-Generation JavaScript Engine for the JVM




# Java 8: joining strings with Stream API | Developer writing about stuff
 https://ivarconr.wordpress.com/2013/11/20/java-8-joining-strings-with-stream-api/


I this brief blog post I show how to loop over a collection of persons and build a string built by their names. The new Java 8 Stream API makes this really easy, combined with lambda expressions, explained in a previous post.
Problem description:
– Given a list of persons
– Build a string, we should follow this format: “age1:name1, age2:name2”
– We should only include adult persons (age > 18)
– Sort the names by age
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
14	//Data
List<Person> persons = new ArrayList<>();
persons.add(new Person("Ola Hansen", 21));
..
 
//Solution
String names = persons.stream()
  .filter(p -> p.getAge() > 18)
  .sorted((p1, p2) -> p1.getAge() - p2.getAge())
  .map(p -> p.getAge() + ":" + p.getName())
  .collect(Collectors.joining(", "));
 
//Result
"21:Ola Hansen, 28:Ivar Østhus, 29:Kari Normann, 42:Donald Duck"
This problem is really easy to solve using the new Stream API, as shown in code example above. The key to the solution is the joining-collector provided as a ready to use Collector. The joining-collector uses StringBuilder under the hood, to build up the resulting String. How would the solution look like with imperative styled for-loops? How many garbage variables would you need?
The example touches multiple new concepts, such as filter, sorted, map, collect, introduced in the Java 8 Stream API. Later I will write about the Stream API more deeply.



