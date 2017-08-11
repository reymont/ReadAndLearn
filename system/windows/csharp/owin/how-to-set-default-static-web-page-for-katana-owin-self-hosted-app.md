


* [asp.net - How to set default static web page for Katana/Owin self hosted app? - Stack Overflow ](https://stackoverflow.com/questions/25478222/how-to-set-default-static-web-page-for-katana-owin-self-hosted-app)

```cs
var physicalFileSystem = new PhysicalFileSystem(webPath);
var options = new FileServerOptions
                          {
                              EnableDefaultFiles = true,
                              FileSystem = physicalFileSystem
                          };
        options.StaticFileOptions.FileSystem = physicalFileSystem;
        options.StaticFileOptions.ServeUnknownFileTypes = true;
        options.DefaultFilesOptions.DefaultFileNames = new[] { "index.html" };
        appBuilder.UseFileServer(options);

```