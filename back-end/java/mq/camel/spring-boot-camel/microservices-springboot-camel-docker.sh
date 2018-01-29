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

http://127.0.0.1:8080/things?httpMethodRestrict=GET

curl --request POST --header 'Content-Type: application/json' \
--data '{"name":"bob", "owner":"someone"}' \
http://localhost:8080/things
# {"id":1,"name":"bob","owner":"someone"}

curl --request POST --header 'Content-Type: application/json' \
--data '{"name":"chuck", "owner":"someone else"}' \
http://localhost:8080/things
# {"id":2,"chuck":"bob","owner":"someone else"}

curl --request GET 'http://localhost:8080/things'
# {"size":2,"things":[{"id":1,"name":"bob","owner":"someone"},{"id":2,"name":"chuck","owner":"someone else"}]}

curl --request GET 'http://localhost:8080/things/2'
# {"id":2,"name":"chuck","owner":"someone else"}

curl --request GET 'http://localhost:8080/things?owner=someone'
# {"size":1,"things":[{"id":1,"name":"bob","owner":"someone"}]}