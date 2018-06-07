

# https://github.com/linkerd/linkerd-examples/blob/master/getting-started/docker/README.md

git clone https://github.com/linkerd/linkerd-examples.git
cd linkerd-examples/getting-started/docker
/opt/linkerd-examples/getting-started/docker

# starts up an nginx service that serves static content from the www directory and a linkerd
docker-compose up -d
# set the Host header to `hello` so that the request is routed to the nginx service.
curl -H "Host: hello" 172.20.62.42:4140
# dashboard
http://172.20.62.42:9990