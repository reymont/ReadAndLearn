

http://fluentbit.io/documentation/0.12/installation/docker.html

docker run -ti fluent/fluent-bit:0.12 /fluent-bit/bin/fluent-bit -i cpu -o stdout -f 1

docker run --rm -ti fluent/fluent-bit:0.12 /fluent-bit/bin/fluent-bit -i cpu -o stdout -f 1

docker run --rm -it \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /:/host \
    registry.cn-hangzhou.aliyuncs.com/acs-sample/fluentd-pilot:0.1