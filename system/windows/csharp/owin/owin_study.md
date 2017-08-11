
#OWIN — Open Web Interface for .NET

<!-- @import "[TOC]" {cmd:"toc", depthFrom:1, depthTo:6, orderedList:false} -->
<!-- code_chunk_output -->

* [OWIN — Open Web Interface for .NET](#owin-open-web-interface-for-net)
* [说明](#说明)
* [Getting Started](#getting-started)
* [Wiki](#wiki)
* [Projects](#projects)
	* [Servers and Hosts](#servers-and-hosts)
	* [Frameworks](#frameworks)
	* [Implementations](#implementations)
	* [Out of date or deprecated](#out-of-date-or-deprecated)
* [Governance](#governance)

<!-- /code_chunk_output -->



#说明

OWIN定义了一个.NET网络服务器和.NET网络应用程序之间的标准接口。OWIN接口的目标是对服务器和应用程序进行解耦，鼓励开发简单的模块。同时，作为一个开放的标准，促进.NET网络开发工具生态圈发展，


#Wiki

You can find more project information on the [wiki](https://github.com/owin/owin/wiki).
#Projects

These projects are known to be OWIN-compatible. If you'd like your project listed here, please post on the discussion list or chat room.

##Servers and Hosts

- [Katana](http://katanaproject.codeplex.com/)
- [Nowin](https://github.com/Bobris/Nowin)
- [Suave](https://github.com/SuaveIO/suave)

- [ASP.NET MVC随想录——漫谈OWIN - 木宛城主 - 博客园 ](http://www.cnblogs.com/OceanEyes/p/thinking-in-asp-net-mvc-what-is-owin.html)
OWIN是Open Web Server Interface for .NET的首字母缩写

过去，IIS作为.NET 开发者来说是最常用的Web Server（没有之一），源于微软产品的紧耦合关系，我们不得不将Website、Web Application、Web API等部署在IIS上，事实上在2010年前并没有什么不妥，但随着近些年来Web的发展，特别是移动互联网飞速发展，IIS作为Web Server已经暴露出他的不足了。主要体现在两个方面，ASP.NET (System.Web)紧耦合IIS，IIS紧耦合OS，这就意味着，我们的Web Framework必须部署在微软的操作系统上，难以跨平台。

ASP.NET 和 IIS

我们知道，不管是ASP.NET MVC 还是ASP.NET WEB API 等都是基于ASP.NET Framework的，这种关系从前缀就可以窥倪出来。而ASP.NET的核心正是System.Web这个程序集，而且System.Web紧耦合IIS，他存在于.NET Framework中。所以，这导致了Web Framework严重的局限性：

ASP.NET 的核心System.Web，而System.Web紧耦合IIS
System.Web 是.NET Framework重要组成，已有15年以上历史，沉重、冗余，性能差，难于测试，约2.5M
System.Web要更新和发布新功能必须等待.NET Framework发布
.但NET Framework是Windows的基础，往往不会随意更新。
所以要想获取最新的Web Framework是非常麻烦的，幸运的事，微软已经意识到了问题的严重性，最新的Web Framework都是通过Nuget来获取。

- [快刀斩乱麻之 Katana ](www.cnblogs.com/xishuai/p/asp-net-5-owin-katana.html)

- owin.RequestBody：一个带有请求正文（如果有）的流。如果没有请求正文，Stream.Null 可以用作占位符。
- owin.RequestHeaders：请求标头的 IDictionary< string, string[] >。
- owin.RequestMethod：一个包含请求的 HTTP 请求方法的字符串（例如 GET 和 POST）。
- owin.RequestPath：一个包含请求路径的字符串。 此路径必须是应用程序委托的“根”的相对路径。
- owin.RequestPathBase：一个字符串，包含对应于应用程序委托的“根”的请求路径部分。
- owin.RequestProtocol：一个包含协议名称和版本的字符串（例如 HTTP/1.0 或 HTTP/1.1）。
- owin.RequestQueryString：一个字符串，包含 HTTP 请求 URI 的查询字符串组成部分，不带“?”（例如 foo=bar&baz=quux），该值可以是空字符串。
- owin.RequestScheme：一个字符串，包含用于请求的 URI 方案（例如 HTTP 或 HTTPS）。

- [OWIN — Open Web Server Interface for .NET ](http://owin.org/spec/spec/owin-1.0.0.html)规范

- [ASP.NET - Getting Started with the Katana Project ](https://msdn.microsoft.com/en-us/magazine/dn451439.aspx)

- [Use OWIN to Self-Host ASP.NET Web API 2 | Microsoft Docs ](https://docs.microsoft.com/en-us/aspnet/web-api/overview/hosting-aspnet-web-api/use-owin-to-self-host-web-api)

- [An Overview of Project Katana | Microsoft Docs ](https://docs.microsoft.com/en-us/aspnet/aspnet/overview/owin-and-katana/an-overview-of-project-katana)

参考

1. [OWIN — Open Web Interface for .NET ](http://owin.org/)