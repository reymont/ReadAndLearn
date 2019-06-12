maven插件maven-dependency-plugin的使用 - - ITeye技术网站
http://li200429.iteye.com/blog/1745361


maven插件maven-dependency-plugin的使用
博客分类： maven
 
mavenmaven-dependency-plugin .


 
 
	用maven来管理应用，经常会用到这个插件，他的功能很强大，暂说说他的一个功能吧。就是可以将依赖的jar文件拷贝到你指定的文件夹。
 
	使用例子如下：
 
 
 
 
 


Xml代码  
1.<build>  
2.        <plugins>  
3.            <plugin>  
4.                <artifactId>maven-dependency-plugin</artifactId>  
5.                <version>2.1</version>  
6.                <executions>  
7.                    <execution>  
8.                        <id>copy-dependencies</id>  
9.                        <phase>prepare-package</phase>  
10.                        <goals>  
11.                            <goal>copy-dependencies</goal>  
12.                        </goals>  
13.                    </execution>  
14.                </executions>  
15.                <configuration>  
16.                    <includeTypes>jar</includeTypes>  
17.                    <overWriteSnapshots>true</overWriteSnapshots>  
18.                    <type>jar</type>  
19.                    <outputDirectory>${project.build.directory}/lib</outputDirectory>  
20.                </configuration>  
21.            </plugin>  
22.        </plugins>  
23.    </build>  
 
 
 
 说明：
 
 
 1.这个文件放在你需要打包的工程下面，这个工程要么有应用代码，要么依赖其他工程。
 2.<outputDirectory>${project.build.directory}/lib</outputDirectory>中${project.build.directory}是指当前工程的target目录。lib文件夹下会放置所有依赖的jar包。
 
     其他的功能下次再总结吧。
 

