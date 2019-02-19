

http://www.baeldung.com/dubbo

Protocol Support

The framework supports multiple protocols, including dubbo, RMI, hessian, HTTP, web service, thrift, memcached and redis. Most of the protocols looks familiar, except for dubbo. Let’s see what’s new in this protocol.

The dubbo protocol keeps a persistent connection between providers and consumers. The long connection and NIO non-blocking network communication result in a fairly great performance while transmitting small-scale data packets (<100K).

There are several configurable properties, `such as port, number of connections per consumer, maximum accepted connections`, etc.

<dubbo:protocol name="dubbo" port="20880"  connections="2" accepts="1000" />
Dubbo also supports exposing services via different protocols all at once:

<dubbo:protocol name="dubbo" port="20880" />
<dubbo:protocol name="rmi" port="1099" />
 
<dubbo:service interface="com.baeldung.dubbo.remote.GreetingsService"
  version="1.0.0" ref="greetingsService" protocol="dubbo" />
<dubbo:service interface="com.bealdung.dubbo.remote.AnotherService"
  version="1.0.0" ref="anotherService" protocol="rmi" />
And yes, we can expose different services using different protocols, as shown in the snippet above. The underlying transporters, serialization implementations and other common properties relating to networking are configurable as well.