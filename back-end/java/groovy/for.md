

实战 Groovy: for each 剖析 - justjavac(迷渡) - ITeye博客 
http://justjavac.iteye.com/blog/709670


实战 Groovy: for each 剖析

博客分类： Groovy&Grails
GroovyJavaJavaScriptSQL ServerSQL 
 
在这一期的 实战 Groovy 中，Scott Davis 提出了一组非常好的遍历方法，这些方法可以遍历数组、列表、文件、URL 以及很多其它内容。最令人印象深刻的是，Groovy 提供了一种一致的机制来遍历所有这些集合和其它内容。
迭代是编程的基础。您经常会遇到需要进行逐项遍历的内容，比如 List、File 和 JDBC ResultSet。Java 语言几乎总是提供了某种方法帮助您逐项遍历所需的内容，但令人沮丧的是，它并没有给出一种标准方法。Groovy 的迭代方法非常实用，在这一点上，Groovy 编程与 Java 编程截然不同。通过一些代码示例（可从 下载 小节获得），本文将介绍 Groovy 的万能的 each() 方法，从而将 Java 语言的那些迭代怪癖抛在脑后。
Java 迭代策略
假设您有一个 Java 编程语言的 java.util.List。清单 1 展示了在 Java 语言中如何使用编程实现迭代：

清单 1. Java 列表迭代
				
import java.util.*;

public class ListTest{
  public static void main(String[] args){
    List<String> list = new ArrayList<String>();
    list.add("Java");
    list.add("Groovy");
    list.add("JavaScript");
    
    for(Iterator<String> i = list.iterator(); i.hasNext();){
      String language = i.next();
      System.out.println("I know " + language);
    }
  }  
}
 
由于提供了大部分集合类都可以共享的 java.lang.Iterable 接口，您可以使用相同的方法遍历 java.util.Set 或 java.util.Queue。
	
现在，假设该语言存储在 java.util.Map 中。在编译时，尝试对 Map 获取 Iterator 会导致失败 — Map 并没有实现Iterable 接口。幸运的是，可以调用 map.keySet() 返回一个 Set，然后就可以继续处理。这些小差异可能会影响您的速度，但不会妨碍您的前进。需要注意的是，List、Set 和 Queue 实现了 Iterable，但是 Map 没有 — 即使它们位于相同的java.util 包中。
现在假设该语言存在于 String 数组中。数组是一种数据结构，而不是类。不能对 String 数组调用 .iterator()，因此必须使用稍微不同的迭代策略。您再一次受到阻碍，但可以使用如清单 2 所示的方法解决问题：

清单 2. Java 数组迭代
				
public class ArrayTest{
  public static void main(String[] args){
    String[] list = {"Java", "Groovy", "JavaScript"};
    
    for(int i = 0; i < list.length; i++){
      String language = list[i];
      System.out.println("I know " + language);            
    }
  }
}
 
但是等一下 — 使用 Java 5 引入的 for-each 语法怎么样（参见 参考资料）？它可以处理任何实现 Iterable 的类和数组，如清单 3 所示：

清单 3. Java 语言的 for-each 迭代
				
import java.util.*;

public class MixedTest{
  public static void main(String[] args){
    List<String> list = new ArrayList<String>();
    list.add("Java");
    list.add("Groovy");
    list.add("JavaScript");
    
    for(String language: list){
      System.out.println("I know " + language);      
    }

    String[] list2 = {"Java", "Groovy", "JavaScript"};
    for(String language: list2){
      System.out.println("I know " + language);      
    }
  }
}
 
因此，您可以使用相同的方法遍历数组和集合（Map 除外）。但是如果语言存储在 java.io.File，那该怎么办？如果存储在 JDBC ResultSet，或者存储在 XML 文档、java.util.StringTokenizer 中呢？面对每一种情况，必须使用一种稍有不同的迭代策略。这样做并不是有什么特殊目的 — 而是因为不同的 API 是由不同的开发人员在不同的时期开发的 — 但事实是，您必须了解 6 个 Java 迭代策略，特别是使用这些策略的特殊情况。
Eric S. Raymond 在他的 The Art of Unix Programming（参见 参考资料）一书中解释了 “最少意外原则”。他写道，“要设计可用的接口，最好不要设计全新的接口模型。新鲜的东西总是难以入门；会为用户带来学习的负担，因此应当尽量减少新内容。”Groovy 对迭代的态度正是采纳了 Raymond 的观点。在 Groovy 中遍历几乎任何结构时，您只需要使用 each() 这一种方法。

 
# Groovy 中的列表迭代
首先，我将 清单 3 中的 List 重构为 Groovy。在这里，只需要直接对列表调用 each() 方法并传递一个闭包，而不是将 List 转换成 for 循环（顺便提一句，这样做并不是特别具有面向对象的特征，不是吗）。
创建一个名为 listTest.groovy 的文件并添加清单 4 中的代码：

清单 4. Groovy 列表迭代
				
def list = ["Java", "Groovy", "JavaScript"]
list.each{language->
  println language
}
 
清单 4 中的第一行是 Groovy 用于构建 java.util.ArrayList 的便捷语法。可以将 println list.class 添加到此脚本来验证这一点。接下来，只需对列表调用 each()，并在闭包体内输出 language 变量。在闭包的开始处使用 language-> 语句命名 language 变量。如果没有提供变量名，Groovy 提供了一个默认名称 it。在命令行提示符中输入 groovy listTest 运行 listTest.groovy。
清单 5 是经过简化的 清单 4 代码版本：

清单 5. 使用 Groovy 的 it 变量的迭代
				
// shorter, using the default it variable
def list = ["Java", "Groovy", "JavaScript"]
list.each{ println it }

// shorter still, using an anonymous list
["Java", "Groovy", "JavaScript"].each{ println it }
 
Groovy 允许您对数组和 List 交替使用 each() 方法。为了将 ArrayList 改为 String 数组，必须将 as String[] 添加到行末，如清单 6 所示：

清单 6. Groovy 数组迭代
				
def list = ["Java", "Groovy", "JavaScript"] as String[]
list.each{println it}
 
在 Groovy 中普遍使用 each() 方法，并且 getter 语法非常便捷（getClass() 和 class 是相同的调用），这使您能够编写既简洁又富有表达性的代码。例如，假设您希望利用反射显示给定类的所有公共方法。清单 7 展示了这个例子：

清单 7. Groovy 反射
				
def s = "Hello World"
println s
println s.class
s.class.methods.each{println it}

//output:
$ groovy reflectionTest.groovy 
Hello World
class java.lang.String
public int java.lang.String.hashCode()
public volatile int java.lang.String.compareTo(java.lang.Object)
public int java.lang.String.compareTo(java.lang.String)
public boolean java.lang.String.equals(java.lang.Object)
...
 
脚本的最后一行调用 getClass() 方法。java.lang.Class 提供了一个 getMethods() 方法，后者返回一个数组。通过将这些操作串连起来并对 Method 的结果数组调用 each()，您只使用了一行代码就完成了大量工作。
但是，与 Java for-each 语句不同的是，万能的 each() 方法并不仅限于 List 和数组。在 Java 语言中，故事到此结束。然而，在 Groovy 中，故事才刚刚开始。
 
# Map 迭代
从前文可以看到，在 Java 语言中，无法直接迭代 Map。在 Groovy 中，这完全不是问题，如清单 8 所示：

清单 8. Groovy map 迭代
				
def map = ["Java":"server", "Groovy":"server", "JavaScript":"web"]
map.each{ println it }
 
要处理名称/值对，可以使用隐式的 getKey() 和 getValue() 方法，或在包的开头部分显式地命名变量，如清单 9 所示：

清单 9. 从 map 获得键和值
				
def map = ["Java":"server", "Groovy":"server", "JavaScript":"web"]
map.each{ 
  println it.key
  println it.value 
}

map.each{k,v->
  println k
  println v
}
 
可以看到，迭代 Map 和迭代其它任何集合一样自然。
在继续研究下一个迭代例子前，应当了解 Groovy 中有关 Map 的另一个语法。与在 Java 语言中调用 map.get("Java") 不一样，可以简化对 map.Java 的调用，如清单 10 所示：

清单 10. 获得 map 值
				
def map = ["Java":"server", "Groovy":"server", "JavaScript":"web"]

//identical results
println map.get("Java")
println map.Java
 
不可否认，Groovy 针对 Map 的这种便捷语法非常酷，但这也是在对 Map 使用反射时引起一些常见问题的原因。对 list.class 的调用将生成 java.util.ArrayList，而调用 map.class 返回 null。这是因为获得 map 元素的便捷方法覆盖了实际的 getter 调用。Map 中的元素都不具有 class 键，因此调用实际会返回 null，如清单 11 的示例所示：

清单 11. Groovy map 和 null 
				
def list = ["Java", "Groovy", "JavaScript"]
println list.class
// java.util.ArrayList

def map = ["Java":"server", "Groovy":"server", "JavaScript":"web"]
println map.class
// null

map.class = "I am a map element"
println map.class
// I am a map element

println map.getClass()
// class java.util.LinkedHashMap
 
这是 Groovy 比较罕见的打破 “最少意外原则” 的情况，但是由于从 map 获取元素要比使用反射更加常见，因此我可以接受这一例外。
 
# String 迭代
现在您已经熟悉 each() 方法了，它可以出现在所有相关的位置。假设您希望迭代一个 String，并且是逐一迭代字符，那么马上可以使用 each() 方法。如清单 12 所示：

清单 12. String 迭代
				
def name = "Jane Smith"
name.each{letter->
  println letter
}
 
这提供了所有的可能性，比如使用下划线替代所有空格，如清单 13 所示：

清单 13. 使用下划线替代空格
				
def name = "Jane Smith"
println "replace spaces"
name.each{
  if(it == " "){
    print "_"
  }else{
    print it
  }
}

// output
Jane_Smith
 
当然，在替换一个单个字母时，Groovy 提供了一个更加简洁的替换方法。您可以将清单 13 中的所有代码合并为一行代码："Jane Smith".replace(" ", "_")。但是对于更复杂的 String 操作，each() 方法是最佳选择。
 
Range 迭代
Groovy 提供了原生的 Range 类型，可以直接迭代。使用两个点分隔的所有内容（比如 1..10）都是一个 Range。清单 14 展示了这个例子：

清单 14. Range 迭代
				
def range = 5..10
range.each{
  println it
}

//output:
5
6
7
8
9
10
 
Range 不局限于简单的 Integer。考虑清单 15 在的代码，其中迭代 Date 的 Range：

清单 15. Date 迭代
				
def today = new Date()
def nextWeek = today + 7
(today..nextWeek).each{
  println it
}

//output:
Thu Mar 12 04:49:35 MDT 2009
Fri Mar 13 04:49:35 MDT 2009
Sat Mar 14 04:49:35 MDT 2009
Sun Mar 15 04:49:35 MDT 2009
Mon Mar 16 04:49:35 MDT 2009
Tue Mar 17 04:49:35 MDT 2009
Wed Mar 18 04:49:35 MDT 2009
Thu Mar 19 04:49:35 MDT 2009
 
可以看到，each() 准确地出现在您所期望的位置。Java 语言缺乏原生的 Range 类型，但是提供了一个类似地概念，采取 enum 的形式。毫不奇怪，在这里 each() 仍然派得上用场。
 
 
Enumeration 类型
Java enum 是按照特定顺序保存的随意的值集合。清单 16 展示了 each() 方法如何自然地配合 enum，就好象它在处理 Range 操作符一样：

清单 16. enum 迭代
				
enum DAY{
  MONDAY, TUESDAY, WEDNESDAY, THURSDAY,
    FRIDAY, SATURDAY, SUNDAY
}

DAY.each{
  println it
}

(DAY.MONDAY..DAY.FRIDAY).each{
  println it
}
 
在 Groovy 中，有些情况下，each() 这个名称远未能表达它的强大功能。在下面的例子中，将看到使用特定于所用上下文的方法对 each() 方法进行修饰。Groovy eachRow() 方法就是一个很好的例子。
 
SQL 迭代
在处理关系数据库表时，经常会说 “我需要针对表中的每一行执行操作”。比较一下前面的例子。您很可能会说 “我需要对列表中的每一种语言执行一些操作”。根据这个道理，groovy.sql.Sql 对象提供了一个eachRow() 方法，如清单 17 所示：

清单 17. ResultSet 迭代
				
import groovy.sql.*

def sql = Sql.newInstance(
   "jdbc:derby://localhost:1527/MyDbTest;create=true",
   "username",
   "password",
   "org.apache.derby.jdbc.ClientDriver")

println("grab a specific field")
sql.eachRow("select name from languages"){ row ->
    println row.name
}

println("grab all fields")
sql.eachRow("select * from languages"){ row ->
    println("Name: ${row.name}")
    println("Version: ${row.version}")
    println("URL: ${row.url}\n")
}
 
该脚本的第一行代码实例化了一个新的 Sql 对象：设置 JDBC 连接字符串、用户名、密码和 JDBC 驱动器类。这时，可以调用 eachRow() 方法，传递 SQL select 语句作为一个方法参数。在闭包内部，可以引用列名（name、version、url），就好像实际存在 getName()、getVersion() 和 getUrl() 方法一样。
这显然要比 Java 语言中的等效方法更加清晰。在 Java 中，必须创建单独的 DriverManager、Connection、Statement 和 JDBCResultSet，然后必须在嵌套的 try/catch/finally 块中将它们全部清除。
对于 Sql 对象，您会认为 each() 或 eachRow() 都是一个合理的方法名。但是在接下来的示例中，我想您会认为 each() 这个名称并不能充分表达它的功能。
 
文件迭代
我从未想过使用原始的 Java 代码逐行遍历 java.io.File。当我完成了所有的嵌套的 BufferedReader 和 FileReader 后（更别提每个流程末尾的所有异常处理），我已经忘记最初的目的是什么。
清单 18 展示了使用 Java 语言完成的整个过程：

清单 18. Java 文件迭代
				
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;

public class WalkFile {
   public static void main(String[] args) {
      BufferedReader br = null;
      try {
         br = new BufferedReader(new FileReader("languages.txt"));
         String line = null;
         while((line = br.readLine()) != null) {
            System.out.println("I know " + line);
         }
      }
      catch(FileNotFoundException e) {
         e.printStackTrace();
      }
      catch(IOException e) {
         e.printStackTrace();
      }
      finally {
         if(br != null) {
            try {
               br.close();
            }
            catch(IOException e) {
               e.printStackTrace();
            }
         }
      }
   }
}
 
清单 19 展示了 Groovy 中的等效过程：

清单 19. Groovy 文件迭代
				
def f = new File("languages.txt")
f.eachLine{language->
  println "I know ${language}"
}
 
这正是 Groovy 的简洁性真正擅长的方面。现在，我希望您了解为什么我将 Groovy 称为 “Java 程序员的 DSL”。
注意，我在 Groovy 和 Java 语言中同时处理同一个 java.io.File 类。如果该文件不存在，那么 Groovy 代码将抛出和 Java 代码相同的 FileNotFoundException 异常。区别在于，Groovy 没有已检测的异常。在 try/catch/finally 块中封装 eachLine() 结构是我自己的爱好 — 而不是一项语言需求。对于一个简单的命令行脚本中，我欣赏 清单 19 中的代码的简洁性。如果我在运行应用服务的同时执行相同的迭代，我不能对这些异常坐视不管。我将在与 Java 版本相同的 try/catch 块中封装 eachLine() 块。
File 类对 each() 方法进行了一些修改。其中之一就是 splitEachLine(String separator, Closure closure)。这意味着您不仅可以逐行遍历文件，同时还可以将它分为不同的标记。清单 20 展示了一个例子：

清单 20. 分解文件的每一行 
				
// languages.txt
// notice the space between the language and the version
Java 1.5
Groovy 1.6
JavaScript 1.x 

// splitTest.groovy
def f = new File("languages.txt")
f.splitEachLine(" "){words->
  words.each{ println it }
}

// output
Java
1.5
Groovy
1.6
JavaScript
1.x
 
如果处理的是二进制文件，Groovy 还提供了一个 eachByte() 方法。
当然，Java 语言中的 File 并不总是一个文件 — 有时是一个目录。Groovy 还提供了一些 each() 修改以处理子目录。
 




回页首
 
目录迭代
使用 Groovy 代替 shell 脚本（或批处理脚本）非常容易，因为您能够方便地访问文件系统。要获得当前目录的目录列表，参见清单 21：

清单 21. 目录迭代
				
def dir = new File(".")
dir.eachFile{file->
  println file
}
 
eachFile() 方法同时返回了文件和子目录。使用 Java 语言的 isFile() 和 isDirectory() 方法，可以完成更复杂的事情。清单 22 展示了一个例子：

清单 22. 分离文件和目录
				
def dir = new File(".")
dir.eachFile{file->
  if(file.isFile()){
    println "FILE: ${file}"    
  }else if(file.isDirectory()){
    println "DIR:  ${file}"
  }else{
    println "Uh, I'm not sure what it is..."
  }
}
 
由于两种 Java 方法都返回 boolean 值，可以在代码中添加一个 Java 三元操作符。清单 23 展示了一个例子：

清单 23. 三元操作符
				
def dir = new File(".")
dir.eachFile{file->
  println file.isDirectory() ? "DIR:  ${file}" : "FILE: ${file}"
}
 
如果只对目录有兴趣，那么可以使用 eachDir() 而不是 eachFile()。还提供了 eachDirMatch() 和 eachDirRecurse() 方法。
可以看到，对 File 仅使用 each() 方法并不能提供足够的含义。典型 each() 方法的语义保存在 File 中，但是方法名更具有描述性，从而提供更多有关这个高级功能的信息。
 
URL 迭代
理解了如何遍历 File 后，可以使用相同的原则遍历 HTTP 请求的响应。Groovy 为 java.net.URL 提供了一个方便的（和熟悉的）eachLine() 方法。
例如，清单 24 将逐行遍历 ibm.com 主页的 HTML：

清单 24. URL 迭代
				
def url = new URL("http://www.ibm.com")
url.eachLine{line->
  println line
}
 
当然，如果这就是您的目的的话，Groovy 提供了一个只包含一行代码的解决办法，这主要归功于 toURL() 方法，它被添加到所有 Strings："http://www.ibm.com".toURL().eachLine{ println it }。
但是，如果希望对 HTTP 响应执行一些更有用的操作，该怎么办呢？具体来讲，如果发出的请求指向一个 RESTful Web 服务，而该服务包含您要解析的 XML，该怎么做呢？each() 方法将在这种情况下提供帮助。
 
XML 迭代
您已经了解了如何对文件和 URL 使用 eachLine() 方法。XML 给出了一个稍微有些不同的问题 — 与逐行遍历 XML 文档相比，您可能更希望对逐个元素进行遍历。
例如，假设您的语言列表存储在名为 languages.xml 的文件中，如清单 25 所示：

清单 25. languages.xml 文件
				
<langs>
  <language>Java</language>
  <language>Groovy</language>
  <language>JavaScript</language>
</langs>
 
Groovy 提供了一个 each() 方法，但是需要做一些修改。如果使用名为 XmlSlurper 的原生 Groovy 类解析 XML，那么可以使用 each() 遍历元素。参见清单 26 所示的例子：

清单 26. XML 迭代
				
def langs = new XmlSlurper().parse("languages.xml")
langs.language.each{
  println it
}

//output
Java
Groovy
JavaScript
 
langs.language.each 语句从名为 <language> 的 <langs> 提取所有元素。如果同时拥有 <format> 和 <server> 元素，它们将不会出现在 each() 方法的输出中。
如果觉得这还不够的话，那么假设这个 XML 是通过一个 RESTful Web 服务的形式获得，而不是文件系统中的文件。使用一个 URL 替换文件的路径，其余代码仍然保持不变，如清单 27 所示：

清单 27. Web 服务调用的 XML 迭代
				
def langs = new XmlSlurper().parse("http://somewhere.com/languages")
langs.language.each{
  println it
}
 
这真是个好方法，each() 方法在这里用得很好，不是吗？
 
结束语
在使用 each() 方法的整个过程中，最妙的部分在于它只需要很少的工作就可以处理大量 Groovy 内容。解了 each() 方法之后，Groovy 中的迭代就易如反掌了。正如 Raymond 所说，这正是关键所在。一旦了解了如何遍历 List，那么很快就会掌握如何遍历数组、Map、String、Range、enum、SQL ResultSet、File、目录和 URL，甚至是 XML 文档的元素。
本文的最后一个示例简单提到使用 XmlSlurper 实现 XML 解析。在下一期文章中，我将继续讨论这个问题，并展示使用 Groovy 进行 XML 解析有多么简单！您将看到 XmlParser 和 XmlSlurper 的实际使用，并更好地了解 Groovy 为什么提供两个类似但又略有不同的类实现 XML 解析。到那时，希望您能发现 Groovy 的更多实际应用。