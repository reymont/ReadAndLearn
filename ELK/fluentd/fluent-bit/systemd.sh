

# Systemd · Fluent Bit v0.12 Documentation 
# http://fluentbit.io/documentation/0.12/input/systemd.html

# In the example above we are collecting all messages coming from the Docker service.
fluent-bit -i systemd \
  -p systemd_filter=_SYSTEMD_UNIT=docker.service \
  -p tag='host.*' -o stdout
docker run --name fluent-bit -ti fluent/fluent-bit:0.12 /fluent-bit/bin/fluent-bit -i cpu -o stdout -f 
docker run --name fluent-bit -ti fluent/fluent-bit:0.12 /fluent-bit/bin/fluent-bit -i systemd \
  -p systemd_filter=_SYSTEMD_UNIT=docker.service \
  -p tag='host.*' -o stdout