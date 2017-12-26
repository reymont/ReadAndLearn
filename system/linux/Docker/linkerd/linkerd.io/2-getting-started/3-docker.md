

https://linkerd.io/getting-started/docker/


```sh
docker-machine start
eval $("C:\Program Files\Docker Toolbox\docker-machine.exe" env)
cat >>config.yaml <<EOF
admin:
  port: 9990

routers:
- protocol: http
  dtab: /svc => /$/inet/127.1/9990;
  servers:
  - port: 8080
EOF
docker-machine ssh
docker run --name linkerd -v `pwd`/config.yaml:/config.yaml buoyantio/linkerd:1.3.4 /config.yaml
docker-machine ssh
docker exec linkerd curl -s 127.1:8080/admin/ping
```



Running with Docker
If you’re using Docker to run Linkerd, there is no need to pull the release binary from GitHub, as described in the previous section. Instead, Buoyant provides the following public Docker images for you:

buoyantio/linkerd:1.3.4 buoyantio/namerd:1.3.4

Tags
Both repositories have tags for all stable released versions of each image. To see a list of releases with associated changes, visit the Linkerd GitHub releases page.

In addition to the versioned tags, the “latest” tag always points to the most recent stable release. This can be useful for environments that want to pick up new code without manually bumping the dependency version, but note that the latest tag may pull an image with breaking changes from a previous version, depending on the nature of the Linkerd release.

Furthermore, the “nightly” tag is used to provide nightly builds of both Linkerd and namerd from the most recent commit on the master branch in the Linkerd GitHub repository. This image is unstable, but can be used for testing recently added features and fixes.

Running
The default entrypoint for the Linkerd image runs the Linkerd executable, which requires that a Linkerd config file be passed to it on the command line. The easiest way to accomplish this is by mounting a config file into the container at startup.

For instance, given the following config that simply forwards http requests received on port 8080 to the Linkerd admin service running on port 9990:

admin:
  port: 9990

routers:
- protocol: http
  dtab: /svc => /$/inet/127.1/9990;
  servers:
  - port: 8080
We can start the Linkerd container with:

$ docker run --name linkerd -v `pwd`/config.yaml:/config.yaml buoyantio/linkerd:1.3.4 /config.yaml
...
I 0922 02:01:12.862 THREAD1: serving http admin on /0.0.0.0:9990
I 0922 02:01:12.875 THREAD1: serving http on localhost/127.0.0.1:8080
I 0922 02:01:12.890 THREAD1: linkerd initialized.
Making sure it works
To verify that it’s working correctly, we can exec into the running container and curl Linkerd’s admin ping endpoint via the http router’s configured port:

$ docker exec linkerd curl -s 127.1:8080/admin/ping
pong
Success! For more information about Linkerd’s admin capabilities, see the Administration page.