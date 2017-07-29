
# asp.net mvc

* [返璞归真 asp.net mvc (13) - asp.net mvc 5.0 新特性 - webabcd - 博客园 ](http://www.cnblogs.com/webabcd/p/3510032.html)
* [ASP.NET MVC 随想录——开始使用ASP.NET Identity，初级篇 - 木宛城主 - 博客园 ](http://www.cnblogs.com/OceanEyes/p/thinking-in-asp-net-mvc-get-started-with-identity.html)
* [ASP.NET MVC 随想录——探索ASP.NET Identity 身份验证和基于角色的授权，中级篇 - 木宛城主 - 博客园 ](http://www.cnblogs.com/OceanEyes/archive/2015/09/06/4787576.html)
* [CookieAuthenticationOptions类 （MVC身份验证） - Fanbin168的专栏 - CSDN博客 ](http://blog.csdn.net/fanbin168/article/details/49923505)
* [MVC5 - ASP.NET Identity登录原理 - Claims-based认证和OWIN - 腾飞（Jesse) - 博客园 ](http://www.cnblogs.com/jesse2013/p/aspnet-identity-claims-based-authentication-and-owin.html)
* [A primer on OWIN cookie authentication middleware for the ASP.NET developer | brockallen ](https://brockallen.com/2013/10/24/a-primer-on-owin-cookie-authentication-middleware-for-the-asp-net-developer/)

* [A primer on external login providers (social logins) with OWIN/Katana authentication middleware | brockallen ](https://brockallen.com/2014/01/09/a-primer-on-external-login-providers-social-logins-with-owinkatana-authentication-middleware/)

* [Four Easy Steps to Set Up OWIN for Form-authentication - CodeProject ](https://www.codeproject.com/Tips/849113/Four-Easy-Steps-to-Set-Up-OWIN-for-Form-authentica)

* [ASP.NET Web Api: Understanding OWIN/Katana Authentication/Authorization Part I: Concepts - CodeProject ](https://www.codeproject.com/Articles/876867/ASP-NET-Web-Api-Understanding-OWIN-Katana-Authenti)

* [TypecastException/MinimalOwinWebApiSelfHost ](https://github.com/TypecastException/MinimalOwinWebApiSelfHost)


* [Thinktecture.IdentityModel/Startup.cs at master · IdentityModel/Thinktecture.IdentityModel ](https://github.com/IdentityModel/Thinktecture.IdentityModel/blob/master/samples/OWIN/AuthenticationTansformation/KatanaAuthentication/Startup.cs)

* [IdentityModel/IdentityModel2: .NET standard helper library for claims-based identity, OAuth 2.0 and OpenID Connect. ](https://github.com/IdentityModel/IdentityModel2)
* [NuGet Gallery | Thinktecture.IdentityModel.Owin - Basic Authentication 1.0.1 ](https://www.nuget.org/packages/Thinktecture.IdentityModel.Owin.BasicAuthentication/)
* [Blog-Example-Classes/OwinBasicAuthentication at master · scottbrady91/Blog-Example-Classes ](https://github.com/scottbrady91/Blog-Example-Classes/tree/master/OwinBasicAuthentication)

* [OWIN Basic Authentication - Scott Brady ](https://www.scottbrady91.com/Katana/OWIN-Basic-Authentication)

Basic Authentication is considered a bit of an anti-pattern these days, but it can still be useful in a pinch when you have limited options for integrating with APIs, third party applications or the dreaded legacy applications.

Basic Authentication should never be a recommended solution, however I have met many clients who are still running services that use it and third party applications who only support basic authentication. Some security is better than none, right? I guess that's debatable.

If you want a modern identity solution, check out Identity Server. Identity Server is a one time configuration that will allow you to create your own OAuth, OpenID Connect or WS-Federation Authentication Server (aka Identity Provider, Security Token Service, etc), that can reliably service all of your applications.

This article will cover the theory behind basic authentication, including why we shouldn't really be using it, and then look at how we can integrate it into our OWIN pipeline.

Basic Authentication
The Basics
A resource that is protected by basic authentication requires incoming requests to include the Authorization HTTP header using the basic scheme. This scheme uses a base64 encoded username and password separated by a colon (base64 encoding is used to avoid characters that would cause issues when sent over HTTP).

Plain text
Authorization: Basic username:password
Encoded
Authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ=
The server will return HTTP 401 Unauthorized if this header is not present, along with a WWW-Authenticate HTTP header stating the preferred authentication method (the Basic scheme) as well as the realm of the resource. If this header was seen by a browser it will typically open up a username and password dialog box.

    WWW-Authenticate: Basic realm="localhost"
Why you shouldn't use it
When using basic authentication you send credentials with every request. This means you must either ask the user for their username and password on every request or store them in some way. It also means that credentials are validated upon every request, which has performance implications when you hash and compare against your user store (you're not storing passwords in plain text, are you?). This comparison should also be implemented with an awareness of Timing Attacks (so keep the comparison times consistent).

Obviously we are sending unencrpyted credentials across the wire, so Transport Layer Security (TLS) is a must, so make sure you're running your site on https. Remember, base64 encoding is not encryption...

OWIN Basic Authentication using IdentityModel.Owin.BasicAuthentication
There is currently no Katana middleware provided by Microsoft (e.g. Microsoft.Owin.Security.Basic>) that can protect your application using Basic Authentication out of the box. This was due to security concerns about even offering basic authentication to modern OWIN applications.

Articles on creating your own OWIN component for basic authentication have been done to death, whether it’s implemented using the AuthenticationHandler> middleware class or not. But why implement your own when there’s a perfectly good open source library tested and maintained by the team behind Identity Server.

You can get a full breakdown of how this component is implemented in Dominick Baier’s Pluralsight course Web API v2 Security, framed around explaining the mechanics of the AuthenticationHandler> middleware class, but here we are just going to integrate this with our project.

First we'll need the following nuget package:

Install-Package Thinktecture.IdentityModel.Owin.BasicAuthentication
This will also pull down the required Microsoft.Owin.Security> package.

This middleware requires the usual AuthenticationOptions> required by Authentication middleware. This implementation (BasicAuthenticationOptions>) requires the realm and a function for validating the username and password that returns a collection of claims. So we can add something like the following to our OWIN Startup class:
```cs
app.UseBasicAuthentication(new BasicAuthenticationOptions("SecureApi",
    async (username, password) => await Authenticate(username, password)));
Where the Authenticate> method is something like:

private async Task<IEnumerable<Claim>> Authenticate(string username, string password) {
    // authenticate user
    if (username == password) {
        return new List<Claim> {
            new Claim("name", username)
        };
    }

    return null;
}
```
It is here that you validate the incoming credentials and provide a collection of claims if the user is valid. Here I am just comparing the username and password for equality, obviously this example shouldn't be used in a production environment.

Source Code
You can find an example OWIN Web API on GitHub that uses this package and the above code, where authentication is simply triggered by an Authorizaton attribute on a controller. Otherwise check out the following resources for further reading:

Example Implementation of IdentityModel.Owin.BasicAuthentication
Source code for the IdentityModel.Owin.BasicAuthentication package
ASP.NET Core implementation of Basic Authentication by Barry Dorrans with some bonus warnings and sarcasm
RFC Specification for Basic Authentication