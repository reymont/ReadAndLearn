



* [Default Document <defaultDocument> | Microsoft Docs ](https://docs.microsoft.com/en-us/iis/configuration/system.webServer/defaultDocument/#sample-code)

```xml
<configuration>
   <system.webServer>
      <defaultDocument enabled="true">
         <files>
            <add value="home.html" />
         </files>
      </defaultDocument>
   </system.webServer>
</configuration>
```
```xml
<defaultDocument enabled="true">
    <files>
        <add value="Default.htm" />
        <add value="Default.asp" />
        <add value="index.htm" />
        <add value="index.html" />
        <add value="iisstart.htm" />
        <add value="default.aspx" />
    </files>
</defaultDocument>
```

```cs
using System;
using System.Text;
using Microsoft.Web.Administration;

internal static class Sample {

    private static void Main() {
        
        using(ServerManager serverManager = new ServerManager()) { 
            Configuration config = serverManager.GetWebConfiguration("Contoso");
            
            ConfigurationSection defaultDocumentSection = config.GetSection("system.webServer/defaultDocument");
            
            defaultDocumentSection["enabled"] = true;
            
            ConfigurationElementCollection filesCollection = defaultDocumentSection.GetCollection("files");
            ConfigurationElement addElement = filesCollection.CreateElement("add");
            addElement["value"] = @"home.html";
            filesCollection.AddAt(0, addElement);
            
            serverManager.CommitChanges();
        }
    }
}
```