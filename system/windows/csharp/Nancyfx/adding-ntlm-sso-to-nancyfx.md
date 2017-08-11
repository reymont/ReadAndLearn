

* [Adding NTLM SSO to Nancyfx ](https://www.finalbuilder.com/resources/blogs/postid/730/adding-ntlm-sso-to-nancyfx)

Nancyfx is a Lightweight, low-ceremony, framework for building HTTP based services on .Net and Mono. It's open source and available on github. 

Nancy supports Forms Authentication, Basic Authentication and Stateless Authentication "out of the box", and it's simple to configure. In my application, I wanted to be able to handle mixed Forms and NTLM Authentication, which is something nancyfx  doesn't support. We have done this before with asp.net on IIS, and it was not a simple task, involving a child site with windows authentication enabled while the main site had forms (IIS doesn't allow both at the same time) and all sorts of redirection. It was painful to develop, and it's painful to install and maintain. 

Fortunately with Nancy and Owin, it's a lot simpler. Using Microsoft's implementation of the Owin spec, and Nancy's Owin support, it's actually quite easy, without the need for child websites and redirection etc. 
I'm not going to explain how to use Nancy or Owin here, just the part needed to hook up NTLM support. In my application, NTLM authentication is invoked by a button on the login page ("Login using my windows account") which causes a specific login url to be hit. We're using Owin for hosting rather than IIS and Owin enables us to get access to the HttpListener, so we can control the authentication scheme for each url. We do this by adding an AuthenticationSchemeSelectorDelegate.
?
1
2
3
4
5
6
7
8
9
10
11
12
13
14
internal class Startup
{
    public void Configuration(IAppBuilder app)
    {
        var listener = (HttpListener)app.Properties["System.Net.HttpListener"];
       //add a delegate to select the auth scheme based on the url 
        listener.AuthenticationSchemeSelectorDelegate = request =>
        {
            //the caller requests we try windows auth by hitting a specific url
            return request.RawUrl.Contains("loginwindows") ? AuthenticationSchemes.IntegratedWindowsAuthentication : AuthenticationSchemes.Anonymous;
        }
        app.UseNancy();
    }
}

What this achieves is to invoke the NTLM negotiation if the "loginwindows" url is hit on our nancy application. If the negotiation is successful (ie the browser supports NTLM and is able to identify the user),  then the Owin environment will have the details of the user, and this is how we get those details out of Owin (in our bootstrapper class).

?
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
protected override void ApplicationStartup(TinyIoCContainer container, IPipelines pipelines)
{
  pipelines.BeforeRequest.AddItemToStartOfPipeline((ctx) =>
  {
      if (ctx.Request.Path.Contains("loginwindows"))
      {
          var env = ((IDictionary<string,>)ctx.Items[Nancy.Owin.NancyOwinHost.RequestEnvironmentKey]);
          var user = (IPrincipal)env["server.User"];
          if (user != null && user.Identity.IsAuthenticated)
          {
              //remove the cookie if someone tried sending one in a request!
              if (ctx.Request.Cookies.ContainsKey("IntegratedWindowsAuthentication"))
                  ctx.Request.Cookies.Remove("IntegratedWindowsAuthentication");
              //Add the user as a cooking on the request object, so that Nancy can see it.
              ctx.Request.Cookies.Add("IntegratedWindowsAuthentication", user.Identity.Name);
          }
      }
      return null;//ensures normal processing continues. 
  });
}

Note we are adding the user in a cookie on the nancy Request object, which might seem a strange thing to do, but it was the only way I could find to add something to the request that can be accessed inside a nancy module, because everything else on the request object is read only. We don't send this cookie back to the user. So with that done, all that remains is the use that user in our login module


Post["/loginwindows"] = parameters => 
   {
       string domainUser = "";
       if (this.Request.Cookies.TryGetValue("IntegratedWindowsAuthentication",out domainUser))
       {
           //Now we can check if the user is allowed access to the application and if so, add 
           //our forms auth cookie to the response.             
           ...
       }
   }

Of course, this will probably only work on Windows, not sure what the current status is for System.Net.HttpListener is on Mono. This code was tested with Nancyfx 1.2 from nuget. 
