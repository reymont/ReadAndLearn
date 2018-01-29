# Simple Microservice Example
## This is the source code for Microservices with Apache Camel, Spring Boot and Docker blog post on Sixtree webiste.
## Using Groovy, Gradle, Apache Camel, Spring Boot and Docker, we demonstrate how to quickly create a microservice.
## The microservice exposes a REST API for interacting with an in-memory H2 Database.

# To run the application through Spring Boot (not Docker):
gradle bootRun
# To build the Docker image for the project:
gradle buildDocker
# To run the container for the above image:
docker run -p 8080:8080 thing-service