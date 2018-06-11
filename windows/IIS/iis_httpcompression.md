


* [Adding Dynamic Types <add> | Microsoft Docs ](https://docs.microsoft.com/en-us/iis/configuration/system.webserver/httpcompression/dynamictypes/add)

```xml
<httpCompression
      directory="%SystemDrive%\inetpub\temp\IIS Temporary Compressed Files">
   <scheme name="gzip" dll="%Windir%\system32\inetsrv\gzip.dll" />
   <dynamicTypes>
      <add mimeType="text/*" enabled="true" />
      <add mimeType="message/*" enabled="true" />
      <add mimeType="application/javascript" enabled="true" />
      <add mimeType="*/*" enabled="false" />
   </dynamicTypes>
   <staticTypes>
      <add mimeType="text/*" enabled="true" />
      <add mimeType="message/*" enabled="true" />
      <add mimeType="application/javascript" enabled="true" />
      <add mimeType="*/*" enabled="false" />
   </staticTypes>
</httpCompression>
```

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
         ConfigurationSection httpCompressionSection = config.GetSection("system.webServer/httpCompression");
         ConfigurationElementCollection dynamicTypesCollection = httpCompressionSection.GetCollection("dynamicTypes");

         ConfigurationElement addElement = dynamicTypesCollection.CreateElement("add");
         addElement["mimeType"] = @"application/msword";
         addElement["enabled"] = true;
         dynamicTypesCollection.Add(addElement);

         ConfigurationElement addElement1 = dynamicTypesCollection.CreateElement("add");
         addElement1["mimeType"] = @"application/vnd.ms-powerpoint";
         addElement1["enabled"] = true;
         dynamicTypesCollection.Add(addElement1);

         ConfigurationElement addElement2 = dynamicTypesCollection.CreateElement("add");
         addElement2["mimeType"] = @"application/vnd.ms-excel";
         addElement2["enabled"] = true;
         dynamicTypesCollection.Add(addElement2);

         serverManager.CommitChanges();
      }
   }
}
```

* [Adding Static Types <add> | Microsoft Docs ](https://docs.microsoft.com/en-us/iis/configuration/system.webserver/httpcompression/statictypes/add)

```xml
<httpCompression
      directory="%SystemDrive%\inetpub\temp\IIS Temporary Compressed Files">
   <scheme name="gzip" dll="%Windir%\system32\inetsrv\gzip.dll" />
   <dynamicTypes>
      <add mimeType="text/*" enabled="true" />
      <add mimeType="message/*" enabled="true" />
      <add mimeType="application/javascript" enabled="true" />
      <add mimeType="*/*" enabled="false" />
   </dynamicTypes>
   <staticTypes>
      <add mimeType="text/*" enabled="true" />
      <add mimeType="message/*" enabled="true" />
      <add mimeType="application/javascript" enabled="true" />
      <add mimeType="*/*" enabled="false" />
   </staticTypes>
</httpCompression>
```


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
         ConfigurationSection httpCompressionSection = config.GetSection("system.webServer/httpCompression");
         ConfigurationElementCollection staticTypesCollection = httpCompressionSection.GetCollection("staticTypes");

         ConfigurationElement addElement = staticTypesCollection.CreateElement("add");
         addElement["mimeType"] = @"application/msword";
         addElement["enabled"] = true;
         staticTypesCollection.Add(addElement);

         ConfigurationElement addElement1 = staticTypesCollection.CreateElement("add");
         addElement1["mimeType"] = @"application/vnd.ms-powerpoint";
         addElement1["enabled"] = true;
         staticTypesCollection.Add(addElement1);

         ConfigurationElement addElement2 = staticTypesCollection.CreateElement("add");
         addElement2["mimeType"] = @"application/vnd.ms-excel";
         addElement2["enabled"] = true;
         staticTypesCollection.Add(addElement2);

         serverManager.CommitChanges();
      }
   }
}
```