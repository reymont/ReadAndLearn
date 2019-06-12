maven中把依赖的JAR包一起打包 - lvjun106 - ITeye技术网站
http://lvjun106.iteye.com/blog/1849803


maven中把依赖的JAR包一起打包
博客分类： maven
项目管理
敏捷开发
 
 .


 
这里所用到的MAVEN-PLUGIN是MAVNE-ASSEMBLY-PLUGIN
 
官方网站是:http://maven.apache.org/plugins/maven-assembly-plugin/usage.html
 
 
 
1. 添加此PLUGIN到项目的POM.XML中
 
 
 


Xml代码  
1.<buizld>  
2.        <plugins>  
3.            <plugin>  
4.                <artifactId>maven-assembly-plugin</artifactId>  
5.                <configuration>  
6.                    <archive>  
7.                        <manifest>  
8.                            <mainClass>com.allen.capturewebdata.Main</mainClass>  
9.                        </manifest>  
10.                    </archive>  
11.                    <descriptorRefs>  
12.                        <descriptorRef>jar-with-dependencies</descriptorRef>  
13.                    </descriptorRefs>  
14.                </configuration>  
15.            </plugin>  
16.        </plugins>  
17.    </build>  
 
 
 
 
 
如果出现CLASS重名的情况,这时候就要把最新的版本号添加进去即可,
 
 
 
2, 在当前项目下执行mvn assembly:assembly, 执行成功后会在target文件夹下多出一个以-jar-with-dependencies结尾的JAR包. 这个JAR包就包含了项目所依赖的所有JAR的CLASS.
 
 
 
3.如果不希望依赖的JAR包变成CLASS的话,可以修改ASSEMBLY插件.
 
  3.1 找到assembly在本地的地址,一般是c:/users/${your_login_name}/.m2/\org\apache\maven\plugins\maven-assembly-plugin\2.4
 
  3.2 用WINZIP或解压工具打开此目录下的maven-assembly-plugin-2.4.jar, 找到assemblies\jar-with-dependencies.xml
 
   3.3 把里面的UNPACK改成FALSE即可
