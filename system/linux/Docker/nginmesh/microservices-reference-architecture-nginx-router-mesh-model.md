
* https://www.nginx.com/blog/microservices-reference-architecture-nginx-router-mesh-model/


Author’s note – This blog post is the third in a series:

Introducing the Microservices Reference Architecture from NGINX
MRA, Part 2: The Proxy Model
MRA, Part 3: The Router Mesh Model (this post)
MRA, Part 4: The Fabric Model
MRA, Part 5: Adapting the Twelve‑Factor App for Microservices
MRA, Part 6: Implementing the Circuit Breaker Pattern with NGINX Plus
All six blogs, plus a blog about web frontends for microservices applications, have been collected into a free ebook.

Also check out these other NGINX resources about microservices:

A very useful and popular series by Chris Richardson about microservices application design
The Chris Richardson articles collected into a free ebook, with additional tips on implementing microservices with NGINX and NGINX Plus
Other microservices blog posts
Microservices webinars

Introducing the Router Mesh Model

In terms of sophistication and comprehensiveness, the Router Mesh Model is the middle of the three models in the NGINX Microservices Reference Architecture (MRA). Each of the models uses an NGINX Plus high‑availability (HA) server cluster in the reverse proxy position, “in front of” other servers. The models differ in whether, and how, they use additional NGINX Plus servers:

The Proxy Model is the simplest model and focuses on managing only inbound and outbound traffic, not traffic between the microservices in an application. The NGINX Plus HA server cluster in the reverse proxy position fronts your microservices servers. The NGINX Plus server cluster buffers Internet traffic, load balances it to your service instances, caches data, and performs other microservices‑related tasks.
As the intermediate model, the Router Mesh Model uses an NGINX Plus HA server cluster in the reverse proxy position, then places a second server cluster as a router mesh hub in the center of the servers that run specific microservices. The Router Mesh Model is relatively easy to implement, powerful, efficient, and fast.
The Fabric Model is the most sophisticated of the three models, using an NGINX Plus server cluster as a reverse proxy and an additional instance of NGINX Plus for each service instance. (Both the NGINX Plus instances and the service instances are ephemeral, created and destroyed as needed at runtime.) The Fabric Model implements load balancing and traffic management at the container level, enabling persistent, fast SSL/TLS connections between service instances to provide the utmost performance in an encrypted HTTP network.
We see the three models as forming a progression. As you begin implementing a new microservices application or converting an existing monolithic app to microservices, the Proxy Model may well be sufficient. You might then move to the Router Mesh Model for increased power and control; it covers the needs of a great many microservices apps. For the largest apps, and those that require SSL/TLS at the transmission layer, use the Fabric Model.

The following figure shows how NGINX Plus performs two roles in the Router Mesh Model. One NGINX Plus server cluster acts as a frontend reverse proxy; another NGINX Plus server cluster functions as a routing hub. This configuration allows for optimal request distribution and purpose‑driven separation of concerns.

In the Router Mesh Model of the Microservices Reference Architecture from NGINX, NGINX Plus runs on each server to load balance the microservices running there, and also on frontend servers to reverse proxy and load balance traffic to the application servers with service discovery
Figure 1. In the Router Mesh Model of the Microservices Reference Architecture, NGINX Plus runs as a reverse proxy server and as a router mesh hub
Reverse Proxy and Load Balancing Server Capabilities

In the Router Mesh Model, the NGINX Plus proxy server cluster manages incoming traffic, but sends requests to the router mesh server cluster rather than directly to the service instances.

The functions of the reverse proxy server cluster fall into two groups. The first group of features are performance‑related functions:

Caching
Low‑latency connectivity
High availability
(The links connect to detailed descriptions of these capabilities in the Proxy Model blog post.)

The features in the second group improve security and make application management easier:

Rate limiting/WAF
SSL/TLS termination
HTTP/2 support
While the first server cluster provides reverse proxy services, the second serves as a router mesh hub, providing:

A central communications point for services
Dynamic service discovery
Load balancing
Interservice caching
Health checks and the circuit breaker pattern
For additional details, see our blog posts on dynamic service discovery, API gateways, and health checks.

Implementing the Router Mesh Model

Implementing a microservices architecture using the Router Mesh Model is a four‑step process:

Set up a proxy server cluster
Deploy a second server cluster as a router mesh hub with the interface code for your orchestration tool
Indicate which services to load balance
Tell the services the new endpoints of the services they use
For the first step, set up a proxy server cluster in the same way that you would for the Proxy Model, or for a typical reverse proxy server.

For the subsequent steps, begin by deploying a container to be used for the router mesh microservices hub. This container holds the NGINX Plus instance and the appropriate agent for the service registry and orchestration tools you are using. Once the container is deployed and scaled, you indicate the services to be load balanced by adding an environment variable to the definition for each service:

LB_SERVICE=true
This hub monitors the service registry and the stream of events that are emitted as new services and instances are created, modified, and destroyed.

In order to integrate successfully, the router mesh hub needs adapters to work with the different registry and orchestration tools available on the market. Currently, we have the Router Mesh Model working in Docker Swarm‑based tools, Mesos‑based systems, and with Kubernetes.

The NGINX Plus servers in the router mesh hub support a load balancing pool for the service instances. To send requests to the service instances, you route requests to the NGINX Plus servers in the router mesh hub and use the service name, either as part of the URI path or as a service name.

For example, in Figure 1, the URL for the Pages web frontend looks something like this:

http://router-mesh.internal.mra.com/pages/index.php

With Kubernetes as of this writing, and soon with Mesos/DCOS systems, the Router Mesh Model implements the routes as servers rather than locations. In this version, the route above is accessible as:

http://pages.router-mesh.internal.mra.com/index.php

This allows some types of payloads with internal references (for example, HTML) to make requests without having to modify the links. For most JSON payloads, the original, path‑based format works well.

One of the advantages of using NGINX Plus in the Router Mesh Model is that the system can implement the circuit breaker pattern for all services that need it. An active health check is automatically created to monitor user‑configurable URIs, so that service instances can be queried for their health status. NGINX Plus diverts traffic away from unhealthy service instances to give them a chance to recover, or to be recycled if they cannot recover. If all service instances are down or unavailable, NGINX Plus can provide continuity of service by delivering cached data.

Conclusion

The Router Mesh Model networking architecture for microservices is the middle option of the NGINX MRA models. In contrast to the Proxy Model, which puts all relevant functions on one NGINX Plus instance, the Router Mesh model uses two NGINX Plus server clusters, configured for different roles. One server cluster acts as a proxy server and the other as a router mesh hub for your microservices.

Splitting different types of functions between two different server clusters provides speed, control, and opportunities to optimize for security. In the second server cluster, service discovery (in collaboration with a service registry tool) and load balancing are fast, capable, and configurable. Health checks for all service instances make the system as a whole faster, more stable, and more resilient.

To try out the Router Mesh Model with NGINX Plus for yourself, start your free 30‑day trial today or contact us for a live demo. You may also wish to contact the NGINX Professional Services today so they can assess your needs and help you begin implementing the Router Mesh Model.