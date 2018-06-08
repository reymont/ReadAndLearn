Maven Archetype Plugin创建新工程2012/10/11

Maven Archetype plugin是Maven用来创建新工程的工具。Archetypes给开源项目很大的帮助，像Apache Wicket、 Apache Cocoon等。这些项目使用Archetypes提供很多新项目的模板。Archetypes也可以帮助公司推行项目标准化。如果你是公司里的一个大团队中的成员，需要依照现有的项目创建新的项目，那么你可以利用团队中使用的archetype来创建新的项目。
有两种方式创建新工程
第一种直接创建
Java代码    
1.	mvn archetype:generate \ 
2.	-DgroupId=org.sonatype.mavenbook \ 
3.	-DartifactId=quickstart \ 
4.	-Dversion=1.0-SNAPSHOT \ 
5.	-DpackageName=org.sonatype.mavenbook \ 
6.	-DarchetypeGroupId=org.apache.maven.archetypes \ 
7.	-DarchetypeArtifactId=maven-archetype-quickstart \ 
8.	-DarchetypeVersion=1.0 \ 
9.	-DinteractiveMode=false 
http://maven.apache.org/archetype/maven-archetype-plugin/create-mojo.html
第二种交互模式
http://maven.apache.org/archetype/maven-archetype-plugin/generate-mojo.html
使用Maven Archetype plugin创建新工程最简单的方式就是以交互模式执行archetype:generate。当交互模式设置为True时，该命令会显示出一个archetypes的列表并提示你选择其中一种类型。默认interactiveMode是True。
Java代码    
1.	mvn archetype:generate 
这种方式，生成的列表archetypes太多，有两种方式限定范围：
1 限定只使用内置的archetypes
Java代码    
1.	mvn archetype:generate -DarchetypeCatalog=internal 
2 使用Filter
Java代码    
1.	mvn archetype:generate -Dfilter=org.apache:struts 

