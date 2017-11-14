Handlebars.java：逻辑简单、支持语义扩展的Java模板引擎 - 资源 - 伯乐在线 
http://hao.jobbole.com/handlebars-java/





Handlerbars.java 是handlebars的一种Java编程入口。Handlebars能够让你毫无压力地，并且高效地构建语义模板。遵循Apache 2.0开源协议发布。

handlebars_java

Mustache模板兼容Handlebars，可以用Mustache编写一个模板然后导入到Handlebars中。这样便也可以使用到Handlebars的其他更多优势功能了。

性能

Handlebars.java 是一个时下流行、功能强大的模板引擎，同时还有不错的性能表现：

Template Comparison

Benchmark 的源码地址：https://github.com/mbosecke/template-benchmark

开始

总的来说，Handlebars模板语法是包含了Mustache的模板语法的。常用的基本语法，可以参考一下Mustache的用户使用手册

要找入门教程，Handlebars.java blog 也是个不错的选择。

Maven

稳定版本  Maven Central

XHTML

<dependency>
	<groupId>com.github.jknack</groupId>
	<artifactId>handlebars</artifactId>
	<version>${handlebars-version}</version>
</dependency>
1
2
3
4
5
<dependency>
	<groupId>com.github.jknack</groupId>
	<artifactId>handlebars</artifactId>
	<version>${handlebars-version}</version>
</dependency>
开发版本

SNAPSHOT版本是没有同步到Maven中央仓库的，如要使用，把这个仓库地址加入到你的pom.xml中：

https://oss.sonatype.org/content/repositories/snapshots/
Hello Handlebars.java

Java

Handlebars handlebars = new Handlebars();
Template template = handlebars.compileInline("Hello {{this}}!");
System.out.println(template.apply("Handlebars.java"));
1
2
3
Handlebars handlebars = new Handlebars();
Template template = handlebars.compileInline("Hello {{this}}!");
System.out.println(template.apply("Handlebars.java"));
输出:

Shell

Hello Handlebars.java!
1
Hello Handlebars.java!
加载模板

模板加载要使用TemplateLoader类来加载， Handlebars.java 提供了3种TemplateLoader实现方案

ClassPathTemplateLoader（默认方式）
FileTemplateLoader
SpringTemplateLoader（参见 handlebars-springmvc 模块）
这个例子将从classpath的根路径加载模板文件mytemplate.hbs。

mytemplate.hbs:

Java

Hello {{this}}!
Handlebars handlebars = new Handlebars();
Template template = handlebars.compile("mytemplate");
System.out.println(template.apply("Handlebars.java"));
1
2
3
4
Hello {{this}}!
Handlebars handlebars = new Handlebars();
Template template = handlebars.compile("mytemplate");
System.out.println(template.apply("Handlebars.java"));
输出:

Shell

Hello Handlebars.java!
1
Hello Handlebars.java!
你可以指定一个不同的TemplateLoader：

Java

TemplateLoader loader = ...;
Handlebars handlebars = new Handlebars(loader);
1
2
TemplateLoader loader = ...;
Handlebars handlebars = new Handlebars(loader);
模板的前缀和后缀

TemplateLoader有两个重要的属性：

前缀：用来设置模板的默认存储路径。
后缀：用来设置模板的追加后缀或者文件扩展名等等，默认追加 .hbs。
举例:

Java

TemplateLoader loader = new ClassPathTemplateLoader();
loader.setPrefix("/templates");
loader.setSuffix(".html");
Handlebars handlebars = new Handlebars(loader);
Template template = handlebars.compile("mytemplate");
System.out.println(template.apply("Handlebars.java"));
1
2
3
4
5
6
TemplateLoader loader = new ClassPathTemplateLoader();
loader.setPrefix("/templates");
loader.setSuffix(".html");
Handlebars handlebars = new Handlebars(loader);
Template template = handlebars.compile("mytemplate");
System.out.println(template.apply("Handlebars.java"));
Handlebars.java 会将mytemplate映射成 /templates/mytemplate.html 去加载它

Handlebars.java服务器

handlebars.java server 是一个小的应用程序， 你可以通过它来编写Mustache或者Handlebars的模板并将它们加入数据。

对于Web开发者来说，这很有用。

从Maven中心仓库下载：

点击 这里
在Download模块下选择jar
Maven：

XHTML

<dependency>
  <groupId>com.github.jknack</groupId>
  <artifactId>handlebars-proto</artifactId>
  <version>${current-version}</version>
</dependency>
1
2
3
4
5
<dependency>
  <groupId>com.github.jknack</groupId>
  <artifactId>handlebars-proto</artifactId>
  <version>${current-version}</version>
</dependency>
用法 : java -jar handlebars-proto-${current-version}.jar -dir myTemplates

示例:

myTemplates/home.hbs


<ul>
 {{#items}}
 {{name}}
 {{/items}}
</ul>
1
2
3
4
5
<ul>
 {{#items}}
 {{name}}
 {{/items}}
</ul>
myTemplates/home.json


{
  "items": [
    {
      "name": "Handlebars.java rocks!"
    }
  ]
}
1
2
3
4
5
6
7
{
  "items": [
    {
      "name": "Handlebars.java rocks!"
    }
  ]
}
或者你更喜欢用YAML的话 myTemplates/home.yml:


list: - name: Handlebars.java rocks!
1
list: - name: Handlebars.java rocks!
打开浏览器输入:


http://localhost:6780/home.hbs
1
http://localhost:6780/home.hbs
是不是很棒！

依赖的Jar包


+- org.apache.commons:commons-lang3:jar:3.1
+- org.antlr:antlr4-runtime:jar:4.0
+- org.mozilla:rhino:jar:1.7R4
+- org.slf4j:slf4j-api:jar:1.6.4
1
2
3
4
+- org.apache.commons:commons-lang3:jar:3.1
+- org.antlr:antlr4-runtime:jar:4.0
+- org.mozilla:rhino:jar:1.7R4
+- org.slf4j:slf4j-api:jar:1.6.4
相关项目

Handlebars.js
Try Handlebars.js
Mustache
Humanize
ANTLRv4
作者

Edgar Espina
官方网站：http://jknack.github.io/handlebars.java/
开源地址：https://github.com/jknack/handlebars.java