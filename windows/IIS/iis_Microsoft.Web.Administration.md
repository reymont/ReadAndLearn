


- [IIS develop in .NET | Microsoft Docs ](https://docs.microsoft.com/en-us/iis/develop/runtime-extensibility/extending-web-server-functionality-in-net)
- [Microsoft API 和参考目录 ](https://msdn.microsoft.com/library)

#Microsoft.Web.Administration

- [Microsoft.Web.Administration | Microsoft Docs ](https://docs.microsoft.com/en-us/iis/manage/provisioning-and-managing-iis/microsoftwebadministration)
- [How to Use Microsoft.Web.Administration | Microsoft Docs ](https://docs.microsoft.com/en-us/iis/manage/scripting/how-to-use-microsoftwebadministration)
- [Accessing Configuration Sections Using Microsoft.Web.Administration (MWA) | Microsoft Docs ](https://docs.microsoft.com/en-us/iis/manage/scripting/accessing-configuration-sections-using-microsoftwebadministration-mwa)
- [Microsoft.Web.Administration in IIS 7 – CarlosAg Blog ](https://blogs.msdn.microsoft.com/carlosag/2006/04/17/microsoft-web-administration-in-iis-7/)


#remove ApplicationPools
-[C# ServerManager IIs 7 - YangangwuWuyangang的专栏 - CSDN博客 ](http://blog.csdn.net/yangangwuwuyangang/article/details/40589251)

```csharp
ApplicationPool oldpool = iisManager.ApplicationPools[siteName + "Pool"];
if (oldpool != null)
{
    iisManager.ApplicationPools.Remove(oldpool);
    iisManager.CommitChanges();
}
```