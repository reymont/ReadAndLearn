

* https://linkerd.io/overview/what-is-linkerd/


# What is Linkerd
Linkerd is an open source network proxy designed to be deployed as a service mesh: a dedicated layer for managing, controlling, and monitoring service-to- service communication within an application.

# What problems does it solve?
Linkerd was built to solve the problems we found operating large production systems at companies like Twitter, Yahoo, Google and Microsoft. `In our experience, the source of the most complex, surprising, and emergent behavior was usually not the services themselves, but the communication between services`. Linkerd addresses these problems not just by controlling the mechanics of this communication but by providing a layer of abstraction on top of it.


LINKERD ADDS RELIABILITY AND INSTRUMENTATION TO EXISTING APPLICATIONS.
`By providing a consistent, uniform layer of instrumentation and control across services, Linkerd frees service owners to choose whichever language is most appropriate for their service`. And by decoupling communication mechanics from application code, Linkerd allows you visibility and control over these mechanics without changing the application itself.

Today, companies around the world use Linkerd in production to power the heart of their software infrastructure. Linkerd takes care of the difficult, error-prone(易于出错的) parts of cross-service communication—including latency-aware load balancing, connection pooling, TLS, instrumentation, and request-level routing—to make application code scalable, performant, and resilient.

# How do I use it?
Linkerd runs as a separate standalone proxy. As a result, it does not depend on specific languages or libraries. Applications typically use Linkerd by running instances in known locations and proxying calls through these instances—i.e., rather than connecting to destinations directly, services connect to their corresponding Linkerd instances, and treat these instances as if they were the destination services.

Under the hood, Linkerd applies routing rules, communicates with existing service discovery mechanisms, and load-balances over destination instances—all while instrumenting the communication and reporting metrics. By deferring the mechanics of making the call to Linkerd, application code is decoupled from:

  * knowledge of the production topology;
  * knowledge of the service discovery mechanism; and
  * load balancing and connection management logic.

Applications also benefit from a consistent, global traffic control mechanism. This is particularly important for polyglot applications, for which it is very difficult to attain this sort of consistency via libraries.

Linkerd instances can be deployed as sidecars (i.e. one instance per application service instance) or per-host. Since Linkerd instances are stateless and independent, they can fit easily into existing deployment topologies. They can be deployed alongside application code in a variety of configurations and with a minimum of coordination.