
https://github.com/elastic/elasticsearch-docker/issues/49


I build my own Dockerfile and change the uid/gid to some other and everything works for now

FROM docker.elastic.co/elasticsearch/elasticsearch:5.3.0
# Switch to root for install
USER root
#Hack
RUN echo http://dl-2.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories
RUN apk add --no-cache shadow && \ 
 usermod -u 555  elasticsearch && \
 groupmod -g 555 elasticsearch && \
	find . -user  1000 -exec chown -h 555 {} \; && \
	find . -group 1000 -exec chgrp -h 555 {} \; && \
	usermod -g 555 elasticsearch

# Switch back 
USER elasticsearch 

```yml
Another temporary workaround is to write your own Dockerfile, based on the history from elasticsearch

FROM alpine

RUN apk --no-cache  add bash curl openjdk8 openssl                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
RUN adduser -D -u 555 -h /usr/share/elasticsearch elasticsearch                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             

ARG ELASTIC_VERSION
ARG ES_DOWNLOAD_URL
ARG ES_JAVA_OPTS

ENV ELASTIC_VERSION=5.3.0 
ENV ES_DOWNLOAD_URL=https://artifacts.elastic.co/downloads/elasticsearch 
ENV PATH /usr/share/elasticsearch/bin:$PATH
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk

WORKDIR /usr/share/elasticsearch

# Download/extract defined ES version. busybox tar can't strip leading dir.
RUN wget ${ES_DOWNLOAD_URL}/elasticsearch-${ELASTIC_VERSION}.tar.gz && \
    EXPECTED_SHA=$(wget -O - ${ES_DOWNLOAD_URL}/elasticsearch-${ELASTIC_VERSION}.tar.gz.sha1) && \
    test $EXPECTED_SHA == $(sha1sum elasticsearch-${ELASTIC_VERSION}.tar.gz | awk '{print $1}') && \
    tar zxf elasticsearch-${ELASTIC_VERSION}.tar.gz && \
    chown -R elasticsearch:elasticsearch elasticsearch-${ELASTIC_VERSION} && \
    mv elasticsearch-${ELASTIC_VERSION}/* . && \
    rmdir elasticsearch-${ELASTIC_VERSION} && \
    rm elasticsearch-${ELASTIC_VERSION}.tar.gz

RUN set -ex && for esdirs in config data logs; do \
        mkdir -p "$esdirs"; \
        chown -R elasticsearch:elasticsearch "$esdirs"; \
    done

# Install Plugin
RUN /usr/share/elasticsearch/bin/elasticsearch-plugin list
RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch repository-s3

# Remove x-pack 'https://github.com/elastic/elasticsearch-docker/issues/35#issuecomment-285912424
# RUN /usr/share/elasticsearch/bin/elasticsearch-plugin remove  x-pack
RUN rm -rf plugins/x-pack


USER elasticsearch

COPY elasticsearch.yml config/
COPY log4j2.properties config/
COPY bin/es-docker bin/es-docker

USER root
RUN chown elasticsearch:elasticsearch config/elasticsearch.yml config/log4j2.properties bin/es-docker && \
    chmod 0750 bin/es-docker

USER elasticsearch
CMD ["/bin/bash", "bin/es-docker"]
```


# One strategy for changing the uid/gid in a dynamic way, when you build the image, is to use build args.

```yml
FROM docker.elastic.co/elasticsearch/elasticsearch:5.3.0
ARG CUSTOM_UID
ARG CUSTOM_GID
USER root
RUN sed -r -i "s/^elasticsearch:x:\d+:\d+:(.*)\$/elasticsearch:x:$CUSTOM_UID:$CUSTOM_GID:\1/" /etc/passwd && \
    sed -r -i "s/^elasticsearch:x:\d+:(.*)\$/elasticsearch:x:$CUSTOM_GID:\1/" /etc/group && \
    chown -R $CUSTOM_UID:$CUSTOM_GID /usr/share/elasticsearch
USER elasticsearch
```

$ id
uid=1001(elastic) gid=1001(elastic) groups=1001(elastic),1002(docker) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
$ docker build --build-arg CUSTOM_UID=$(id -u) --build-arg CUSTOM_GID=$(id -g) -t myes .
This results in a working container:
docker run --rm myes