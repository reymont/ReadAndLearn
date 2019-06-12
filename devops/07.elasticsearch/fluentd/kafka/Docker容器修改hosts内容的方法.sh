
# http://securityer.lofter.com/post/1d0f3ee7_a937f2f
docker run --rm --add-host host:172.20.62.42 busybox cat /etc/hosts
docker run --rm --add-host host:172.20.62.42 busybox ping host