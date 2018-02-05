# https://github.com/Netflix/zuul/wiki/Writing-Filters

Filter Basics

Filter Interface

Filters must extend ZuulFilter and implement the following methods:

String filterType();

int filterOrder();

boolean shouldFilter();

Object run();
To Run, or Maybe Not

The method shouldFilter() returns a boolean indicating if the Filter should run or not.

Ordering

The method filterOrder() returns an int describing the order that the Filter should run in relative to others.

Filter Types

A Filter's type is a String which can be any value that you desire. There are 2 uses for this:

Zuul's primary request lifecycle consists of "pre", "routing", and "post" phases, in that order. All filters with these types are run for every request.

Filters of any type can be explicitly run using the method GroovyProcessor.runFilters(String type).

Filter Coordination

Filters have no direct way of accessing each other. They can share state using RequestContext which is a Map-like structure with some explicit accessor methods for data considered primitive to Zuul.

Special Filter Extensions

StaticResponseFilter

StaticResponseFilter allows the generation of responses from Zuul itself, instead of forwarding the request to an origin.

SurgicalDebugFilter

SurgicalDebugFilter allows specific requests to be routed to a separate debug cluster or host.
A Netflix Original Production
Tech Blog | Twitter @NetflixOSS | Jobs