Distributed Tracing - Apache ServiceComb (incubating) http://servicecomb.incubator.apache.org/docs/quick-start-advance/distributed-tracing/

Distributed Tracing

Before you start
Enable
Verification
What’s next
Distributed handler chain tracing is used to monitor the network latencies and visualize the flow of requests through microservices. This guide shows how to use distributed tracing with ServiceComb in the BMI application.

Before you start

Walk through Develop microservice application in minutes and have BMI application running.

Enable

Add distributed tracing dependency in pom.xml of BMI calculator service:

    <dependency>
      <groupId>io.servicecomb</groupId>
      <artifactId>handler-tracing-zipkin</artifactId>
    </dependency>
Copy
Add handler chain of distributed tracing in microservice.yaml of BMI calculator service:

cse:
  handler:
    chain:
      Provider:
        default: tracing-provider
Copy
Add distributed tracing dependency in pom.xml of BMI web service:

    <dependency>
      <groupId>io.servicecomb</groupId>
      <artifactId>spring-cloud-zuul-zipkin</artifactId>
    </dependency>
Copy
The above configurations have already set up in the code. All you need to do is as follows:

Run Zipkin distributed service inside Docker.

docker run -d -p 9411:9411 openzipkin/zipkin
Copy
Restart BMI calculator service with the following command:

mvn spring-boot:run -Drun.jvmArguments="-Dcse.handler.chain.Provider.default=tracing-provider"
Copy
Restart BMI web service with the following command:

mvn spring-boot:run -Drun.jvmArguments="-Dservicecomb.tracing.enabled=true"
Copy
Verification

Visit http://localhost:8889 . Input a positive height and weight and then click Submit button.

Visit http://localhost:9411 to checkout the status of distributed tracing and get the following figure.

Distributed tracing result

What’s next

Learn more about Distributed Tracing

Read Distributed Tracing with ServiceComb and Zipkin

See ServiceComb User Guide

Learn more from the Company application for a more complete example of microservice applications integrated with ServiceComb