#IIS配置编程


<!-- @import "[TOC]" {cmd:"toc", depthFrom:1, depthTo:6, orderedList:false} -->
<!-- code_chunk_output -->

* [IIS配置编程](#iis配置编程)
* [Microsoft.Web.Administration操作IIS7站点时的权限问题](#microsoftwebadministration操作iis7站点时的权限问题)
* [nodejs and ActiveXObject](#nodejs-and-activexobject)
* [Sample Code](#sample-code)
	* [AppCmd.exe](#appcmdexe)
	* [C#](#c)
	* [VBScript](#vbscript)
* [参考](#参考)

<!-- /code_chunk_output -->


#Microsoft.Web.Administration操作IIS7站点时的权限问题

应用程序池的高级设置里进程模型下的标识选择为LocalSystem



#nodejs and ActiveXObject

#Sample Code
The following examples add an application pool named Contoso, and set the managed pipeline mode to Integrated.
##AppCmd.exe
```bat
appcmd.exe set config -section:system.applicationHost/applicationPools /+"[name='Contoso',autoStart='True',managedPipelineMode='Integrated']" /commit:apphost
```
You must be sure to set the commit parameter to apphost when you use AppCmd.exe to configure these settings. This commits the configuration settings to the appropriate location section in the ApplicationHost.config file.
##C#

```csharp
using System;
using System.Text;
using Microsoft.Web.Administration;

internal static class Sample {

   private static void Main() {

      using(ServerManager serverManager = new ServerManager()) { 
      Configuration config = serverManager.GetApplicationHostConfiguration();

      ConfigurationSection applicationPoolsSection = config.GetSection("system.applicationHost/applicationPools");

      ConfigurationElementCollection applicationPoolsCollection = applicationPoolsSection.GetCollection();

      ConfigurationElement addElement = applicationPoolsCollection.CreateElement("add");
      addElement["name"] = @"Contoso";
      addElement["autoStart"] = true;
      addElement["managedPipelineMode"] = @"Integrated";
      applicationPoolsCollection.Add(addElement);

      serverManager.CommitChanges();
      }
   }
}
```


##VBScript

```vb
Set adminManager = CreateObject("Microsoft.ApplicationHost.WritableAdminManager")
adminManager.CommitPath = "MACHINE/WEBROOT/APPHOST"
Set applicationPoolsSection = adminManager.GetAdminSection("system.applicationHost/applicationPools","MACHINE/WEBROOT/APPHOST")
Set applicationPoolsCollection = applicationPoolsSection.Collection

Set addElement = applicationPoolsCollection.CreateNewElement("add")
addElement.Properties.Item("name").Value = "Contoso"
addElement.Properties.Item("autoStart").Value = True
addElement.Properties.Item("managedPipelineMode").Value = "Integrated"
applicationPoolsCollection.AddElement(addElement)

adminManager.CommitChanges()
```

#参考

1. Schaefer K, Cochran J, Forsyth S, et al. Professional IIS 7[M]. Wrox Press Ltd. 2008.
2. [Jenkins插件之构建与MSBuild - iTech - 博客园 ](http://www.cnblogs.com/itech/archive/2011/11/17/2252916.html)
3. [.Net项目使用持续集成服务AppVeyor，Travis-CI实战 - #张志豪# - 博客园 ](http://www.cnblogs.com/zhang-zhi-hao/p/DotNET_Project_Uses_Continuous_Integration_Services_AppVeyor_And_TravisCI_In_Action.html)
4. [WIN10 应用程序修改IIS程序池配置及Azure云服务修改程序池配置避免自动回收 - 村_长 - 博客园 ](http://www.cnblogs.com/hepc/p/6340602.html)
5. [【求助】Microsoft.Web.Administration操作IIS7站点时的权限问题-CSDN论坛 ](http://bbs.csdn.net/topics/390193869)
6. [Application Pools <applicationPools> | Microsoft Docs ](https://docs.microsoft.com/en-us/iis/configuration/system.applicationHost/applicationPools/)
7. [winax | npmjs ](https://www.npmjs.com/package/winax)
8. [Node-adodb by nuintun ](http://nuintun.github.io/node-adodb/)
9. [win7 web开发遇到的问题-由于权限不足而无法读取配置文件，无法访问请求的页面 - 殷晶晶-廊坊师范学院信息技术提高班第八期 - CSDN博客 ](http://blog.csdn.net/yinjingjing198808/article/details/7185453)
10. [Accessing iis 7.0 features programmatically from configuration file(S) (C#) – Care, Share and Grow! ](https://blogs.msdn.microsoft.com/saurabh_singh/2007/11/24/accessing-iis-7-0-features-programmatically-from-configuration-files-c/)
11. [c# - Config file reading - Stack Overflow ](https://stackoverflow.com/questions/6516930/config-file-reading)
12. [Failure Settings for an Application Pool <failure> | Microsoft Docs ](https://docs.microsoft.com/en-us/iis/configuration/system.applicationHost/applicationPools/add/failure)
13. [Win7下VS2010、IIS7配置常见问题收集 - 沙耶 - 博客园 ](http://www.cnblogs.com/ShaYeBlog/p/4111722.html)
14. [Using Configuration Editor: Generate Scripts | Microsoft Docs ](https://docs.microsoft.com/en-us/iis/manage/managing-your-configuration-settings/using-configuration-editor-generate-scripts)
15. [Application Pool Defaults <applicationPoolDefaults> | Microsoft Docs ](https://docs.microsoft.com/en-us/iis/configuration/system.applicationHost/applicationPools/applicationPoolDefaults/)
16. [PowerShell: Creating Active Directory Managed Service Accounts - Trevor Sullivan ](https://trevorsullivan.net/2012/10/15/powershell-creating-active-directory-managed-service-accounts/)
17. [Create a virtual directory in IIS from Classic ASP - Stack Overflow ](https://stackoverflow.com/questions/27832748/create-a-virtual-directory-in-iis-from-classic-asp/27945573#27945573)
18. [iis - Classic ASP page is impersonating NT AUTHORITY\ANONYMOUS LOGON - Stack Overflow ](https://stackoverflow.com/questions/20910737/classic-asp-page-is-impersonating-nt-authority-anonymous-logon)
19. [.net - How can I restart Application Pool's from a website without having setting app pool identity to local system? - Stack Overflow ](https://stackoverflow.com/questions/13274964/how-can-i-restart-application-pools-from-a-website-without-having-setting-app-p/13382735#13382735)
20. [New Features Introduced in IIS 10.0 | Microsoft Docs ](https://docs.microsoft.com/en-us/iis/get-started/whats-new-in-iis-10/new-features-introduced-in-iis-10)