
* [How to read a section from web.config on IIS7 w/ .net 4 in C# - Stack Overflow ](https://stackoverflow.com/questions/5098406/how-to-read-a-section-from-web-config-on-iis7-w-net-4-in-c-sharp)
```cs
using (var serverManager = new ServerManager())
{
    var siteName = HostingEnvironment.ApplicationHost.GetSiteName();
    var config = serverManager.GetWebConfiguration(siteName);
    var staticContentSection = config.GetSection("system.webServer/staticContent");
    var staticContentCollection = staticContentSection.GetCollection();

    var mimeMap = staticContentCollection.Where(c =>
        c.GetAttributeValue("fileExtension") != null &&
        c.GetAttributeValue("fileExtension").ToString() == ext
    ).Single();

    var mimeType = mimeMap.GetAttributeValue("mimeType").ToString();
    contentType = mimeType.Split(';')[0];
}
```

* [Static Content <staticContent> | Microsoft Docs ](https://docs.microsoft.com/en-us/iis/configuration/system.webserver/staticcontent/)

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
         Configuration config = serverManager.GetWebConfiguration("Default Web Site");

         ConfigurationSection staticContentSection = config.GetSection("system.webServer/staticContent");
         staticContentSection["defaultDocFooter"] = @"The information in this web site is copyrighted.";
         staticContentSection["enableDocFooter"] = true;

         serverManager.CommitChanges();
      }
   }
}
```

* [Adding Static Content MIME Mappings <mimeMap> | Microsoft Docs ](https://docs.microsoft.com/en-us/iis/configuration/system.webserver/staticcontent/mimemap)

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
         Configuration config = serverManager.GetWebConfiguration("Default Web Site");
         ConfigurationSection staticContentSection = config.GetSection("system.webServer/staticContent");
         ConfigurationElementCollection staticContentCollection = staticContentSection.GetCollection();

         ConfigurationElement mimeMapElement = staticContentCollection.CreateElement("mimeMap");
         mimeMapElement["fileExtension"] = @"syx";
         mimeMapElement["mimeType"] = @"application/octet-stream";
         staticContentCollection.Add(mimeMapElement);

         ConfigurationElement mimeMapElement1 = staticContentCollection.CreateElement("mimeMap");
         mimeMapElement1["fileExtension"] = @"tab";
         mimeMapElement1["mimeType"] = @"text/plain";
         staticContentCollection.Add(mimeMapElement1);

         serverManager.CommitChanges();
      }
   }
}
```