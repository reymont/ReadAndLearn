scm 作用2012/11/12

在Nightly Build的環節，我比較喜歡Clean Build，也就是從Checkout、Compile、Test、Deploy都是一個動作完成的Compile、Test、Deploy都可以靠Maven或Ant完成，但是自VCS中checkout source code就要看plugin的支援程度了。即便是plugin支援度不夠，只要該種VCS有提供command line的模式，我想就能利用shell或script的方式來達到完整的Clean Build。 例如：
git clone [url] ＃checkout source code from VCS
cd [project]
mvn site -Pprod
當然利用Maven提供的SCM來處理也是不錯，除了checkin, checkout之外也可以利用scm plugin來列出changelog或add、remove檔案，不過我個人是比較少用到這些功能就是。

Maven提供的SCM Plugin請參考 http://maven.apache.org/scm/plugins/index.html， 而支援的SCM的完整度則可以考http://maven.apache.org/scm/matrix.html

為了使用Maven的SCM Plugin，通常單獨將<scm>建一個pom.xml，其他plugin或build的東西就免寫了，當然要用原來project的pom.xml也無不可，簡單看個例子。
view source
print?
01.<project xsi:schemalocation="http://maven.apache.org/POM/4.0.0http://maven.apache.org/xsd/maven-4.0.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://maven.apache.org/POM/4.0.0">
02.  <modelversion>4.0.0</modelversion>
03.  
04.  <groupid>idv.elliot</groupid>
05.  <artifactid>BuildDemo</artifactid>
06.  <version>0.0.1-SNAPSHOT</version>
07.  <packaging>pom</packaging>
08.  
09.  <name>BuildDemo</name>
10.  <url>http://github.com/ElliotChen/BuildDemo </url>
11.  
12.  <scm>
13.    <!-- 僅供讀取的Connection URL, 前面必需加上scm:xxx -->
14.    <connection>scm:git:git://github.com/ElliotChen/BuildDemo.git </connection>
15.    <!-- 可以執行checkin的Connection URL, 前面必需加上scm:xxx -->
16.    <developerconnection>scm:git:git://github.com/ElliotChen/BuildDemo.git</developerconnection>
17.    <url>http://github.com/ElliotChen/BuildDemo </url>
18.  </scm>
19.  <build>
20.    <plugins>
21.      <plugin>
22.        <groupid>org.apache.maven.plugins</groupid>
23.        <artifactid>maven-scm-plugin</artifactid>
24.        <version>1.3</version>
25.        <!-- Checkout之後要執行的Goal -->
26.        <configuration>
27.          <goals>site</goals>
28.        </configuration>
29.      </plugin>
30.    </plugins>
31.  </build>
32.</project>

簡單來說，只要在<scm>裡的<connection>填入SCM checkout source code的url，然後在url之前依你使用的SCM種類加上指定的prefix，然後在<maven-scm-plugin>的<configuration>中填上接下來要執行的goal，最後執行
mvn clean scm:bootstrap 
這樣就可以看到像下列的輸出:
[INFO] [scm:bootstrap {execution: default-cli}]
[INFO] Removing /Users/elliot/tmp/target/checkout
[INFO] Executing: /bin/sh -c cd /Users/elliot/tmp/target && git clone git://github.com/ElliotChen/BuildDemo.git /Users/elliot/tmp/target/checkout
[INFO] Working directory: /Users/elliot/tmp/target
[INFO] Executing: /bin/sh -c cd /Users/elliot/tmp/target/checkout && git pull git://github.com/ElliotChen/BuildDemo.git master
[INFO] Working directory: /Users/elliot/tmp/target/checkout
[INFO] Executing: /bin/sh -c cd /Users/elliot/tmp/target/checkout && git checkout
[INFO] Working directory: /Users/elliot/tmp/target/checkout
[INFO] Executing: /bin/sh -c cd /Users/elliot/tmp/target/checkout && git ls-files
[INFO] Working directory: /Users/elliot/tmp/target/checkout
[INFO] Scanning for projects...
[INFO] ------------------------------------------------------------------------
[INFO] Building BuildDemo
[INFO]    task-segment: [site]
[INFO] ------------------------------------------------------------------------
[INFO] [site:site {execution: default-site}]

＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
http://www.juvenxu.com/2010/05/07/reproducibility-of-maven-build/
可重现性（Reproducibility）在维基百科中的解释是：
可重现性是科学方法的主要原则之一，它是指一个测试或试验，能够由其它独立工作的个人准确重现或复制的能力。
在谈Maven构建的可重现性之前，先看一个简单的POM：
view plaincopy to clipboardprint?
1.	<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
2.	  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">  
3.	  <modelVersion>4.0.0</modelVersion>  
4.	  <groupId>com.juvenxu</groupId>  
5.	  <artifactId>test</artifactId>  
6.	  <version>1.0-SNAPSHOT</version>  
7.	  <url>http://www.juvenxu.com</url>  
8.	  <dependencies>  
9.	    <dependency>  
10.	      <groupId>junit</groupId>  
11.	      <artifactId>junit</artifactId>  
12.	      <version>3.8.1</version>  
13.	      <scope>test</scope>  
14.	    </dependency>  
15.	  </dependencies>  
16.	  <build>  
17.	    <plugins>  
18.	      <plugin>  
19.	        <groupId>org.apache.maven.plugins</groupId>  
20.	        <artifactId>maven-javadoc-plugin</artifactId>  
21.	      </plugin>  
22.	    </plugins>  
23.	  </build>  
24.	</project>  
[xml] view plaincopy
1.	<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
2.	  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">  
3.	  <modelVersion>4.0.0</modelVersion>  
4.	  <groupId>com.juvenxu</groupId>  
5.	  <artifactId>test</artifactId>  
6.	  <version>1.0-SNAPSHOT</version>  
7.	  <url>http://www.juvenxu.com</url>  
8.	  <dependencies>  
9.	    <dependency>  
10.	      <groupId>junit</groupId>  
11.	      <artifactId>junit</artifactId>  
12.	      <version>3.8.1</version>  
13.	      <scope>test</scope>  
14.	    </dependency>  
15.	  </dependencies>  
16.	  <build>  
17.	    <plugins>  
18.	      <plugin>  
19.	        <groupId>org.apache.maven.plugins</groupId>  
20.	        <artifactId>maven-javadoc-plugin</artifactId>  
21.	      </plugin>  
22.	    </plugins>  
23.	  </build>  
24.	</project>  
这个POM仅仅就是声明了一个JUnit依赖，然后配置了maven-javadoc-plugin来生成项目的Javadoc文档。初看起来没有什么问题，但是如果你用Maven 3构建该项目，你会看到一段 WARNING 输出，如：
[WARNING] Some problems were encountered while building the effective model for
com.juvenxu:test:jar:1.0-SNAPSHOT
[WARNING] 'build.plugins.plugin.version' for org.apache.maven.plugins:maven-javadoc-plugin
is missing. @
[WARNING]
[WARNING] It is highly recommended to fix these problems because they threaten the stability
of your build.
[WARNING]
[WARNING] For this reason, future Maven versions might no longer support building
such malformed projects.
大致意思就是警告你说，maven-javadoc-plugin没有声明版本，这种配置会威胁你项目构建的稳定性，请修复该问题。
然而，如果你在使用Maven 2，那么你就不会看到这样的警告信息。因此这里实际上涉及到了一个Maven 3 对Maven 2 的改进。对于未声明版本的插件，Maven 2 会自动解析所有仓库中的最新版本（包括SNAPSHOT），Maven 3 会自动解析所有仓库中的最新RELEASE版本，同时给用户发出警告。Maven 3 这么做是为了帮助用户提高构建的可重现性。
有不少的Maven 2用户抱怨Maven插件系统的不稳定，一个项目，同样的源码，同样的POM，昨天构建还是成功的，今天就莫名其妙的失败了，这是怎么回事呢？这其中的原因往往就是因为他们使用某些插件的时候没有声明插件版本，这时可能发生的情况是：昨天Maven解析到插件X的最新版本为1.2.0，该版本与项目兼容得很好；可是今天Maven解析到X的最新版本为1.3.0-SNAPSHOT，由于是快照版且与1.2.0版本差异很大，该版本的插件就与项目出现了兼容性问题，导致了构建失败。
Maven 3 的一个改进地方在于，它在自动解析插件版本的时候，会无视 SNAPSHOT，也就是说，昨天的1.2.0版本今天不可能变成1.3.0-SNAPSHOT，只可能成为1.2.1这样的RELEASE版本，避开快照版本就意味着避开了很大程度的不稳定性。此外，Maven 3还给出警告，推荐用户声明插件的版本，为什么呢？
我们都知道 ，Maven 的行为是由插件决定的，可重现性就意味着基于同样的源码，同样的POM，Maven 的行为不应该发生变化。不幸的是，Maven 的插件版本自动解析机制在方便用户的同时也可能在不同的时间引入不同版本的插件，从而导致 Maven 构建行为的微妙差异，而这种差异是隐式地引入的，因此当出现问题时很难发现根源因素。所以 Maven 3要给出警告，Maven 用户在使用插件的时候应该一直显式地声明插件版本。
需要补充的一点是，Maven 在超级POM中为一些核心的插件声明了版本，如 maven-compiler-plugin，maven-surefire-plugin 等都在其列，因此在使用这些插件的时候你就不再需要担心版本不确定的问题。
基于可重现性原则，我们可以得到以下几条使用 Maven 的最佳实践：
1.	使用插件的使用显式声明版本。原因已在本文论述。
2.	配置依赖的时候显式声明版本。如果依赖声明没有版本，Maven也会自动去解析，但不能保证版本的稳定性，而依赖版本的变化也可能导致构建失败。
3.	除项目内部依赖外，不要依赖其它 SNAPSHOT。项目外部的 SNAPSHOT 依赖随时可能发生变化，且不受你控制，因此不应该使用。
发现你 Maven 项目的潜在问题了么？现在就动手修复吧。
