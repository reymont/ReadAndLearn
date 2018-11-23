http://blog.csdn.net/henni_719/article/details/53608144


3.1 场景(Scenarios)
         场景是Cucumber结构的核心之一。每个场景都以关键字“Scenario：”（或本地化一）开头，后面是可选的场景标题。每个Feature可以有一个或多个场景，每个场景由一个或多个步骤组成。一个非常简单的场景示例可以是：
         Scenario：验证帮助功能。给定用户导航到Facebook。当用户单击帮助时，将打开帮助页面。
         考虑一种情况，其中我们需要不止一次地执行测试场景。假设，我们需要确保登录功能适用于所有类型的订阅用户。这需要多次执行登录功能场景。复制粘贴相同的步骤为了只重新执行代码，似乎不是一个聪明的主意。为此，Gherkin提供了一个更多的结构，这是场景概要。
         Scenario Outline: 场景大纲类似于场景结构;唯一的区别是提供多个输入。从下面的示例中可以看出，测试用例保持不变，不可重复。在底部，我们为变量“Username”和“Password”提供了多个输入值。运行实际测试时，Cucumber将用提供的输入值替换变量，它将执行测试。一旦执行了pass-1，测试将使用另一个输入值重新运行第二次迭代。这样的变量或占位符可以用“<>”表示，同时用gherkin语句提及。
    例如：ScenarioOutline：一个社交网站的登录功能。将用于引导到Facebook。当用户输入用户名：<username>，密码：<password>，这时登录成功。
    参数列表如下：
          
有一些提示和技巧来巧妙地定义Cucumber场景：
1. 每个步骤应该清楚地定义，以便它不会给读者造成任何混乱。
2. 不要重复测试场景，如果需要使用场景大纲来实现重复。
3. 以一种方式开发测试步骤，它可以在多个场景和场景大纲中使用。
4. 尽可能保持每个步骤完全独立。例如：“给定用户已登录”。这可以分为两个步骤：输入用户名、点击登录。
3.2 附注(Annotations)
         附注是预定义的文本，其具有特定的含义。 它让编译器/解释器知道，应该在执行时做什么。Cucumber有以下几个附注。
3.2.1 Given
         它描述了要执行的测试的先决条件。示例：GIVEN I am a Facebook user
3.2.2 When
     它定义任何测试场景执行的触发点。示例：WHEN I enter "<username>"
3.2.3 Then
      Then保存要执行的测试的预期结果。示例：THEN loginshould be successful 
3.2.4 And
         它提供任何两个语句之间的逻辑AND条件。AND可以与GIVEN、WHEN和THEN语句结合使用。示例：WHEN I enter my "<username>" AND Ienter my "<password>"
3.2.5 But
         它表示任何两个语句之间的逻辑或条件。But可以与GIVEN、WHEN和THEN语句结合使用。示例：THEN login should be successful.BUT home page should not be missing
3.2.6 Scenario
         关于测试下的场景的详细信息需要在关键字“Scenario:”之后捕获。示例：
       Scenario:
         GIVEN I am aFacebook user
         WHEN I enter my
         AND I enter my
         THEN loginshould be successful.
         BUT home pageshould not be missing.
3.2.7 Scenario Outline
         Scenario Outline: Login functionality for a socialnetworking site.
         Givenuser navigates to Facebook
         WhenI enter Username as "<username>"
         AndPassword as "<password>"
         Thenlogin should be unsuccessful
    示例：
         
3.2.8 Background
         Background通常具有在每个场景运行之前要设置什么的指令。但是，它在“Before”hook之后执行。因此，当我们想要设置Web浏览器或者我们想要建立数据库连接时，这时最佳的运用代码的方式。示例：
         Background:
         Go to Facebook home page.
3.3 场景实例
Step_1：打开Eclipse，在src/test/java包下，创建一个Annotation包并保存。(之前安装环境)
            
Step_2:创建一个名为：Annotation.feature的feature文件。创建步骤，右击Annotation包，选择New file，然后输入文件名：Annotation.feature，打开文件，填写如下信息到文件，并保存：
           
Annotation.feature
[plain] view plain copy
Feature: annotation   
  
#This is how background can be used to eliminate duplicate steps   
Background: User navigates to CSDN  
Given I am on CSDN login page   
  
#Scenario with AND   
Scenario: When I enter username as "TOM"   
And I enter password as "JERRY"   
Then Login should fail   
  
#Scenario with BUT   
Scenario:   
When I enter username as "TOM"   
And I enter password as "JERRY"   
Then Login should fail   
But Relogin option should be available  
Step_3:创建一个step定义文件。创建步骤，右击Annotation包，选择New file，然后输入文件名：Annotation.java，打开文件，填写如下信息到文件，并保存：
      
Annotation.java   
[java] view plain copy
package Annotation;   
import org.openqa.selenium.By;   
import org.openqa.selenium.WebDriver;   
import org.openqa.selenium.chrome.ChromeDriver;  
import cucumber.annotation.en.Given;   
import cucumber.annotation.en.Then;   
import cucumber.annotation.en.When;  
  
public class Annotation {   
    WebDriver driver = null;  
  
    @Given("^I am on CSDN login page$")  
    public void goToCsdn() {   
        driver = new ChromeDriver();  
        driver.navigate().to("https://passport.csdn.net/account/login?ref=toolbar");  
    }   
   
    @When("^I enter username as \"(.*)\"$")  
    public void enterUsername(String arg1) {   
        driver.findElement(By.id("username")).sendKeys(arg1);   
    }  
   
    @When ("^I enter password as \"(.*)\"$")   
    public void enterPassword(String arg1) {   
        driver.findElement(By.id("password")).sendKeys(arg1);   
        driver.findElement(By.className("logging")).click();   
    }  
      
    @Then("^Login should fail$")  
    public void checkFail() {   
        if(driver.getCurrentUrl().equalsIgnoreCase("http://my.csdn.net/my/mycsdn")){  
            System.out.println("Test1 Pass");   
        }   
        else {   
            System.out.println("Test1 Failed");   
        }   
        driver.close();   
        }  
      
    @Then("^Relogin option should be available$")   
    public void checkRelogin() {   
        if(driver.getCurrentUrl().equalsIgnoreCase("http://my.csdn.net/my/mycsdn")){   
            System.out.println("Test2 Pass"); }   
        else {  
            System.out.println("Test2 Failed");   
        }   
        driver.close();   
        }   
}  

Step_4:创建一个runner 类文件。创建步骤，右击Annotation包，选择New file，然后输入文件名：runTest.java，打开文件，填写如下信息到文件，并保存：   
[java] view plain copy
package Annotation;   
import org.junit.runner.RunWith;   
import cucumber.junit.Cucumber;   
@RunWith(Cucumber.class)   
@Cucumber.Options(format={"pretty", "html:target/cucumber"})   
public class runTest {  
      
}  

     
Step_5:运行test的选项：进入左侧包浏览，选择runTest.java，右击选择“Run as”，在弹出框选择“JUnit test”。运行结果如下：
        
运行此类文件时，将观察以下事项：
1.        Csdn在一个新的Chrome Web浏览器实例中打开。
2.        TOM将作为用户名字段的输入传递。
3.        JERRY将作为密码字段的输入传递。
4.        将单击登录。
5.        在登录失败时，浏览器上将显示信息。
6.        在控制台中，您将看到打印的“测试通过”。
7.        步骤结果1.至5.将重新执行用户名为“”和密码为“”。
        