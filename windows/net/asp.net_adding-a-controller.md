# ASP.NET MVC 5：添加控制器

原文： [Adding a Controller | Microsoft Docs ](https://docs.microsoft.com/en-us/aspnet/mvc/overview/getting-started/introduction/adding-a-controller)

搭建好开发环境 [Getting Started with ASP.NET MVC 5 | Microsoft Docs ](https://docs.microsoft.com/en-us/aspnet/mvc/overview/getting-started/introduction/getting-started)

Adding a Controller
2013-10-17 - 6 min to read - Contributors ![Rick Anderson](https://github.com/Rick-Anderson.png?size=16)  ![Andy Pasic](https://github.com/v-anpasi.png?size=16)  ![Tom Dykstra](https://github.com/tdykstra.png?size=16)
by [Rick Anderson](https://github.com/Rick-Anderson)

MVC代表model-view-controller。MVC是开发应用的架构模式，可测性和易于维护。基于MVC的应用程序包含：
* **M**odels: 表示应用程序数据并使用验证逻辑为该数据强制执行业务规则的类。
* **V**iews: 应用程序动态生成HTML响应的模板文件。
* **C**ontrollers: 处理传入的浏览器请求、检索模型数据，然后指定返回浏览器响应的视图模板的类。

我们将在本系列教程中介绍所有这些概念，并展示如何使用它们构建应用程序。
让我们开始创建一个控制器类。在“解决方案资源管理器”中，右键单击“控制器”文件夹，然后单击“添加”，然后单击“控制器”
![image1.png](https://docs.microsoft.com/en-us/aspnet/mvc/overview/getting-started/introduction/adding-a-controller/_static/image1.png)

在“添加脚手架”对话框中，单击`MVC 5 Controller - Empty`，然后单击“添加”。
![image2.png](https://docs.microsoft.com/en-us/aspnet/mvc/overview/getting-started/introduction/adding-a-controller/_static/image2.png)

命名控制器为“HelloWorldController”，并单击“添加”。
![image3.png](https://docs.microsoft.com/en-us/aspnet/mvc/overview/getting-started/introduction/adding-a-controller/_static/image3.png)

Notice in Solution Explorer that a new file has been created named HelloWorldController.cs and a new folder Views\HelloWorld. The controller is open in the IDE.
注意在解决方案资源管理器中，已经创建了一个名为HelloWorldController.cs的文件和一个文件夹`Views\HelloWorld`。在IDE中打开了该控制器：
![image4.png](https://docs.microsoft.com/en-us/aspnet/mvc/overview/getting-started/introduction/adding-a-controller/_static/image4.png)

用以下代码替换文件的内容：
```cs
using System.Web;
using System.Web.Mvc; 
 
namespace MvcMovie.Controllers 
{ 
    public class HelloWorldController : Controller 
    { 
        // 
        // GET: /HelloWorld/ 
 
        public string Index() 
        { 
            return "This is my <b>default</b> action..."; 
        } 
 
        // 
        // GET: /HelloWorld/Welcome/ 
 
        public string Welcome() 
        { 
            return "This is the Welcome action method..."; 
        } 
    } 
}
```

作为示例，控制器方法将返回一个HTML字符串。该控制器名称为HelloWorldController和第一个方法叫`Index`。让我们从浏览器中调用它。运行应用程序（按F5或Ctrl + F5）。在浏览器中，在地址栏输入路径“HelloWorld”。（例如，http://localhost:1234/HelloWorld. ）在浏览器中，页面会看起来像下图。在上面的方法中，直接返回字符串。让HelloWorldController只返回一些HTML，它做到了！

![image5.png](https://docs.microsoft.com/en-us/aspnet/mvc/overview/getting-started/introduction/adding-a-controller/_static/image5.png)

ASP.NET MVC根据输入的URL，调用不同的控制器类和其中不同的方法（action methods）。ASP.NET MVC默认URL路由使用这样的格式来确定调用具体的代码：

> /[Controller]/[ActionName]/[Parameters]

在`App_Start/RouteConfig.cs`文件设置路由格式。

```cs
public static void RegisterRoutes(RouteCollection routes)
{
    routes.IgnoreRoute("{resource}.axd/{*pathInfo}");

    routes.MapRoute(
        name: "Default",
        url: "{controller}/{action}/{id}",
        defaults: new { controller = "Home", action = "Index", id = UrlParameter.Optional }
    );
}
```

当运行应用程序并且不提供任何URL参数时，默认指定“Home”控制器和名为“index”的action方法。

URL的第一部分决定要执行哪一个控制器类。所以`/HelloWorld`映射到HelloWorldController类。URL的第二部分决定要执行的类上哪一个action方法。因此`/HelloWorld/Index`指定了`HelloWorldController类`的`index`的方法。注意，只需要输入`/HelloWorld`将会默认执行`index`方法。这是因为`index`方法是默认方法。如果没有显式指定，控制器会默认调用。URL第三部分是路由数据（参数），将在后面介绍它。

访问`http://localhost:xxxx/HelloWorld/Welcome`。`Welcome`方法运行并返回字符串“This is the Welcome action method...”。默认MVC映射为`/[Controller]/[ActionName]/[Parameters]`。这个URL，`HelloWorld`是控制器，而`Welcome`是动作方法(action method)。还没有使用URL的[参数]部分。

![image6.png](https://docs.microsoft.com/en-us/aspnet/mvc/overview/getting-started/introduction/adding-a-controller/_static/image6.png)

让我们稍稍修改下例子，传递一些参数信息给的控制器（例如，`/HelloWorld/Welcome?name=Scott&numtimes=4`）。Welcome方法改为包含两个参数，如下所示。请注意，代码采用了C#可选参数特性。如果没有传递值给参数，numTimes将默认为1。

```cs
public string Welcome(string name, int numTimes = 1) {
     return HttpUtility.HtmlEncode("Hello " + name + ", NumTimes is: " + numTimes);
}
```

> 注意
安全注意：上面的代码使用HttpServerUtility.HtmlEncode保护应用免受恶意输入（即JavaScript）。有关更多信息，请参见如何：[通过对字符串应用HTML编码来保护Web应用程序中的脚本攻击](https://msdn.microsoft.com/en-us/library/a2a4yykt(v=vs.100).aspx)。

运行应用程序，访问URL（ http://localhost:xxxx/HelloWorld/Welcome?name=Scott&numtimes=4 ）。可以在URL中尝试不同`name`和`numtimes`的值。ASP.NET MVC模型绑定系统自动从地址栏中映射，查询字符串中的命名参数(name, numTimes)到方法参数`Welcome(string name, int numTimes = 1)`。
![image7.png](https://docs.microsoft.com/en-us/aspnet/mvc/overview/getting-started/introduction/adding-a-controller/_static/image7.png)

在以上示例中，URL片段（参数）没有使用，numtimes参数作为查询字符串传递。在上面的URL，?（问号）是一个分隔符，紧接着就是查询字符串。&连接查询字符串的字符。

用以下代码替换`Welcome`方法：
```cs
public string Welcome(string name, int ID = 1)
{
    return HttpUtility.HtmlEncode("Hello " + name + ", ID: " + ID);
}
```
运行应用程序，访问URL:

>http://localhost:xxx/HelloWorld/Welcome/3?name=Rick

这一次的URL第三部分匹配参数ID。在RegisterRoutes方法中，Welcome动作方法包含一个匹配的URL规范的参数（ID）。

```cs
public static void RegisterRoutes(RouteCollection routes)
{
    routes.IgnoreRoute("{resource}.axd/{*pathInfo}");

    routes.MapRoute(
        name: "Default",
        url: "{controller}/{action}/{id}",
        defaults: new { controller = "Home", action = "Index", id = UrlParameter.Optional }
    );
}
```

在ASP.NET MVC应用程序中，通过参数来访问数据（像ID参数一样），比作为查询字符串传递给方法，更加典型。你也可以在URL添加name和numtimes来路由数据。在`App_Start\RouteConfig.cs`文件，添加“Hello”路由：

```cs
public class RouteConfig
{
   public static void RegisterRoutes(RouteCollection routes)
   {
      routes.IgnoreRoute("{resource}.axd/{*pathInfo}");

      routes.MapRoute(
          name: "Default",
          url: "{controller}/{action}/{id}",
          defaults: new { controller = "Home", action = "Index", id = UrlParameter.Optional }
      );

      routes.MapRoute(
           name: "Hello",
           url: "{controller}/{action}/{name}/{id}"
       );
   }
}
```

运行应用程序，访问URL:

> /localhost:XXX/HelloWorld/Welcome/Scott/3.

在大多数MVC应用程序，默认路由正常工作。在本教程后续学习中，使用模型绑定器(model binder)传递数据，并且不必修改默认路由。

在这些例子中，控制器一直在做MVC的“VC”部分，也就是视图和控制器的工作。控制器直接返回HTML。通常，你不希望控制器直接返回HTML，因为代码变得非常繁琐。相反，我们通常使用一个单独的视图模板文件来生成HTML。[让我们看下如何做到这一点](https://docs.microsoft.com/en-us/aspnet/mvc/overview/getting-started/introduction/adding-a-view)。