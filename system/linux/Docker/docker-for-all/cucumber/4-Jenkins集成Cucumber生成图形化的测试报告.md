Jenkins集成Cucumber生成图形化的测试报告 - 牛奋lch - CSDN博客 http://blog.csdn.net/liuchuanhong1/article/details/52593438

1、配置项目pom文件
将Cucumber的启动类配置到pom文件中，在Jenkins构建的时候，会跑Cucumber的测试类，配置如下：
[html] view plain copy
<build>  
        <plugins>  
            <plugin>  
                <groupId>org.apache.maven.plugins</groupId>  
                <artifactId>maven-compiler-plugin</artifactId>  
                <configuration>  
                    <source>1.8</source>  
                    <target>1.8</target>  
                </configuration>  
            </plugin>  
              
            <plugin>    
                <groupId>org.codehaus.mojo</groupId>    
                <artifactId>sonar-maven-plugin</artifactId>  
                <version>3.0.1</version>  
            </plugin>  
            <plugin>  
                <groupId>org.apache.maven.plugins</groupId>  
                <artifactId>maven-surefire-plugin</artifactId>  
                <configuration>  
                    <testFailureIgnore>  
                        true<!-- 因为要执行Cucumber -->  
                    </testFailureIgnore>  
                    <includes>  
                        <include>**/CucumberStart.java</include>  
                    </includes>  
                </configuration>  
            </plugin>  
        </plugins>  
    </build>  

注意CucumberStart.java，这个java类的作用是指定features文件的位置，步骤定义的位置，以及生成的测试报告存放的问题，该类代码如下：

```java
package com.chhliu.myself.cucumberstart;  
  
  
import org.junit.runner.RunWith;  
  
  
import cucumber.api.CucumberOptions;  
import cucumber.api.junit.Cucumber;  
  
  
  
  
 /** 
 * @author chhliu@(邮箱) 
 *  
 * 修改记录 
 * @version 产品版本信息 2015-09-22 姓名(邮箱) 修改信息<br/> 
 *  
 * @RunWith(Cucumber.class) 这是一个运行器 ，指用Cucumber来运行测试 
 * @CucumberOptions中的features，用于指定我们项目中要运行的feature的目录 
 * @CucumberOptions中的format，用于指定我们项目中要运行时生成的报告，并指定之后可以在target目录中找到对应的测试报告 
 * @CucumberOptions中的glue，用于指定项目运行时查找实现step定义文件的目录 
 *  
 * 在实际项目中，随着项目的进行，一个测试工程可能由多个feature文件组成，并且每个feature文件中可能也是由多个scenario组成。默认情况下， 
 * 每次运行是运行所有feature中的所有scenario。这样可能导致正常情况下运行一次测试脚本，需要非常长的时间来等待测试结果。 
 * 但是实际过程中，测试用例是有优先级等区分的。比如smokeTest、regressionTest等。或者有时候会有特别小部分的用例，比如等级是critical， 
 * 这些用例需要长时间运行来监测系统是否没有白页或者页面404等现象。 
 * 所以我们必须区分开所有的scenario，可以使我们在启动测试脚本时，可以根据我们需要来运行哪些模块的scenaro。这时我们可以使用Tags 
 * 在Cucumber里Tag是直接在Feature、Scenari或Scenario Outline关键字前给feature或scenario添加任意数量的前缀为@的tags，多个tag用空格来分隔 
 */  
// tags="@CA",   
@RunWith(Cucumber.class)  
@CucumberOptions(plugin = {"json:target/cucumber/cucumber.json", "html:target/cucumber", "pretty"}, features = "src/test/resources/features/")  
public class CucumberStart {  
}  
```
注：plugin选项用来指定生成的报告格式，多种格式用逗号隔开，glue用来指定cucumber的步骤定义位置，features用来指定features文件的位置  

3、在Jenkins中安装cucumber插件
需要安装的插件如下：

4、新建一个Jenkins项目，并配置
配置如下
4.1 JDK配置

4.2 代码托管地址配置(此处以SVN为例)

4.3 构建触发器配置(什么时候触发Jenkins扫描)

4.4 Maven构建配置

4.5 Sonar构建配置

4.6 代码规范扫描配置

4.7 发布Cucumber测试结果报告

4.8 发布HTML格式的报告

4.9 发布Junit测试结果报告

4.10 发布Cucumber结果报告

5、点击应用保存，并构建
6、构建完成后，效果如下
构建完之后，会多生成这两个链接，点击Cucumber Reports后就可以看到好看的测试报告了，下面是部分截图：


7、Sonar构建结果如下

