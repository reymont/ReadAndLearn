


# https://zipkin.io/pages/quickstart.html
# https://github.com/openzipkin/docker-zipkin

docker pull index.docker.io/openzipkin/zipkin:2.4
docker run -d -p 9411:9411 --restart always --name zipkin\
 index.docker.io/openzipkin/zipkin:2.4

# https://github.com/openzipkin/brave-webmvc-example
# https://github.com/joshlong/cloud-native-workshop/blob/master/code-java/zipkin-service
# https://github.com/jessyZu/dubbo-zipkin-spring-starter