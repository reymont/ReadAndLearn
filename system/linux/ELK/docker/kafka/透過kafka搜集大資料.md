

https://peihsinsu.gitbooks.io/fluentd-in-action/content/kafka.html

透過kafka搜集大資料

Kafka是一套開源的pubsub系統，可以用來作為資料暫留的佇列，作為大資料搜集的工具是再好不過，fluentd的kafka plugin專案可以在這邊找到: https://github.com/htgc/fluent-plugin-kafka。
Installation

一般在本機安裝，可以透過ruby的gem來安裝fluentd kafka的plugin..
gem install fluent-plugin-kafka
Build your docker

在Docker的環境，我們可以用下面的Dockerfile配置來準備執行環境...
Dockerfile:
FROM ruby:2.2.0
MAINTAINER simonsu.mail@gmail.com
RUN apt-get update
RUN gem install fluentd -v "~>0.12.3"
RUN mkdir /etc/fluent
RUN apt-get install -y libcurl4-gnutls-dev make
RUN /usr/local/bin/gem install fluent-plugin-kafka && /usr/local/bin/gem install fluent-plugin-secure-forward && \
  /usr/local/bundle/bin/secure-forward-ca-generate /tmp/ notasecret
#RUN /usr/local/bin/gem install fluent-plugin-elasticsearch
ADD fluent.conf /etc/fluent/
ENTRYPOINT ["/usr/local/bundle/bin/fluentd", "-c", "/etc/fluent/fluent.conf"]
Build:
docker build -t linkeriot/fluentd .
Run a sample

在執行前，需要有fluentd的設定檔... 下面準備一個可以接受http input與stdout + kafka output的設定檔...
fluent.conf:
<source>
  type http
  port 9880
</source>

<match *.**>
  type copy
  <store>
    type stdout
  </store>
  <store>
    @type kafka
    @id kafka_output
    brokers your-ip-address:your-port
    output_data_type json
    default_topic iot
  </store>
</match>
在設定檔中，指定kafka的topic為iot，且格式為json。
Run:

docker run -it -p 9880:9880 -v $(pwd)/fluent.conf:/fluent.conf linkeriot/fluentd bash
上面的執行部分，由於需要測試http input，因此需要打開9880 port對外。如果您的fluent.conf未包入image中，則可以透過-v掛載該設定檔到image中...
最後，由於已經export 9880 port，因此可以透過curl來輸入資料...
curl -X POST -d 'json={"action":"login","user":423}' http://your-gw-ip:9880/iot.message.aaa
最後，我們可以透過下面的指令來確認kafka有收到資料與否...
kafkacat -C -b "52.79.124.228:8083" -t iot -p 0 -e