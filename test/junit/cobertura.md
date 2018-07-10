
# Java测试覆盖率工具----Cobertura,EclEmma

* [Java测试覆盖率工具----Cobertura,EclEmma - Dragon's Life - CSDN博客 ](http://blog.csdn.net/wanghantong/article/details/39270997)

Cobertura 是一个与Junit集成的代码覆盖率测量工具
它是免费、开源的
它可以与Ant和Maven集成，也可以通过命令行调用
可以生成HTML或XML格式的报告
可以按照不同的标准对HTML结果进行排序
为每个类、包以及整个项目计算所覆盖的代码行与代码分支的百分比例
原创文章，版权所有，允许转载，标明出处：http://blog.csdn.net/wanghantong
Eclipse插件地址： http://ecobertura.johoop.de/update/ (requires Eclipse 3.5+)

使用Ant来执行Cobertura
操作步骤：
1.添加核心依赖jar包---
2.在 build.xml 文件中添加一个任务定义。以下这个顶级taskdef 元素将 cobertura.jar 文件限定在当前工作目录中：
[html] view plain copy
<taskdef classpath="cobertura.jar" resource="tasks.properties" />  
3.被测量的类必须在原始类出现在类路径中之前出现在类路径中，而且需要将 Cobertura JAR 文件添加到类路径中：
```xml
<target name="cover-test" depends="instrument">  
  <mkdir dir="${testreportdir}" />  
  <junit dir="./" failureproperty="test.failure" printSummary="yes"   
         fork="true" haltonerror="true">  
    <!-- Normally you can create this task by copying your existing JUnit  
         target, changing its name, and adding these next two lines.  
         You may need to change the locations to point to wherever   
         you've put the cobertura.jar file and the instrumented classes. -->  
    <classpath location="cobertura.jar"/>  
    <classpath location="target/instrumented-classes"/>  
    <classpath>  
      <fileset dir="${libdir}">  
        <include name="*.jar" />  
      </fileset>  
      <pathelement path="${testclassesdir}" />  
      <pathelement path="${classesdir}" />  
    </classpath>  
    <batchtest todir="${testreportdir}">  
      <fileset dir="src/java/test">  
        <include name="**/*Test.java" />  
        <include name="org/jaxen/javabean/*Test.java" />  
      </fileset>  
    </batchtest>  
  </junit>  
</target>>  
```
4.cobertura-report 任务生成测试报告 HTML 文件：
```xml
<target name="coverage-report" depends="cover-test">
 <cobertura-report srcdir="src/java/main" destdir="cobertura"/>
</target>
```
5.srcdir 属性指定原始的 .java 源代码在什么地方。destdir 属性指定 Cobertura 放置输出 HTML 的那个目录的名称。
在自己的 Ant 编译文件中加入了类似的任务后，就可以通过键入以下命令来生成一个覆盖报告：
```
% ant instrument  
% ant cover-test  
% ant coverage-report  
```
在Java测试覆盖率工具上，还有一个更加简单的工具：EclEmma(推荐) ,笔者目前也在使用EclEmma，它可以很方便的与Eclipse集成，然后可以直接run，显示出代码覆盖率，其地址是：http://www.eclemma.org/
我们可以在Eclipse的MarketPlace中直接搜索并下载安装
在这里我就不过多介绍了，有兴趣的同学可以自己尝试。
原创文章，版权所有，允许转载，标明出处：http://blog.csdn.net/wanghantong
——不要太高估自己在集体中的力量，因为当你选择离开时，就会发现即使没有你，太阳照常升起！