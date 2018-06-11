
- [NuGet Gallery | Packages matching IIS ](https://www.nuget.org/packages?q=IIS&page=3)
- [Microsoft |github](https://github.com/Microsoft)
- [Microsoft/IIS.Administration: REST API for managing IIS ](https://github.com/Microsoft/IIS.Administration)
- [Microsoft IIS Administration API - Microsoft IIS Administration ](https://blogs.iis.net/adminapi)
- [Microsoft IIS Administration API - Microsoft IIS Administration on Nano Server ](https://blogs.iis.net/adminapi/microsoft-iis-administration-on-nano-server)
- [Microsoft IIS Administration API - Microsoft IIS Administration API 2.0.0 ](https://blogs.iis.net/adminapi/microsoft-iis-administration-2-0-0)
- [Microsoft IIS Administration API - Introducing the IIS Administration API ](https://blogs.iis.net/adminapi/introducing-the-iis-administration-api)
- [Microsoft IIS Administration API - Microsoft IIS Administration Docs Now Available ](https://blogs.iis.net/adminapi/microsoft-iis-administration-docs-now-available)
- [Introduction to the Microsoft IIS Administration API | Microsoft Docs ](https://docs.microsoft.com/en-us/iis-administration/)


获取token
n7LVj0Ymmzl4RdpWVV9FPzqukfY34xvAaGicnw9sPcbqoLFdHhfKKQ

访问
https://localhost:55539
/api/webserver/websites

<POST>https://localhost:55539/api/webserver/websites
```json
{
	"name": "API Exploer Demo",
	"physical_path": "%SystemDrive%/inetpub/wwwroot",
	"bindings": [
		{
			"ip_address":"*",
			"port":"33441",
			"protocol":"http"
		}
	]
}
```