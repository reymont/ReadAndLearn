

# http://cloud.spring.io/spring-cloud-static/docs/1.0.x/spring-cloud.html#_refresh_scope

# Refresh Scope
A Spring @Bean that is marked as @RefreshScope will get special treatment when there is a configuration change. This addresses the problem of stateful beans that only get their configuration injected when they are initialized. For instance if a DataSource has open connections when the database URL is changed via the Environment, we probably want the holders of those connections to be able to complete what they are doing. Then the next time someone borrows a connection from the pool he gets one with the new URL.

Refresh scope beans are lazy proxies that initialize when they are used (i.e. when a method is called), and the scope acts as a cache of initialized values. To force a bean to re-initialize on the next method call you just need to invalidate its cache entry.

The RefreshScope is a bean in the context and it has a public method refreshAll() to refresh all beans in the scope by clearing the target cache. There is also a refresh(String) method to refresh an individual bean by name. This functionality is exposed in the /refresh endpoint (over HTTP or JMX).

NOTE
@RefreshScope works (technically) on an @Configuration class, but it might lead to surprising behaviour: e.g. it does not mean that all the @Beans defined in that class are themselves @RefreshScope. Specifically, anything that depends on those beans cannot rely on them being updated when a refresh is initiated, unless it is itself in @RefreshScope (in which it will be rebuilt on a refresh and its dependencies re-injected, at which point they will be re-initialized from the refreshed @Configuration).

# Endpoints
For a Spring Boot Actuator application there are some additional management endpoints:

* POST to /env to update the Environment and rebind @ConfigurationProperties and log levels
* /refresh for re-loading the boot strap context and refreshing the @RefreshScope beans
* /restart for closing the ApplicationContext and restarting it (disabled by default)
* /pause and /resume for calling the Lifecycle methods (stop() and start() on the ApplicationContext)