
Build self-healing distributed systems with Spring Cloud | InfoWorld https://www.infoworld.com/article/2925047/application-development/build-self-healing-distributed-systems-with-spring-cloud.html

Microservices have become the hottest topic in software architecture over the past year, and much can be said about their benefits. However, it’s important to understand that as soon as we start decomposing the monolith, we enter the realm of distributed systems. Anyone who is familiar with The Eight Fallacies of Distributed Computing knows that such systems are fraught with danger, and making any of the eight assumptions will eventually lead to disastrous consequences.

If I were to sum up these fallacies in one sentence it would be the following: Any expression of consistency or reliability in a distributed system is a lie. We have to assume that the behavior and the locations of the components of our system will constantly change. Two consequences of this: Components will sometimes provide poor quality of service or outright disappear, and we can bucket these under the general term of faults. Faults, if not handled properly, can cause failures, meaning the system no longer provides the service it was designed to provide.

[ Get the most out of collaborative programming with InfoWorld's 20 essential pointers for Git and GitHub. | Keep up with hot topics in app dev with InfoWorld's Application Development newsletter. ]
Therefore, in order to enjoy the benefits of microservices (loose coupling, autonomous services, decentralized governance, easier continuous delivery, and so on), we must avoid the situation whereby a single fault cascades into a system failure. Joe Armstrong, the father of Erlang, gave a great talk on this topic titled Systems that Run Forever, Self-Heal, and Scale. In it he describes systems that look a lot like what we call microservices, but with emphasis on fault-tolerant systems that self-heal. What does it take for us to build such systems?

Netflix has for some time been the poster child for microservice architectures. One of the core tenets of the way Netflix builds systems is that any component should be able to suffer a fault, yet the system should keep running (meaning you can still watch movies and Netflix can continue to learn your preferences!). When trying to build systems like this, we encounter several common challenges:

As we decompose the system into many distributed processes, how do we consistently and reliably distribute configuration to these processes?
When that configuration needs to change, how do we update that configuration without redeploying all of the processes?
In a system like this, particularly one deployed in a cloud environment, processes will come and go and change their locations (especially as they recover from faults). How do we determine the locations of the processes that my process needs to collaborate with?
Once we’ve determined a set of possible locations of one of my process’s dependencies, how do we choose which process instance to communicate with next?
Suppose, in the span of time between choosing a process instance and communicating with that instance, the instance suffers a fault. How do we prevent that fault from cascading into a failure?
How do we maintain visibility into the composite behavior of the system that emerges from the evolving topology of autonomous services so that we can make adjustments?
As it turns out, you can deploy several boilerplate patterns and open source tools to mitigate these challenges. Netflix built many of these components, battle tested them in production, and open-sourced them. In theory, we can leverage these tools to build systems that “run forever, self-heal, and scale.” For us remains the task of understanding the patterns; understanding the Netflix components that implement them; then deploying, managing, and integrating with these components. Taking on new technology dependencies always introduces additional complexity into any software engineering endeavor, so some of us might hesitate to adopt the Netflix stack.

The Spring engineering team has throughout its existence attempted to build powerful weapons for the war on Java complexity. Our early focus was on removing the shackles of J2EE that inhibited the productivity of the enterprise application developer. These days that focus has shifted to enabling the construction of cloud-native applications, with much of the work done in and around a project we call Spring Cloud.

The goal of Spring Cloud is to provide the Spring developer with an easily consumable set of tools to build distributed systems. It primarily does this by wrapping other implementation stacks, starting with the Netflix OSS stack. These stacks are then consumed via the familiar tools of annotation-based configuration, Java configuration, and template-based programming. Let’s take a look at a few of Spring Cloud’s components.

Spring Cloud Config Server

Spring Cloud Config Server provides a centralized configuration service that is horizontally scalable. It uses as its data store a pluggable repository layer that currently supports local storage, Git, and Subversion. By leveraging a version control system as a configuration store, developers can easily version and audit configuration changes.

Spring Cloud Config Server
Figure 1: Spring Cloud Config Server
Configuration is represented as either Java properties or YAML files. The Config Server coalesces these files into environment objects, which present the well-understood model of Spring properties and profiles as a REST API. This REST API can be queried by any application directly to obtain configuration data, but an intelligent client-side binding can be added to Spring Boot applications that will automatically reconcile any local configuration with configuration received from the Config Server.

Spring Cloud Bus

The Spring Cloud Config Server is a powerful mechanism for distributing configuration consistently across a set of application instances. However, as it stands, we are currently limited to updating such configuration only on application boot. After pushing a new value for a property to Git, we would need to manually restart each application process to obtain the new value. What we’d like is the ability to refresh the application’s configuration without a restart.

Spring Cloud Config Server with Spring Cloud Bus
Figure 2: Spring Cloud Config Server with Spring Cloud Bus
The Spring Cloud Bus adds a management backplane to your application instances. It is currently implemented as a client-side binding to a set of AMQP exchanges and queues, but this back end is also designed to be pluggable. The Cloud Bus adds more management endpoints to your application. In Figure 2 we see a new value for the greeting property pushed to Git, followed by a POST request sent to the /bus/refresh endpoint on App A. This request triggers three events:

App A requests the latest configuration from the Config Server. Any Spring Beans annotated with @RefreshScope are reinitialized with the new configuration.
App A sends a message to the AMQP exchange indicating it has received a refresh event.
Apps B and C, participating on the Cloud Bus by listening to the appropriate AMQP queue, receive the message and update their configuration in the same manner as App A.
Now we have the ability to refresh an application’s configuration without a restart.

Spring Cloud Netflix

Spring Cloud Netflix provides wrappers around several Netflix components: Eureka, Ribbon, Hystrix, and Zuul. I’ll discuss each of these in turn.

Eureka is a resilient service registry implementation. A service registry is one mechanism for implementing the Service Discovery pattern (Figure 3).

Using a service registry for service discovery
Figure 3: Using a service registry for service discovery
Spring Cloud Netflix enables the deployment of embedded Eureka servers by simply adding the spring-cloud-starter-eureka-server dependency to a Spring Boot application, then annotating that application’s configuration class with @EnableEurekaServer.

Applications can participate in service discovery by adding the spring-cloud-starter-eureka dependency and annotating their configuration class with @EnableDiscoveryClient. This annotation provides the ability to inject a properly configured instance of DiscoveryClient into any Spring Bean. DiscoveryClient is an abstraction for service discovery that in this case happens to be implemented via Eureka, but can also provide integration with alternative stacks such as Consul. The DiscoveryClient is able to provide location information (such as network addresses) and other metadata about service instances registered with Eureka by those service’s logical identifier.

The load balancing provided by Eureka is limited to round robin. Ribbon provides a sophisticated client-side IPC library with configurable load balancing and fault tolerance. Ribbon can be populated with dynamic server lists obtained from a Eureka server. Spring Cloud Netflix provides integration with Ribbon by adding the spring-cloud-starter-ribbon dependency to a Spring Boot application. This additional library provides the ability to inject a properly configured instance of LoadBalancerClient into any Spring Bean, which will enable client-side load balancing (Figure 4).

Using a client-side load balancer
Figure 4: Using a client-side load balancer
Among other tasks, using Ribbon enables additional load balancing algorithms such as availability filtering, weighted response times, and availability zone affinity.

Spring Cloud Netflix further enhances the Spring developer’s use of Ribbon by automatically creating a Ribbon-enhanced instance of RestTemplate that can be injected into any Spring Bean. Developer can then simply pass the logical service name in the URL provided to RestTemplate:

@Autowired
@LoadBalanced
private RestTemplate restTemplate;

@RequestMapping("/")
public String consume() {
   ProducerResponse response = restTemplate.getForObject("http://producer", ProducerResponse.class);
   return String.format("{\"value\": %s}", response.getValue());
}

Hystrix provides an implementation of common fault-tolerance patterns for distributed systems such as circuit breakers and bulkheads. Circuit breakers are normally implemented as a state machine, an example of which is found in Figure 5.

Circuit breaker state machine
Figure 5: Circuit breaker state machine
Circuit breakers can be placed between services and their remote dependencies. If the circuit is closed, calls to the dependency pass through normally. If a call fails, that failure is counted. If the number of failures reaches a threshold within a configurable time period, the circuit is tripped to open. While in the open state, calls are no longer sent to the dependency, and the resulting behavior is customizable (throw an exception, return dummy data, call a different dependency, and so on).

Periodically the state machine will transition into a “half open” state to determine if the dependency is healthy again. In this state, requests are again passed through normally. If the request succeeds, the machine transitions back to the closed state. If the request fails, the machine transitions back to the open state.

Spring Cloud applications can leverage Hystrix by adding the spring-cloud-starter-hystrix dependency and annotating their configuration class with @EnableCircuitBreaker. You can then add a circuit breaker to any Spring Bean method by annotating it with @HystrixCommand:

@HystrixCommand(fallbackMethod = "getProducerFallback")
public ProducerResponse getValue() {
   return restTemplate.getForObject("http://producer", ProducerResponse.class);
}

This example specifies a fallback method called getProducerFallback. When the circuit breaker is in an open state, this method will be called in lieu of getValue:

private ProducerResponse getProducerFallback() {
   return new ProducerResponse(42);
}

In addition to providing the state machine behavior, Hystrix also emits a metrics stream from each breaker providing important telemetry such as request metering, a response time histogram, and the number of successful, failed, and short-circuited requests (Figure 6).

Hystrix dashboard
Figure 6: Hystrix dashboard
Zuul handles all incoming requests to Netflix’s edge services. It is used in combination with other Netflix components like Ribbon and Hystrix to provide a flexible and resilient routing tier for Netflix services.

Netflix uses filters dynamically loaded into Zuul to perform the following functions:

Authentication and security: Identifying authentication requirements for each resource and rejecting requests that do not satisfy them.
Insights and monitoring: Tracking meaningful data and statistics at the edge in order to give us an accurate view of production.
Dynamic routing: Dynamically routing requests to different back-end clusters as needed.
Stress testing: Gradually increasing the traffic to a cluster in order to gauge performance.
Load shedding: Allocating capacity for each type of request and dropping requests that go over the limit.
Static response handling: Building some responses directly at the edge instead of forwarding them to an internal cluster.
Multiregion resiliency: Routing requests across AWS regions in order to diversify our ELB usage and move our edge closer to our members.
In addition, Netflix leverages the capabilities of Zuul to perform surgical routing and stress testing via canary releases.