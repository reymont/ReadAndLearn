

# https://hub.docker.com/r/fluent/fluentd/
# https://docs.docker.com/engine/admin/logging/fluentd
docker run -d -p 24224:24224 -p 24224:24224/udp -v /data:/fluentd/log fluent/fluentd
docker run -d -p 24224:24224 -p 24224:24224/udp -v /opt/fluent/data:/fluentd/log fluent/fluentd

# Fluentd is running on this IP address:
docker inspect -f '{{.NetworkSettings.IPAddress}}' custom-docker-fluent-logger
# send its logs to Fluentd.
docker run --log-driver=fluentd --log-opt tag="docker.{{.ID}}" \
  --log-opt fluentd-address=172.20.62.69:24224 \
  python:alpine echo Hello
