

Dec 12 19:02:41 test-perf-service7 dockerd-current[7284]: time="2017-12-12T19:02:41+08:00" level=fatal msg="unable to configure the Docker daemon with file /etc/docker/daemon.json: the following directives are specified both as a flag and in the configuration file: log-driver: (from flag: journald, from file: fluentd)\n"

```sh
# 
journalctl -xe | less
# To find out where it's set, temporarily rename or remove your daemon.json and use 
systemctl cat docker.service
```