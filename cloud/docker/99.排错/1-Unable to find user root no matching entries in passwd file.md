Unable to find user root: no matching entries in passwd file - Open Source Projects / DockerEngine - Docker Forums https://forums.docker.com/t/unable-to-find-user-root-no-matching-entries-in-passwd-file/26545

I have noticed that whenever I run docker cp command, the later invocations of docker exec do not work and I get the error “unable to find user root: no matching entries in passwd file”

Here is an example where docker exec works fine but after I did docker cp, the docker exec refuse to work.

Same issue here on 1.12.6. A docker cp followed by a docker exec fails to find the user. Running docker stop and then docker start fixes the problem but is hardly a long-term solution. Docker restart does not fix the problem. Is this related to docker cp not releasing a lock on the container?


Ok - I am still seeing this error in Docker version 17.06.0-ce

`The only solution is to restart docker service` - which is an interruption.

Can this be fixed in docker and is becoming an issue for Docker being a SPOF?