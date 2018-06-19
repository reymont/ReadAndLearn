Microservices with Apache Camel, Spring Boot and Docker http://www.sixtree.com.au/articles/2016/microservices-springboot-camel-docker/

sohrab-/microservice-simple-example: Example microservice for Sixtree blog post https://github.com/sohrab-/microservice-simple-example

This is 2016. If you are still spending macro-efforts developing microservices, there is something seriously wrong. These days, there are plenty of tools and frameworks at the disposal of the discerning developer to rapidly build microservices.

To demonstrate this, we will build a quick microservice here together. The goal is rapid development and small code footprint. To this end, I propose the following stack:

Spring Boot is an opinionated dependency injection framework to get a Spring application up and running in no time. It favours convention over configuration and has made giant strides in streamlining Java development since… well… since Spring.
Apache Camel is a fairly mature implementation of Enterprise Integration Patterns. We could write hundreds of lines of code to integrate our microservice into the back-end or we could use hundreds of Camel components to do the same with minimum effort.
Docker requires no introduction and is used to create a consistent deployable unit that is guaranteed to behave the same regardless of target deployment environment. This also gives us the flexibility to scale the microservice horizontally.
Camel + Spring Boot + Docker

There is no point trying to do rapid development if the programming language and tooling gets in the way. As such, we will also choose

Apache Groovy is a dynamic language running on JVM. While Java cowers in the face of change and moves forward in a frustratingly slow pace compared to its competitors, we reach for other JVM languages to bridge the gap. Groovy is a good middle-ground, especially when introducing Java developers to the current century.
Gradle is again another response to the cumbersome tools of the Java ecosystem. It provides build and dependency management without the constant wrestling matches with Maven.
So if you are still messing about with hierarchy of giant POM files and thousands of lines of code, I want you to get up, go stand in front of the mirror and take a serious look at yourself.

As for our microservice design, we will be building a REST API in front of a relational database to provide CRUD operations to consumers. The Camel application will expose the API over an embedded Jetty web server, running inside a Docker container.

In a great leap of imagination, the service will be Thing Service which will be used to create, query and delete Things.

For those playing at home, you will only need Gradle and your favourite text editor to follow along.

Setup a Spring Boot Project
A minimal, and completely useless, Spring Boot application is created by the following class:

import org.springframework.boot.autoconfigure.SpringBootApplication

@SpringBootApplication
class Application {
    public static void main(String[] args) {
        SpringApplication.run Application, args
    }
}
Spring Boot prefers conventions and annotations over the traditional Spring XML so we will try to follow this principle throughout this example.

To actually run this application though, we will need to configure Gradle to pull in the necessary dependencies and build tasks. The following build.gradle does just that:

buildscript {
    repositories {
        mavenCentral()
    }
    dependencies {
        classpath('org.springframework.boot:spring-boot-gradle-plugin:1.3.3.RELEASE')
    }
}

apply plugin: 'groovy'
apply plugin: 'spring-boot'

jar {
    baseName = 'thing-service'
    version =  '1.0.0'
}

repositories {
    mavenCentral()
}

sourceCompatibility = 1.8
targetCompatibility = 1.8

dependencies {
    compile 'org.springframework.boot:spring-boot-starter'
    compile 'org.codehaus.groovy:groovy-all:2.4.5'
}
The project is configured with Groovy compiling and using all the common-sense defaults of Spring Boot. We now have a skeleton of a Spring Boot application ready to be developed further.

.
├── build.gradle
└── src
    └── main
        └── groovy
            └── Application.groovy
Add Camel
Camel 2.15 introduced camel-spring-boot component for auto-configuration of Camel applications. Upcoming 2.17 will add camel-spring-boot-starter to make creating new projects of this nature even simpler.

To take advantage of Camel Spring Boot, and also enabling Camel’s Groovy DSL, we add the following dependencies to our build.gradle file:

dependencies {
    compile 'org.apache.camel:camel-spring-boot:2.16.2'
    compile 'org.apache.camel:camel-groovy:2.16.2'
}
Now any correctly annotated RouteBuilder class is automatically detected and instantiated by Spring Boot. Here is an example of such class:

import org.apache.camel.builder.RouteBuilder
import org.springframework.stereotype.Component

@Component
class RestRoute extends RouteBuilder {
    @Override
    void configure() throws Exception {
        // TODO add routes
    }
 }
Build the REST API
Next, we can use Camel’s REST DSL to create a REST API implementation in ridiculously short order. But first, we need to define our sophisticated Thing data model, used by this API. In this use case, we define them using POJOs (or rather POGOs):

class Thing {
    Integer id
    String name
    String owner
}

class ThingSearchResults {
    Integer size
    List<Thing> things
}
With the data model available, we can now define our REST configuration and routing logic within the RouteBuilder.configure() method:

@Component
class RestRoute extends RouteBuilder {
 
    @Value('${rest.host}') String host
    @Value('${rest.port}') String port

    @Override
    void configure() throws Exception {
        restConfiguration()
            .component('jetty')
            .host(host).port(port)
            .bindingMode(RestBindingMode.json)

        rest('/things')
            .post()
                .type(Thing)
                .to('direct:createThing')
            .get()
                .outType(ThingSearchResults)
                .to('direct:getThings')
            .get('/{id}')
                .outType(Thing)
                .to('direct:getThing')
            .delete('/{id}')
                .outType(Thing)
                .to('direct:removeThing')
    }
}
At the top, we are demonstrating the use of property-placeholders and properties files. Spring Boot automatically loads properties from application.properties file, or in our case application.yml file, in src/main/resources directory. These are also automatically available to Camel with the usual conventions.

Here is the content of our src/main/resources/application.yml file:

---
rest:
  host: 0.0.0.0
  port: 8080
Moving on, restConfiguration() is used to configure the REST endpoints, including the underlying component, which is Jetty webserver in this case. rest() defines the actual routing logic whose format and functionality should be self-evident.

REST DSL is part of camel-core but we need to add dependencies for Jetty and our JSON un/marshalling:

dependencies {
    compile 'org.apache.camel:camel-jetty:2.16.2'
    compile 'org.apache.camel:camel-jackson:2.16.2'
}
Mix-in Database
To simulate the back-end database, we will use H2 in-memory database and Camel’s JPA and SQL components to interact with it.

To this end, we first need to add the relevant dependencies:

dependencies {
    compile 'org.springframework.boot:spring-boot-starter-data-jpa'
    runtime 'com.h2database:h2'

    compile 'org.apache.camel:camel-jpa:2.16.2'
    compile 'org.apache.camel:camel-sql:2.16.2'
}
Spring Boot’s JPA starter automatically detects the H2 dependency and also scans src/main/resources for SQL scripts to execute at start-up. We add schema.sql file in that directory with the following content:

CREATE TABLE THING (
    ID NUMBER NOT NULL AUTO_INCREMENT,
    NAME VARCHAR(255),
    OWNER VARCHAR(255),
    PRIMARY KEY (ID)
);
The table and the data model mirror each other and so the data model is enhanced with the necessary JPA annotations:

import import javax.persistence.*

@Entity(name = "THING")
class Thing {

    @Id @GeneratedValue @Column(name = "ID") 
    Integer id

    @Column(name = "NAME") 
    String name

    @Column(name = "OWNER") 
    String owner
}
Now we are ready to actually implement the logic behind our REST API:

from('direct:createThing')
    .to('jpa:au.com.sixtree.blog.Thing')

from('direct:getThing')
    .to('sql:select * from THING where id = :#${header.id}?dataSource=dataSource&outputType=SelectOne')
    .beanRef('transformer', 'mapThing')

from('direct:getThings')
    .setProperty('query').method('transformer', 'constructQuery(${headers})')
    .toD('sql:${property.query}?dataSource=dataSource')
    .beanRef('transformer', 'mapThingSearchResults')

from('direct:removeThing')
    .to('direct:getThing')
    .setProperty('thing', body())
    .to('sql:delete from THING where id = :#${body.id}?dataSource=dataSource')
    .setBody(property('thing'))
Each route does what is prescribed by the REST API conventions. For example, DELETE operation removes a resource, also returning the said resource in the response.

The implementation also demonstrate the use of a transformer class, here imaginatively named transformer. For Spring Boot to instantiate and make this bean available to Camel Context, we simply need to add the @Component annotation to the class.

@Component('transformer')
class Transformer {
    ...
}
The content of the class is available on GitHub.

We now have a fully functioning Spring Boot + Camel application. You can test-drive the service through Gradle by executing gradle bootRun in the project’s root directory. This will bring up the Jetty server, bounded to port 8080 on the localhost, ready to receive REST requests.

Dockerise
But we are not done yet. Spring Boot generates a fat JAR as part of the Gradle build. This JAR needs to be placed in a Java-capable container before it can be deployed.

A good candidate as the base Docker image is the official Java Docker image, built on top of an Alpine image. The JVM is already a sizeable layer so we opt for a minimal OS image like Alpine to ensure smallest possible image size. Even with this optimisation, the resultant image ends up being about 143.8 MB.

Now we can either hand-craft a Dockerfile like a savage or thanks to Docker Gradle plugin, by folks at Transmode, we can do this in our build script:

buildscript {
    ...
    dependencies {
        ...
        classpath('se.transmode.gradle:gradle-docker:1.2')
    }
}
...
apply plugin: 'docker'

docker {
    baseImage 'java:8-jre-alpine'
    maintainer 'sohrab <sohrab.hosseini@gmail.com>'
}

task buildDocker(type: Docker) {
    dependsOn build
    applicationName = jar.baseName

    addFile jar.archivePath, '/app.jar'
    defaultCommand([ 'java', '-jar', '/app.jar' ])
    exposePort 8080
}
No changes are needed to the actual production code of the application when we introduce Docker to the mix.

Now executing gradle buildDocker will generate a Dockerfile similar to the following:

FROM java:8-jre-alpine
MAINTAINER sohrab <sohrab.hosseini@gmail.com>
ADD thing-service-1.0.0.jar /app.jar
CMD ["java", "-jar", "/app.jar"]
EXPOSE 8080
The plugin also builds the corresponding Docker image locally. Further configuration can be added to actually push the said image to a Docker Registry.

To test our image, we can execute the following command locally:

$ docker run -p 8080:8080 thing-service
This will run a Docker container which in turn executes our runnable JAR that was copied inside the image.

Here is a transcript of exercising the REST API, assuming the port was bounded to localhost:

$ curl --request POST --header 'Content-Type: application/json' --data '{"name":"bob", "owner":"someone"}' http://localhost:8080/things
{"id":1,"name":"bob","owner":"someone"}

$ curl --request POST --header 'Content-Type: application/json' --data '{"name":"chuck", "owner":"someone else"}' http://localhost:8080/things
{"id":2,"chuck":"bob","owner":"someone else"}

$ curl --request GET 'http://localhost:8080/things'
{"size":2,"things":[{"id":1,"name":"bob","owner":"someone"},{"id":2,"name":"chuck","owner":"someone else"}]}

$ curl --request GET 'http://localhost:8080/things/2'
{"id":2,"name":"chuck","owner":"someone else"}

$ curl --request GET 'http://localhost:8080/things?owner=someone'
{"size":1,"things":[{"id":1,"name":"bob","owner":"someone"}]}
And that’s it. In fewer than 100 lines of production code, we have managed to prototype a full-fledged microservice with a REST API and database integration.

.
├── build.gradle
└── src
    └── main
        ├── groovy
        │   └── Application.groovy
        └── resources
            ├── application.yml
            └── schema.sql
The source code for the project is available on GitHub.

What’s Left
For the sake of brevity and to create content that works in a blog post, I did cut some very obvious corners and omitted some features that is required for a resilient and production-ready application. For example:

I put all the source code in the same Application.groovy in the root of src/main/groovy since I was lazy and Groovy lets you do that. Each class should be in the correct package directory and its own Groovy file
The current solution does not include any error handling logic, for example HTTP 404 when we try to retrieve or delete a non-existent Thing.
A real-life solution would most likely not use an in-memory DB, inside the container for storage. A data source to an external DB should be configured.
No unit and route testing code has been included in the example.
Please feel free to fork the repository and attempt your own enhancements.


You might also enjoy:

Dock Tales: Docker Authoring, with Special Guest Mule ESB 30 March 2015

Ansible Crash Course 09 March 2016

Developing Bulk APIs with Mule, RAML and APIKit 02 December 2014

Jumpstarting Camel Blueprint Testing 09 March 2016

Advanced File Handling in Mule 15 June 2015


comments powered by Disqus