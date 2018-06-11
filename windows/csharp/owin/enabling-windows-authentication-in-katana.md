

* [Enabling Windows Authentication in Katana | The ASP.NET Site ](https://www.asp.net/aspnet/raw-content/owin-and-katana/enabling-windows-authentication-in-katana)

This article shows how to enable Windows Authentication in Katana. It covers two scenarios: Using IIS to host Katana, and using HttpListener to self-host Katana in a custom process. Thanks to Barry Dorrans, David Matson, and Chris Ross for reviewing this article.
Katana is Microsoft’s implementation of OWIN, the Open Web Interface for .NET. You can read an introduction to OWIN and Katana here. The OWIN architecture has several layers:

Host: Manages the process in which the OWIN pipeline runs.
Server: Opens a network socket and listens for requests.
Middleware: Processes the HTTP request and response.
Katana currently provides two servers, both of which support Windows Integrated Authentication:

Microsoft.Owin.Host.SystemWeb. Uses IIS with the ASP.NET pipeline.
Microsoft.Owin.Host.HttpListener. Uses System.Net.HttpListener. This server is currently the default option when self-hosting Katana.
Katana does not currently provide OWIN middleware for Windows Authentication, because this functionality is already available in the servers.

# Windows Authentication in IIS

Using Microsoft.Owin.Host.SystemWeb, you can simply enable Windows Authentication in IIS.

Let’s start by creating a new ASP.NET application, using the “ASP.NET Empty Web Application” project template.



Next, add NuGet packages. From the Tools menu, select Library Package Manager, then select Package Manager Console. In the Package Manager Console window, enter the following command:

Install-Package Microsoft.Owin.Host.SystemWeb -pre
Now add a class named Startup with the following code:

using Owin;

namespace KatanaWebHost
{
    public class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            app.Run(context =>
            {
                context.Response.ContentType = "text/plain";
                return context.Response.WriteAsync("Hello World!");
            });
        }
    }
}
That’s all you need to create a “Hello world” application for OWIN, running on IIS. Press F5 to debug the application. You should see “Hello World!” in the browser window.



Next, we’ll enable Windows Authentication in IIS Express. From the View menu, select Properties. Click on the project name in Solution Explorer to view the project properties.

In the Properties window, set Anonymous Authentication to Disabled and set Windows Authentication to Enabled.



When you run the application from Visual Studio, IIS Express will require the user’s Windows credentials. You can see this by using Fiddler or another HTTP debugging tool. Here is an example HTTP response:

HTTP/1.1 401 Unauthorized
Cache-Control: private
Content-Type: text/html; charset=utf-8
Server: Microsoft-IIS/8.0
WWW-Authenticate: Negotiate
WWW-Authenticate: NTLM
X-Powered-By: ASP.NET
Date: Sun, 28 Jul 2013 07:28:51 GMT
Content-Length: 6062
Proxy-Support: Session-Based-Authentication
The WWW-Authenticate headers in this response indicate that the server supports the Negotiate protocol, which uses either Kerberos or NTLM.

Later, when you deploy the application to a server, follow these steps to enable Windows Authentication in IIS on that server.

# Windows Authentication in HttpListener

If you are using Microsoft.Owin.Host.HttpListener to self-host Katana, you can enable Windows Authentication directly on the HttpListener instance.

First, create a new console application. Next, add NuGet packages. From the Tools menu, select Library Package Manager, then select Package Manager Console. In the Package Manager Console window, enter the following command:

Install-Package Microsoft.Owin.SelfHost -Pre
Now add a class named Startup with the following code:

using Owin;
using System.Net;

namespace KatanaSelfHost
{
    class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            HttpListener listener = 
                (HttpListener)app.Properties["System.Net.HttpListener"];
            listener.AuthenticationSchemes = 
                AuthenticationSchemes.IntegratedWindowsAuthentication;

            app.Run(context =>
            {
                context.Response.ContentType = "text/plain";
                return context.Response.WriteAsync("Hello World!");
            });
        }
    }
}
This class implements the same “Hello world” example from before, but it also sets Windows Authentication as the authentication scheme.

Inside the Main function, start the OWIN pipeline:

using Microsoft.Owin.Hosting;
using System;

namespace KatanaSelfHost
{
    class Program
    {
        static void Main(string[] args)
        {
            using (WebApp.Start<Startup>("http://localhost:9000"))
            {
                Console.WriteLine("Press Enter to quit.");
                Console.ReadKey();
            }        
        }
    }
}
You can send a request in Fiddler to confirm that the application is using Windows Authentication:

HTTP/1.1 401 Unauthorized
Content-Length: 0
Server: Microsoft-HTTPAPI/2.0
WWW-Authenticate: Negotiate
WWW-Authenticate: NTLM
Date: Sun, 28 Jul 2013 21:02:21 GMT
Proxy-Support: Session-Based-Authentication
Related Topics

An Overview of Project Katana

System.Net.HttpListener

Understanding OWIN Forms Authentication in MVC 5