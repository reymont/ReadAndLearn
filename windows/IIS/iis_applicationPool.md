


 - [谢弗. IIS 7开发与管理完全参考手册[M]. 清华大学出版社, 2009.](http://www.tup.tsinghua.edu.cn/upload/books/yz/028328-01.pdf)

#虚拟目录呵和应用程序

应用程序分隔网站及其组成部分。一个应用程序可以包括多个虚拟目录。
虚拟目录是指向一个本地或远程物理路径的的指针。总是存在于应用程序中。


#托管的管道模式

支持两种：IIS7提供的集成管道模式，由先前版本的IIS提供的经典管道模式

#特殊字符转义编码

- [网址URL中特殊字符转义编码_百度文库 ](https://wenku.baidu.com/view/ff8cd627f111f18583d05a43.html) 

确定**physicalPath**时，url斜线用%5C代替
网址URL中特殊字符转义编码

字符 - URL编码值
空格 - %20
" - %22
\# - %23
% - %25
& - %26
( - %28
) - %29
\+ - %2B
, - %2C
/ - %2F
: - %3A
; - %3B
< - %3C
= - %3D
> - %3E
? - %3F
@ - %40
\ - %5C
| - %7C
URL特殊字符转义

URL中一些字符的特殊含义，基本编码规则如下：

1、空格换成加号(+)
2、正斜杠(/)分隔目录和子目录
3、问号(?)分隔URL和查询
4、百分号(%)制定特殊字符
5、#号指定书签
6、&号分隔参数

如果需要在URL中用到，需要将这些特殊字符换成相应的十六进制的值
+ %2B
/ %2F
? %3F
% %25
\# %23
& %26

由于在项目中经常要用AJAX传SQL给后台服务端
会遇到select num+1 from dual或者左右连接形式。总会丢掉(+)
这个时候可以尝试用一下URL特殊字符转义
用JS的encodeURI()函数或者直接改成相对应的十六进制的值
看网上介绍encodeURI函数也是讲URI转义



#cpu的限制
- [CPU Settings for an Application Pool <cpu> | Microsoft Docs ](https://docs.microsoft.com/en-us/iis/configuration/system.applicationhost/applicationpools/add/cpu)

- [ApplicationPool 类 (Microsoft.Web.Administration) ](https://msdn.microsoft.com/zh-cn/library/microsoft.web.administration.applicationpool(v=vs.90).aspx)

```csharp
using System;
using System.Text;
using Microsoft.Web.Administration;

internal static class Sample
{
   private static void Main()
   {
      using (ServerManager serverManager = new ServerManager())
      {
         Configuration config = serverManager.GetApplicationHostConfiguration();
         ConfigurationSection applicationPoolsSection = config.GetSection("system.applicationHost/applicationPools");
         ConfigurationElementCollection applicationPoolsCollection = applicationPoolsSection.GetCollection();
         ConfigurationElement addElement = FindElement(applicationPoolsCollection, "add", "name", @"DefaultAppPool");

         if (addElement == null) throw new InvalidOperationException("Element not found!");

         ConfigurationElement cpuElement = addElement.GetChildElement("cpu");
         cpuElement["action"] = @"KillW3wp";
         cpuElement["resetInterval"] = TimeSpan.Parse("00:04:00");

         serverManager.CommitChanges();
      }
   }

   private static ConfigurationElement FindElement(ConfigurationElementCollection collection, string elementTagName, params string[] keyValues)
   {
      foreach (ConfigurationElement element in collection)
      {
         if (String.Equals(element.ElementTagName, elementTagName, StringComparison.OrdinalIgnoreCase))
         {
            bool matches = true;
            for (int i = 0; i < keyValues.Length; i += 2)
            {
               object o = element.GetAttributeValue(keyValues[i]);
               string value = null;
               if (o != null)
               {
                  value = o.ToString();
               }
               if (!String.Equals(value, keyValues[i + 1], StringComparison.OrdinalIgnoreCase))
               {
                  matches = false;
                  break;
               }
            }
            if (matches)
            {
               return element;
            }
         }
      }
      return null;
   }
}
```