Exec Maven Plugin全面解析和使用示例

http://blog.csdn.net/bluishglc/article/details/7622286


本文原文连接: http://blog.csdn.net/bluishglc/article/details/7622286 ,转载请注明出处！

1.为什么使用exec？

现在的工程往往依赖众多的jar包，不像war包工程，对于那些打包成jar包形式的本地java应用来说，通过java命令启动将会是一件极为繁琐的事情，原因很简单，太多的依赖让参数-classpath变得异常的恐怖。为此，在发布应用时，一般使用两种方法来启动应用程序：一种是通过工具将工程及其所有依赖的jar包打包成一个独立的jar包（在maven里有两个插件assemly和shade是用来完成这种工作的）;另一种方法是编写一个run.bat文件，文件包含一个启动应用的java命令，很显然，这个命令的classpath必须包含全部依赖的jar包。但是对于尚处在开发阶段的应用来说，第一种方法需要将所有jar包解压再重新打包，因此非常耗时，特别是工程非常大的时候。第二种方法的问题在于，对处在开发阶段的工程，经常需要引入或升级jar包，这就需要频繁地修改run.bat文件。实际上，对于使用maven管理的工程，完全可以通过maven来获取工程的classpath,简化应用程序的启动命令，这正是maven插件exec被设计出来的主要动机。使用exec比使用java命令去启动应用程序最大的优势就在于：你不需要再去为-classpath而伤脑筋了。

2. exec:exec和exec:java的区别


exec主要由两个goal组成：exec:exec和exec:java。你应该如何选择呢？首先，你需要记住，exec:exec总是比exec:java强大而灵活，这一点会在后面的示例中体现出来，除此之外，两者的主要区别是在线程管理上：exec:exec总是启动一个新的线程，并且在只剩下守护线程的时候从VM上退出(关闭应用程序)。而对于exec:java，当所有非守护线程结束时，守护线程会被joine或interrupt，应该程序不会关闭。但是对于一般的使用者来说，这种差别并不重要。对于两者的选择，一般来说，如果你的工程启动非常简单，不需要设置jvm参数、系统属性、命令行参数，那么就用exec:java，你只需要指定一下mainClass，一切就OK了。例如这面这段配置：
[html] view plaincopy
1.	<plugin>  
2.	    <groupId>org.codehaus.mojo</groupId>  
3.	    <artifactId>exec-maven-plugin</artifactId>  
4.	    <version>1.2.1</version>  
5.	    <executions>  
6.	        <execution>  
7.	            <goals>  
8.	                <goal>java</goal>  
9.	            </goals>  
10.	        </execution>  
11.	    </executions>  
12.	    <configuration>  
13.	        <mainClass>com.yourcompany.app.Main</mainClass>  
14.	    </configuration>  
15.	</plugin>  

如果恰恰相反，你的应用程序启动非常复杂，需要设置jvm参数、系统属性、命令行参数等，那么你就需要使用exec:exec了，下面我们看一个exec:exec的“好”“大”“全”示例。

3.一个“好”“大”“全”的例子


假定我们的应用程序是通过这样的java命令来启动的：

java -DsystemProperty1=value1 -DsystemProperty2=value2 -XX:MaxPermSize=256m -classpath .... com.yourcompany.app.Main arg1 arg2

这个启动命令先后为应用程序设置了必要的系统属性systemProperty1和systemProperty2，然后设置了一个jvm参数，接着是程序的classpath，....省略的部分就是我不说你也能想到会有多么冗长的类路径了，再接下来是程序入口--主类的类名，arg1 arg2是传给应用程序的命令行参数。

3.1. 在xml中配置：

首先我们来看一下如何在pom中通过配置来实现这个启动命令：
[html] view plaincopy
1.	<plugin>  
2.	    <groupId>org.codehaus.mojo</groupId>  
3.	    <artifactId>exec-maven-plugin</artifactId>  
4.	    <version>1.2.1</version>  
5.	    <configuration>  
6.	        <executable>java</executable> <!-- executable指的是要执行什么样的命令 -->  
7.	        <arguments>  
8.	            <argument>-DsystemProperty1=value1</argument> <!-- 这是一个系统属性参数 -->  
9.	            <argument>-DsystemProperty2=value2</argument> <!-- 这是一个系统属性参数 -->  
10.	            <argument>-XX:MaxPermSize=256m</argument> <!-- 这是一个JVM参数 -->  
11.	            <!--automatically creates the classpath using all project dependencies,   
12.	                also adding the project build directory -->  
13.	            <argument>-classpath</argument> <!-- 这是classpath属性，其值就是下面的<classpath/> -->  
14.	            <classpath/> <!-- 这是exec插件最有价值的地方，关于工程的classpath并不需要手动指定，它将由exec自动计算得出 -->  
15.	            <argument>com.yourcompany.app.Main</argument> <!-- 程序入口，主类名称 -->  
16.	            <argument>arg1</argument> <!-- 程序的第一个命令行参数 -->  
17.	            <argument>arg2</argument> <!-- 程序的第二个命令行参数 -->  
18.	        </arguments>  
19.	    </configuration>  
20.	</plugin>  

将上面的配置加到pom中并保存，然后执行：

mvn exec:exec

即可启动应用程序了。

3.2. 在命令行中配置：


除写在pom配置文件中，exec也支持更加灵活的命令行方式来启动，你可以在你的pom中只声明引入了exec插件，不提供任何配置内容，然后在命令行中设置相关参数，同样以上面的命令为例，如果使用命令行方式来配置，那么这个命令将会是：

mvn exec:exec -Dexec.executable="java" -Dexec.args="-DsystemProperty1=value1 -DsystemProperty2=value2 -XX:MaxPermSize=256m -classpath %classpath com.yourcompany.app.Main arg1 arg2"

怎么样，是不是看起来更加简洁？

注意：exec.args指的是exec:exec的commandlineArgs参数，而我们上面xml配置中的参数是arguments，两者是不一样的，这种做法是比较好的，因为exec规定：如果有commandlineArgs，将优先使用commandlineArgs，如果没有再去找是否配置了argument，这样给我们在命令行执行不同设定参数的机会。下面是exec官网对此的相关说明：

1.If commandLineArgs is specified, it will be used as is, except for replacing %classpath with proper classpath using dependencies
2.Otherwise if the property exec.args is specified, it will be used
3.Otherwise the list of argument and classpath will be parsed and used

4.exec:java的限制

前文提到exec:java没有exec:exec的灵活，主要有以下几点：

1.通过exec:java执行程序无法指定jvm参数！
2.exec:java只能在xml中配置系统属性，不能在命令行中设定！
