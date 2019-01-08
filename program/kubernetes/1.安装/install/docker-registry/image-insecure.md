




```sh
docker push image.service.ob.local:5000/runtime/filebeat:5.4.3
#The push refers to a repository [image.service.ob.local:5000/runtime/filebeat]
#Get https://image.service.ob.local:5000/v1/_ping: http: server gave HTTP response to HTTPS client
cat <<EOF > /etc/sysconfig/docker
DOCKER_OPTS="--insecure-registry=docker.ob.local --insecure-registry=docker.service.ob.local --insecure-registry=image.service.ob.local:5000"
EOF
```