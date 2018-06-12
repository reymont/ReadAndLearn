# https://github.com/Netflix/zuul/wiki/How-it-Works

How it Works
matthew hawthorne edited this page on 5 Jun 2013 · 5 revisions
 Pages 8
Home
Getting Started
How It Works
How We Use Zuul At Netflix
How To Use
Simple Example App: zuul-simple-webapp
Comprehensive Example App: zuul-netflix-webapp
Writing Filters
Clone this wiki locally


https://github.com/Netflix/zuul.wiki.git
 Clone in Desktop
Filter Overview

At the center of Zuul is a series of Filters that are capable of performing a range of actions during the routing of HTTP requests and responses.

The following are the key characteristics of a Zuul Filter:

Type: most often defines the stage during the routing flow when the Filter will be applied (although it can be any custom string)
Execution Order: applied within the Type, defines the order of execution across multiple Filters
Criteria: the conditions required in order for the Filter to be executed
Action: the action to be executed if the Criteria is met
Zuul provides a framework to dynamically read, compile, and run these Filters. Filters do not communicate with each other directly - instead they share state through a RequestContext which is unique to each request.

Filters are currently written in Groovy, although Zuul supports any JVM-based language. The source code for each Filter is written to a specified set of directories on the Zuul server that are periodically polled for changes. Updated filters are read from disk, dynamically compiled into the running server, and are invoked by Zuul for each subsequent request.

Filter Types

There are several standard Filter types that correspond to the typical lifecycle of a request:

PRE Filters execute before routing to the origin. Examples include request authentication, choosing origin servers, and logging debug info.
ROUTING Filters handle routing the request to an origin. This is where the origin HTTP request is built and sent using Apache HttpClient or Netflix Ribbon.
POST Filters execute after the request has been routed to the origin. Examples include adding standard HTTP headers to the response, gathering statistics and metrics, and streaming the response from the origin to the client.
ERROR Filters execute when an error occurs during one of the other phases.
Alongside the default Filter flow, Zuul allows us to create custom filter types and execute them explicitly. For example, we have a custom STATIC type that generates a response within Zuul instead of forwarding the request to an origin. We have a few use cases for this, one of which is internal endpoints that contain debug data about a particular Zuul instance.

Zuul Request Lifecycle

zuul-request-lifecycle.png
A Netflix Original Production
Tech Blog | Twitter @NetflixOSS | Jobs