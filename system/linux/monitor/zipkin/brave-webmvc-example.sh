
# https://github.com/openzipkin/brave-webmvc-example

# Once the services are started, open http://localhost:8081/

# This will call the backend (http://localhost:9000/api) and show the result, which defaults to a formatted date.
# Next, you can view traces that went through the backend via http://localhost:9411/?serviceName=backend

# This is a locally run zipkin service which keeps traces in memory

# Starting the Services
# In a separate tab or window, start each of brave.webmvc.Frontend and brave.webmvc.Backend:
# choose webmvc25 webmvc3 or webmvc4
$ cd webmvc4
$ mvn jetty:run -Pfrontend
$ mvn jetty:run -Pbackend
# Next, run Zipkin, which stores and queries traces reported by the above services.

curl -sSL https://zipkin.io/quickstart.sh | bash -s
java -jar zipkin.jar