

# please add `--insecure-registry 172.27.25.59:5000` to the daemon's arguments · Issue #1005 · docker/docker-registry 
# https://github.com/docker/docker-registry/issues/1005

~$ docker-machine create dev -d virtualbox
~$ docker-machine ssh dev
DOCKER_OPTS=--insecure-registry 172.27.25.59:5000