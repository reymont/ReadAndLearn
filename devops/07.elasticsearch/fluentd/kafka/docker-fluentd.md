

```Dockerfile
FROM fluent/fluentd
MAINTAINER dataeng@vungle.com

RUN gem install \
  fluent-plugin-kafka fluent-plugin \
  fluent-plugin-elasticsearch
```