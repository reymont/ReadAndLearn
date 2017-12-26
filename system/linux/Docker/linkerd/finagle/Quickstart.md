

* https://twitter.github.io/finagle/guide/Quickstart.html
* http://twitter.github.io/scala_school/zh_cn/index.html

Quickstart
In this section we’ll use Finagle to build a very simple HTTP server that is also an HTTP client — an HTTP proxy. We assume that you are familiar with Scala (if not, may we recommend Scala School).

The entire example is available, together with a self-contained script to launch sbt, in the Finagle git repository:

$ git clone https://github.com/twitter/finagle.git
$ cd finagle/doc/src/sphinx/code/quickstart
$ ./sbt compile
Setting up SBT
We’ll use sbt to build our project. Finagle is published to Maven Central, so little setup is needed: see the build.sbt in the quickstart directory. We no longer support scala 2.10.

name := "quickstart"

version := "1.0"

libraryDependencies += "com.twitter" %% "finagle-http" % "17.12.0"
Any file in this directory will now be compiled by sbt.

A minimal HTTP server
We’ll need to import a few things into our namespace.

import com.twitter.finagle.{Http, Service}
import com.twitter.finagle.http
import com.twitter.util.{Await, Future}
Service is the interface used to represent a server or a client (about which more later). Http is Finagle’s HTTP client and server.

Next, we’ll define a Service to serve our HTTP requests:

val service = new Service[http.Request, http.Response] {
  def apply(req: http.Request): Future[http.Response] =
    Future.value(
      http.Response(req.version, http.Status.Ok)
    )
}
Services are functions from a request type (com.twitter.finagle.http.Request) to a Future of a response type (com.twitter.finagle.http.Response). Put another way: given a request, we must promise a response some time in the future. In this case, we just return a trivial HTTP-200 response immediately (through Future.value), using the same version of HTTP with which the request was dispatched.

Now that we’ve defined our Service, we’ll need to export it. We use Finagle’s Http server for this:

val server = Http.serve(":8080", service)
Await.ready(server)
The serve method takes a bind target (which port to expose the server) and the service itself. The server is responsible for listening for incoming connections, translating the HTTP wire protocol into com.twitter.finagle.http.Request objects, and translating our com.twitter.finagle.http.Response object back into its wire format, sending replies back to the client.

The complete server:

import com.twitter.finagle.{Http, Service}
import com.twitter.finagle.http
import com.twitter.util.{Await, Future}

object Server extends App {
  val service = new Service[http.Request, http.Response] {
    def apply(req: http.Request): Future[http.Response] =
      Future.value(
        http.Response(req.version, http.Status.Ok)
      )
  }
  val server = Http.serve(":8080", service)
  Await.ready(server)
}
We’re now ready to run it:

$ ./sbt 'run-main Server'
Which exposes an HTTP server on port 8080 which dispatches requests to service:

$ curl -D - localhost:8080
HTTP/1.1 200 OK
Using clients
In our server example, we define a Service to respond to requests. Clients work the other way around: we’re given a Service to use. Just as we exported services with the Http.serve, method, we can import them with a Http.newService, giving us an instance of Service[http.Request, http.Response]:

val client: Service[http.Request, http.Response] = Http.newService("www.scala-lang.org:80")
client is a Service to which we can dispatch an http.Request and in return receive a Future[http.Response] — the promise of an http.Response (or an error) some time in the future. We furnish newService with the target of the client: the host or set of hosts to which requests are dispatched.

val request = http.Request(http.Method.Get, "/")
request.host = "www.scala-lang.org"
val response: Future[http.Response] = client(request)
Now that we have response, a Future[http.Response], we can register a callback to notify us when the result is ready:

Await.result(response.onSuccess { rep: http.Response =>
  println("GET success: " + rep)
})
Completing the client:

import com.twitter.finagle.{Http, Service}
import com.twitter.finagle.http
import com.twitter.util.{Await, Future}

object Client extends App {
  val client: Service[http.Request, http.Response] = Http.newService("www.scala-lang.org:80")
  val request = http.Request(http.Method.Get, "/")
  request.host = "www.scala-lang.org"
  val response: Future[http.Response] = client(request)
  Await.result(response.onSuccess { rep: http.Response =>
    println("GET success: " + rep)
  })

}
which in turn is run by:

$ ./sbt 'run-main Client'
...
GET success: Response("HTTP/1.1 Status(200)")
...
Putting it together
Now we’re ready to create an HTTP proxy! Notice the symmetry above: servers provide a Service, while a client uses it. Indeed, an HTTP proxy can be constructed by just replacing the service we defined in the Server example with one that was imported with a Http.newService:

import com.twitter.finagle.{Http, Service}
import com.twitter.finagle.http.{Request, Response}
import com.twitter.util.Await

object Proxy extends App {
  val client: Service[Request, Response] =
    Http.newService("twitter.com:80")

  val server = Http.serve(":8080", client)
  Await.ready(server)
}
And we can run it and dispatch requests to it (be sure to shutdown the Server example from earlier):

$ ./sbt 'run-main Proxy' &
$ curl --dump-header - --header "Host: twitter.com" localhost:8080
HTTP/1.1 301 Moved Permanently
content-length: 0
date: Wed, 01 Jun 2016 21:26:57 GMT
location: https://twitter.com/
...