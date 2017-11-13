maven2 更新snapshots jar包的配置 - LionBule - ITeye技术网站
 http://lionbule.iteye.com/blog/641718


<repositories>
   <repository>
      <id>dev-nexus</id>
      <url>http://ob.yihecloud.com:88/nexus/content/groups/public/</url>
      <snapshots>
         <enabled>true</enabled>
         <updatePolicy>always</updatePolicy>
      </snapshots>
   </repository>
</repositories>


[问题再现]
    maven在编译工程时，无法及时更新snapshots jar包。
    maven工程引入snapshots jar包时，jar的snapshots的版本已经确定，但是jar的内容是经常变化的。所以真实的需求是编译工程时能及时更新snapshots jar包。
 
[期望结果]
    maven能在编译时及时更新snapshots jar包。
 
[解决办法]
    在pom.xml中增加如下配置。
Pom代码   
1.	<repositories>  
2.	    <repository>  
3.	      <id>xxmirror</id>  
4.	      <name>*****</name>  
5.	      <layout>default</layout>  
6.	      <url>http://***.com/mvn/repository</url>  
7.	    <snapshots>  
8.	        <enabled>true</enabled>  
9.	    </snapshots>  
10.	    </repository>  
11.	  </repositories>  


