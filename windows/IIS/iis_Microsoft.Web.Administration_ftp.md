
#FTP自动化C#(Microsoft.Web.Administration)开发


<!-- @import "[TOC]" {cmd:"toc", depthFrom:1, depthTo:6, orderedList:false} -->
<!-- code_chunk_output -->

* [FTP自动化C#(Microsoft.Web.Administration)开发](#ftp自动化cmicrosoftwebadministration开发)
* [概述](#概述)
* [配置FTP](#配置ftp)
* [新增FTP站点、部署、SSL](#新增ftp站点-部署-ssl)
* [FTP授权规则](#ftp授权规则)
* [自定义日志](#自定义日志)
* [启动FTP服务协议](#启动ftp服务协议)
* [新增用户和权限认证](#新增用户和权限认证)
* [SSL配置](#ssl配置)
* [创建FTP站点](#创建ftp站点)
* [applicationHost.config](#applicationhostconfig)
* [启动FTP命令](#启动ftp命令)

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

#启动FTP服务协议

- [除非Microsoft FTP 服务（FTPSVC）正在运行，否则无法启动FTP站点。服务目前已停止_草原孤狼_新浪博客 ](http://blog.sina.com.cn/s/blog_a61b811e01016c8y.html)

点击开始，启动运行  输入services.msc  打开win7服务管理  启动microsoft ftp sercive

#新增用户和权限认证

下面的示例为FTP站点启用匿名身份验证，将密码设置为“PW”，并将用户名设置为“AUSR”。

- [FTP Anonymous Authentication <anonymousAuthentication> | Microsoft Docs ](https://docs.microsoft.com/en-us/iis/configuration/system.applicationhost/sites/site/ftpserver/security/authentication/anonymousauthentication#sample-code)

```csharp
//创建基本认证和本机用户
ConfigurationElement authenticationElement = ecurityElement.GetChildElement("authentication");
ConfigurationElement basicAuthenticationElement = uthenticationElement.GetChildElement("basicAuthentication")
basicAuthenticationElement["enabled"] = true;
ConfigurationElement addElement1 = thorizationCollection.CreateElement("add")
addElement1["accessType"] = "Allow";
addElement1["users"] = "dell";
addElement1["permissions"] = "Read";
authorizationCollection.Add(addElement1);
```

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
            ConfigurationElement securityElement = ftpServerElement.GetChildElement("security");
            ConfigurationElement authenticationElement = securityElement.GetChildElement("authentication");
            ConfigurationElement anonymousAuthenticationElement = authenticationElement.GetChildElement("anonymousAuthentication");
            anonymousAuthenticationElement["enabled"] = true;
            anonymousAuthenticationElement["password"] = "PW";
            anonymousAuthenticationElement["userName"] = "AUSR";

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

#SSL配置

- [FTP over SSL <ssl> | Microsoft Docs ](https://docs.microsoft.com/en-us/iis/configuration/system.applicationHost/sites/site/ftpServer/security/ssl)

匿名访问时则不能添加**serverCertHash**。

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
         ConfigurationElement securityElement = ftpServerElement.GetChildElement("security");

         ConfigurationElement sslElement = securityElement.GetChildElement("ssl");
         sslElement["serverCertHash"] = @"57686f6120447564652c2049495320526f636b73";
         sslElement["controlChannelPolicy"] = @"SslRequire";
         sslElement["dataChannelPolicy"] = @"SslRequire";

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

# 创建FTP站点

- [Provisioning Sample in C# | Microsoft Docs ](https://docs.microsoft.com/en-us/iis/manage/provisioning-and-managing-iis/provisioning-sample-in-c#CreateFTPsite)

```csharp
public static bool CreateFtpSite(string applicationPoolName,string siteName, string domainName, string userName, string password,string contentPath, string ipAddress, string tcpPort, string hostHeader)
{
	try
	{
		//provision the application pool
		using (ServerManager mgr = new ServerManager())
		{
			ApplicationPool appPool = mgr.ApplicationPools[applicationPoolName];
			//per IIS7 team recommendation, we always create a new application pool
			//create new application pool
			if (appPool == null)
			{
				appPool = mgr.ApplicationPools.Add(applicationPoolName);
				//set the application pool attribute
				appPool.ProcessModel.IdentityType = ProcessModelIdentityType.SpecificUser;
				appPool.ProcessModel.UserName = domainName + "\\" + userName;
				appPool.ProcessModel.Password = password;
			}
			//if the appPool is null, we throw an exception. The appPool should be created or already exists.
			if (appPool == null)
				throw new Exception("Invalid Application Pool.");
			//if the site already exists, throw an exception
			if (mgr.Sites[siteName] != null)
				throw new Exception("Site already exists.");
			//create site
			Site newSite = mgr.Sites.CreateElement();                   
			newSite.Id = GenerateNewSiteID(mgr, siteName);
			newSite.SetAttributeValue("name", siteName);
			newSite.ServerAutoStart = true;
			mgr.Sites.Add(newSite);
			//create the default application for the site
			Application newApp = newSite.Applications.CreateElement();
			newApp.SetAttributeValue("path", "/"); //set to default root path
			newApp.SetAttributeValue("applicationPool", applicationPoolName);
			newSite.Applications.Add(newApp);
			//create the default virtual directory
			VirtualDirectory newVirtualDirectory = newApp.VirtualDirectories.CreateElement();
			newVirtualDirectory.SetAttributeValue("path", "/");
			newVirtualDirectory.SetAttributeValue("physicalPath", contentPath);
			newApp.VirtualDirectories.Add(newVirtualDirectory);
			//add the bindings 
			Binding binding = newSite.Bindings.CreateElement();
			binding.SetAttributeValue("protocol", "ftp");
			binding.SetAttributeValue("bindingInformation", ipAddress + ":" + tcpPort + ":" + hostHeader);
			newSite.Bindings.Add(binding);
			//commit the changes
			mgr.CommitChanges();
		}
	}
	catch (Exception ex)
	{
		throw new Exception(ex.Message, ex);
	}
	return true;
}
```

# applicationHost.config

- [visual studio 2015 - Where is the template for applicationHost.config file stored - Stack Overflow ](https://stackoverflow.com/questions/31713624/where-is-the-template-for-applicationhost-config-file-stored)

选择任意网站->添加FTP发布->无SSL->身份验证（匿名），授权（所有用户，读取）
选择任意网站->配置编辑器->搜索配置->ApplicationHost.config

```xml
<site name="站点" id="3">
    <application path="/">
        <virtualDirectory path="/" physicalPath="E:\inetpub\WebSite2" />
    </application>
    <bindings>
        <binding protocol="http" bindingInformation=":80:" />
        <binding protocol="ftp" bindingInformation="*:21:" />
    </bindings>
    <ftpServer>
        <security>
            <ssl controlChannelPolicy="SslAllow" dataChannelPolicy="SslAllow" />
            <authentication>
                <anonymousAuthentication enabled="true" />
            </authentication>
        </security>
    </ftpServer>
</site>

<location path="站点">
    <system.ftpServer>
        <security>
            <authorization>
                <add accessType="Allow" users="*" permissions="Read" />
            </authorization>
        </security>
    </system.ftpServer>
</location>
```

#启动FTP命令

The <Start> method of the <ftpServer> element starts the FTP site that <ftpServer> applies to. Once the <Start> method has been called, the run-time state for the FTP site can be determined by the value of the state attribute.
<ftpServer>元素中<Start>方法启动了指定的<ftpServer>的FTP站点。一旦调用<Start>方法，FTP站点的运行时状态可以观察`状态(state)`属性。


- [FTP Site Start Method <Start> | Microsoft Docs ](https://docs.microsoft.com/en-us/iis/configuration/system.applicationhost/sites/site/ftpserver/start)

```cs
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
            // Retrieve the sites collection.
            ConfigurationSection sitesSection = config.GetSection("system.applicationHost/sites");
            ConfigurationElementCollection sitesCollection = sitesSection.GetCollection();

            // Locate a specific site.
            ConfigurationElement siteElement = FindElement(sitesCollection, "site", "name", @"mySite");
            if (siteElement == null) throw new InvalidOperationException("Element not found!");

            // Create an object for the ftpServer element.
            ConfigurationElement ftpServerElement = siteElement.GetChildElement("ftpServer");
            // Create an instance of the Start method.
            ConfigurationMethodInstance Start = ftpServerElement.Methods["Start"].CreateInstance();
            // Execute the method to start the FTP site.
            Start.Execute();
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
