
#FTP自动化C#(Microsoft.Web.Administration)开发


<!-- @import "[TOC]" {cmd:"toc", depthFrom:1, depthTo:6, orderedList:false} -->
<!-- code_chunk_output -->

* [FTP自动化C#(Microsoft.Web.Administration)开发](#ftp自动化cmicrosoftwebadministration开发)
* [概述](#概述)
* [配置FTP](#配置ftp)
* [新增FTP站点、部署、SSL](#新增ftp站点-部署-ssl)
* [FTP授权规则](#ftp授权规则)
* [自定义日志](#自定义日志)

<!-- /code_chunk_output -->

#概述

手动在iismanager中操作，没有比代码中操作来的直接。翻阅了《谢弗. IIS 7开发与管理完全参考手册[M]. 清华大学出版社, 2009.》，并没有专门介绍如何通过`Microsoft.Web.Administratio`来管理FTP。本文是对[docs.microsoft.com](https://docs.microsoft.com)中IIS的FTP开发一个总结。

如果不知道`Microsoft.Web.Administration`，请看这篇文章[How to Use Microsoft.Web.Administration | Microsoft Docs ](https://docs.microsoft.com/en-us/iis/manage/scripting/how-to-use-microsoftwebadministration)

- [FTP Site-level Settings <ftpServer> | Microsoft Docs ](https://docs.microsoft.com/en-us/iis/configuration/system.applicationhost/sites/site/ftpserver/#sample-code)

在IIS 6.0中，FTP服务的设置存储在一个单独的`metabase`中，而不是Web站点内。在IIS 7之后，FTP设置存储在`ApplicationHost.config`文件中。在`<site>`和`<siteDefaults>`元素内保存了Web站点的设置。因此，在`<ftpServer>`元素中指定的设置无法生效，也不能在`<location>`元素内指定。

#配置FTP

- [FTP Site-level Settings <ftpServer> | Microsoft Docs ](https://docs.microsoft.com/en-us/iis/configuration/system.applicationhost/sites/site/ftpserver/#sample-code)

下面的示例怎样配置FTP站点，使用了UNIX样式的目录列表，并以字节显示可用的目录存储。

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
         ConfigurationSection sitesSection = config.GetSection("system.applicationHost/sites");
         ConfigurationElementCollection sitesCollection = sitesSection.GetCollection();

         ConfigurationElement siteElement = FindElement(sitesCollection, "site", "name", @"ftp.example.com");
         if (siteElement == null) throw new InvalidOperationException("Element not found!");

         ConfigurationElement ftpServerElement = siteElement.GetChildElement("ftpServer");
         ConfigurationElement directoryBrowseElement = ftpServerElement.GetChildElement("directoryBrowse");
         directoryBrowseElement["showFlags"] = @"StyleUnix, DisplayAvailableBytes";

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


- [How to Use Managed Code (C#) to Create a Simple FTP Authentication Provider | Microsoft Docs ](https://docs.microsoft.com/en-us/iis/develop/developing-for-ftp/how-to-use-managed-code-c-to-create-a-simple-ftp-authentication-provider)

#新增FTP站点、部署、SSL

- [Automating creation of IIS7 FTP site with C# : The Official Microsoft IIS Forums ](https://forums.iis.net/t/1150298.aspx?Automating+creation+of+IIS7+FTP+site+with+C+)

```csharp
using System;
using System.Text;
using Microsoft.Web.Administration;

internal static class Sample {

    private static void Main() {
        
        using(ServerManager serverManager = new ServerManager()) { 
            Configuration config = serverManager.GetApplicationHostConfiguration();
            
            ConfigurationSection sitesSection = config.GetSection("system.applicationHost/sites");
            
            ConfigurationElementCollection sitesCollection = sitesSection.GetCollection();
            
            ConfigurationElement siteElement = sitesCollection.CreateElement("site");
            siteElement["name"] = @"MyFtpSite";
            
            ConfigurationElementCollection bindingsCollection = siteElement.GetCollection("bindings");
            
            ConfigurationElement bindingElement = bindingsCollection.CreateElement("binding");
            bindingElement["protocol"] = @"ftp";
            bindingElement["bindingInformation"] = @"*:21:";
            bindingsCollection.Add(bindingElement);
            
            ConfigurationElement ftpServerElement = siteElement.GetChildElement("ftpServer");
            
            ConfigurationElement securityElement = ftpServerElement.GetChildElement("security");
            
            ConfigurationElement sslElement = securityElement.GetChildElement("ssl");
            sslElement["serverCertHash"] = @"53FC3C74A1978C734751AB7A14A3E48F70A58A84";
            sslElement["controlChannelPolicy"] = @"SslRequire";
            sslElement["dataChannelPolicy"] = @"SslRequire";
            
            ConfigurationElement authenticationElement = securityElement.GetChildElement("authentication");
            
            ConfigurationElement basicAuthenticationElement = authenticationElement.GetChildElement("basicAuthentication");
            basicAuthenticationElement["enabled"] = true;
            
            ConfigurationElementCollection siteCollection = siteElement.GetCollection();
            
            ConfigurationElement applicationElement = siteCollection.CreateElement("application");
            applicationElement["path"] = @"/";
            
            ConfigurationElementCollection applicationCollection = applicationElement.GetCollection();
            
            ConfigurationElement virtualDirectoryElement = applicationCollection.CreateElement("virtualDirectory");
            virtualDirectoryElement["path"] = @"/";
            virtualDirectoryElement["physicalPath"] = @"c:\FtpSite";
            applicationCollection.Add(virtualDirectoryElement);
            siteCollection.Add(applicationElement);
            sitesCollection.Add(siteElement);
            
            serverManager.CommitChanges();
        }
    }
}
```

可以使用MWA来实现默认Web站点的pubishing功能，同时具有基本的身份验证、对所有人的只读权限和启用SSL。

```csharp
        using (ServerManager serverManager = new ServerManager()) {

            // Add FTP publishing to Default Web Site
            Site site = serverManager.Sites["Default Web Site"];

            // Add an FTP Binding to the Site
            site.Bindings.Add(@"*:21:", @"ftp");

            ConfigurationElement ftpServerElement = site.GetChildElement("ftpServer");

            ConfigurationElement securityElement = ftpServerElement.GetChildElement("security");

            // Enable SSL
            ConfigurationElement sslElement = securityElement.GetChildElement("ssl");
            sslElement["serverCertHash"] = @"53FC3C74A1978C734751AB7A14A3E48F70A58A84";
            sslElement["controlChannelPolicy"] = @"SslRequire";
            sslElement["dataChannelPolicy"] = @"SslRequire";

            // Enable Basic Authentication
            ConfigurationElement authenticationElement = securityElement.GetChildElement("authentication");
            ConfigurationElement basicAuthenticationElement = authenticationElement.GetChildElement("basicAuthentication");
            basicAuthenticationElement["enabled"] = true;


            // Add Authorization Rules
            Configuration appHost = serverManager.GetApplicationHostConfiguration();
            ConfigurationSection authorization = appHost.GetSection("system.ftpServer/security/authorization", site.Name);
            ConfigurationElementCollection authorizationRules = authorization.GetCollection();
            ConfigurationElement authElement = authorizationRules.CreateElement();
            authElement["accessType"] = "Allow";
            authElement["users"] = "*";
            authElement["permissions"] = "Read";
            authorizationRules.Add(authElement);


            serverManager.CommitChanges();
        }
```

#FTP授权规则

- [<system.ftpServer> | Microsoft Docs ](https://docs.microsoft.com/en-us/iis/configuration/system.ftpServer/)

下面的示例为默认Web站点添加了两个FTP授权规则。第一个规则允许对管理员组进行读写访问，第二个规则禁止guest帐户读写访问权限。

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
         ConfigurationSection authorizationSection = config.GetSection("system.ftpServer/security/authorization", "Default Web Site");
         ConfigurationElementCollection authorizationCollection = authorizationSection.GetCollection();

         ConfigurationElement addElement = authorizationCollection.CreateElement("add");
         addElement["accessType"] = @"Allow";
         addElement["roles"] = @"administrators";
         addElement["permissions"] = @"Read, Write";
         authorizationCollection.Add(addElement);

         ConfigurationElement addElement1 = authorizationCollection.CreateElement("add");
         addElement1["accessType"] = @"Deny";
         addElement1["users"] = @"guest";
         addElement1["permissions"] = @"Read, Write";
         authorizationCollection.Add(addElement1);

         serverManager.CommitChanges();
      }
   }
}
```

下面的示例为FTP服务器配置\<serverRuntime\>元素，允许FTP虚拟主机名的域名语法
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
         ConfigurationSection serverRuntimeSection = config.GetSection("system.ftpServer/serverRuntime");

         ConfigurationElement hostNameSupportElement = serverRuntimeSection.GetChildElement("hostNameSupport");
         hostNameSupportElement["useDomainNameAsHostName"] = true;

         serverManager.CommitChanges();
      }
   }
}
```

#自定义日志

- [Adding FTP Custom Features <add> | Microsoft Docs ](https://docs.microsoft.com/en-us/iis/configuration/system.applicationHost/sites/site/ftpServer/customFeatures/providers/add)

下面的示例演示了如何为一个FTP站点添加自定义日志程序。

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
         ConfigurationSection sitesSection = config.GetSection("system.applicationHost/sites");
         ConfigurationElementCollection sitesCollection = sitesSection.GetCollection();

         ConfigurationElement siteElement = FindElement(sitesCollection, "site", "name", @"ftp.example.com");
         if (siteElement == null) throw new InvalidOperationException("Element not found!");

         ConfigurationElement ftpServerElement = siteElement.GetChildElement("ftpServer");
         ConfigurationElement customFeaturesElement = ftpServerElement.GetChildElement("customFeatures");
         ConfigurationElementCollection providersCollection = customFeaturesElement.GetCollection("providers");

         ConfigurationElement addElement = providersCollection.CreateElement("add");
         addElement["name"] = @"CustomLoggingModule";
         addElement["enabled"] = true;
         providersCollection.Add(addElement);

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


- [Robert McMurray - Automatically Creating Checksum Files for FTP Uploads ](https://blogs.iis.net/robert_mcmurray/automatically-creating-checksum-files-for-ftp-uploads)