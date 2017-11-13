





maven跳过单元测试-maven.test.skip和skipTests的区别 - arkblue的专栏 - 博客频道 - CSDN.NET
 http://blog.csdn.net/arkblue/article/details/50974957


-DskipTests，不执行测试用例，但编译测试用例类生成相应的class文件至target/test-classes下。
-Dmaven.test.skip=true，不执行测试用例，也不编译测试用例类。
不执行测试用例，但编译测试用例类生成相应的class文件至target/test-classes下。


一 使用maven.test.skip，不但跳过单元测试的运行，也跳过测试代码的编译。
[html] view plain copy
   
1.	mvn package -Dmaven.test.skip=true    

也可以在pom.xml文件中修改
[html] view plain copy
   
1.	<plugin>    
2.	    <groupId>org.apache.maven.plugin</groupId>    
3.	    <artifactId>maven-compiler-plugin</artifactId>    
4.	    <version>2.1</version>    
5.	    <configuration>    
6.	        <skip>true</skip>    
7.	    </configuration>    
8.	</plugin>    
9.	<plugin>    
10.	    <groupId>org.apache.maven.plugins</groupId>    
11.	    <artifactId>maven-surefire-plugin</artifactId>    
12.	    <version>2.5</version>    
13.	    <configuration>    
14.	        <skip>true</skip>    
15.	    </configuration>    
16.	</plugin>   


二 使用 mvn package -DskipTests 跳过单元测试，但是会继续编译；如果没时间修改单元测试的bug，或者单元测试编译错误。使用上面的，不要用这个
[html] view plain copy
   
1.	<plugin>    
2.	    <groupId>org.apache.maven.plugins</groupId>    
3.	    <artifactId>maven-surefire-plugin</artifactId>    
4.	    <version>2.5</version>    
5.	    <configuration>    
6.	        <skipTests>true</skipTests>    
7.	    </configuration>    
8.	</plugin>   
 


