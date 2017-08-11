

# authenticationschemes

* [HttpListener.AuthenticationSchemes Property (System.Net) ](https://msdn.microsoft.com/en-us/library/system.net.httplistener.authenticationschemes(v=vs.110).aspx)

```cs
public static void SimpleListenerWithUnsafeAuthentication(string[] prefixes)
{
    // URI prefixes are required,
    // for example "http://contoso.com:8080/index/".
    if (prefixes == null || prefixes.Length == 0)
      throw new ArgumentException("prefixes");
    // Set up a listener.
    HttpListener listener = new HttpListener();
    foreach (string s in prefixes)
    {
        listener.Prefixes.Add(s);
    }
    listener.Start();
    // Specify Negotiate as the authentication scheme.
    listener.AuthenticationSchemes = AuthenticationSchemes.Negotiate;
    // If NTLM is used, we will allow multiple requests on the same
    // connection to use the authentication information of first request.
    // This improves performance but does reduce the security of your 
    // application. 
    listener.UnsafeConnectionNtlmAuthentication = true;
    // This listener does not want to receive exceptions 
    // that occur when sending the response to the client.
    listener.IgnoreWriteExceptions = true;
    Console.WriteLine("Listening...");
    // ... process requests here.

    listener.Close();
}
```

* [Understanding HTTP Authentication | Microsoft Docs ](https://docs.microsoft.com/en-us/dotnet/framework/wcf/feature-details/understanding-http-authentication)

Basic authentication sends a Base64-encoded string that contains a user name and password for the client. Base64 is not a form of encryption and should be considered the same as sending the user name and password in clear text. If a resource needs to be protected, strongly consider using an authentication scheme other than basic authentication.


* [HttpListener Class | Microsoft Docs ](https://docs.microsoft.com/en-us/dotnet/api/system.net.httplistener?view=netframework-4.7)

```cs
// This example requires the System and System.Net namespaces.
public static void SimpleListenerExample(string[] prefixes)
{
    if (!HttpListener.IsSupported)
    {
        Console.WriteLine ("Windows XP SP2 or Server 2003 is required to use the HttpListener class.");
        return;
    }
    // URI prefixes are required,
    // for example "http://contoso.com:8080/index/".
    if (prefixes == null || prefixes.Length == 0)
      throw new ArgumentException("prefixes");
    
    // Create a listener.
    HttpListener listener = new HttpListener();
    // Add the prefixes.
    foreach (string s in prefixes)
    {
        listener.Prefixes.Add(s);
    }
    listener.Start();
    Console.WriteLine("Listening...");
    // Note: The GetContext method blocks while waiting for a request. 
    HttpListenerContext context = listener.GetContext();
    HttpListenerRequest request = context.Request;
    // Obtain a response object.
    HttpListenerResponse response = context.Response;
    // Construct a response.
    string responseString = "<HTML><BODY> Hello world!</BODY></HTML>";
    byte[] buffer = System.Text.Encoding.UTF8.GetBytes(responseString);
    // Get a response stream and write the response to it.
    response.ContentLength64 = buffer.Length;
    System.IO.Stream output = response.OutputStream;
    output.Write(buffer,0,buffer.Length);
    // You must close the output stream.
    output.Close();
    listener.Stop();
}
```