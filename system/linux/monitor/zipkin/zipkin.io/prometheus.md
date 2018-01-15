

# https://github.com/openzipkin/zipkin/tree/master/zipkin-server

Metrics

Metrics are exported to the path /metrics and extend defaults reported by spring-boot.

Metrics are also exported to the path /prometheus if the zipkin-autoconfigure-metrics-prometheus is available in the classpath. See the prometheus metrics README for more information.


# https://github.com/openzipkin/zipkin/blob/master/zipkin-autoconfigure/metrics-prometheus/README.md

Prometheus Metrics

Exposes Spring Actuator metrics on /prometheus using the Prometheus exposition text format version 0.0.4.

Scrape configuration example

  - job_name: 'zipkin'
    scrape_interval: 5s
    metrics_path: '/prometheus'
    static_configs:
      - targets: ['localhost:9411']
    metric_relabel_configs:
      # Response code count
      - source_labels: [__name__]
        regex: '^status_(\d+)_(.*)$'
        replacement: '${1}'
        target_label: status
      - source_labels: [__name__]
        regex: '^status_(\d+)_(.*)$'
        replacement: '${2}'
        target_label: path
      - source_labels: [__name__]
        regex: '^status_(\d+)_(.*)$'
        replacement: 'http_requests_total'
        target_label: __name__


Collector

Collector metrics are broken down by transport. The following are exported to the "/metrics" endpoint:

Metric	Description
counter.zipkin_collector.messages.$transport	cumulative messages received; should relate to messages reported by instrumented apps
counter.zipkin_collector.messages_dropped.$transport	cumulative messages dropped; reasons include client disconnects or malformed content
counter.zipkin_collector.bytes.$transport	cumulative message bytes
counter.zipkin_collector.spans.$transport	cumulative spans read; should relate to messages reported by instrumented apps
counter.zipkin_collector.spans_dropped.$transport	cumulative spans dropped; reasons include sampling or storage failures
gauge.zipkin_collector.message_spans.$transport	last count of spans in a message
gauge.zipkin_collector.message_bytes.$transport	last count of bytes in a message