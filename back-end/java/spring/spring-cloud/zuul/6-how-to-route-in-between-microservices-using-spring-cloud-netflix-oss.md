

https://stackoverflow.com/questions/31313170/how-to-route-in-between-microservices-using-spring-cloud-netflix-oss

During our development of microservices using Spring Cloud, we started out using Zuul as a proxy for any connection from the outside to microservices, and for any microservice needing to contact another microservice.

After some time we made the conclusion that Zuul was designed to be an edge service (only proxying traffic from the outside to the microservices), and shouldn't be used for intermicroservices communication. Especially the way Spring Cloud recommends the use of eureka to make a direct (potentially load balanced) connection to another service made us go against having Zuul in between everything.

Of course everything works nicely as expected (as it always does with Spring Cloud), but we are clueless on how to perform a certain use case with this setup.

When deploying a new version of a microservice, we'd like to have a blue/green deployment with the old and the new version. However, having no Zuul in between the microservices, the communication between two separate services will continue to go to the old version until it is removed from eureka.

We are thinking of how we can achieve this. In the picture below I have drawn what I think might be an option.

In the first part of the picture, Zuul calls eureka to get the registry to create the routes. Also service 1 is calling eureka to get the registry to route to service 2. Since service 2 is in the eureka registry, the routing is done successfully.

In the second part of the picture, an update of service 2 (service 2.1) is deployed. It registers with eureka as well, which makes service 1 now route to both service 2 and service 2.1. This is not wanted with the blue/green deployment.

In the third part a potential solution to this issue is showcased with another instance of eureka being deployed just for this purpose. This instance isn't peer aware and won't sync with the first eureka instance. As opposed to the first instance, this one's only purpose is to facilitate the blue/green deployment. Service 2.1 registers with the second eureka instance, and service 1 his configuration is changed to fetch its registry not from the first but from the second eureka instance.

enter image description here

The main question we are facing is whether this is a viable solution. Having the flexibility of Zuul to route is a big plus which we don't have in this scenario. Should we move back to routing every service-to-service call through Zuul or is there another solution (maybe ribbon configuration of some sort) more appropriate? Or is the second eureka instance the best solution for this type of deployments?

Any feedback would be greatly appreciated.

Kind regards, Andreas