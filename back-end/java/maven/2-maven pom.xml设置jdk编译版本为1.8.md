maven pom.xml设置jdk编译版本为1.8 - 夜De第七章的博客的博客 - CSDN博客 http://blog.csdn.net/qq_34545192/article/details/73856345

<build>  
        <finalName>myweb</finalName>  
        <plugins>  
            <!--JDK版本 -->  
            <plugin>  
                <groupId>org.apache.maven.plugins</groupId>  
                <artifactId>maven-compiler-plugin</artifactId>  
                <version>2.5.1</version>  
                <configuration>  
                    <source>1.8</source>  
                    <target>1.8</target>  
                    <encoding>UTF-8</encoding>  
                    <showWarnings>true</showWarnings>  
                </configuration>  
            </plugin>  
        </plugins>  
</build>  

闲来无事研究1.8的lambda ,发现报错:
Error:(19, 28) java: -source 1.5 中不支持 lambda 表达式
  (请使用 -source 8 或更高版本以启用 lambda 表达式)
查阅资料得知需要设置编译版本为1.8 ,加入<plugin>中的代码即可
//文章整理上传于2017-06-28