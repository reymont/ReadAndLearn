



# prometheus/blackbox_exporter:
 Blackbox prober exporter 
https://github.com/prometheus/blackbox_exporter



The blackbox exporter allows blackbox probing of endpoints over HTTP, HTTPS, DNS, TCP and ICMP.
Building and running
Local Build
make
./blackbox_exporter <flags>
Visiting http://localhost:9115/probe?target=google.com&module=http_2xx will return metrics for a HTTP probe against google.com. The probe_success metric indicates if the probe succeeded.


#编译blackbox_exporter
go build .




Building with Docker
docker build -t blackbox_exporter .
docker run -d -p 9115:9115 --name blackbox_exporter -v `pwd`:/config blackbox_exporter -config.file=/config/blackbox.yml
Configuration
A configuration showing all options is below:
modules:
  http_2xx_example:
    prober: http
    timeout: 5s
    http:
      valid_status_codes: []  # Defaults to 2xx
      method: GET
      headers:
        Host: vhost.example.com
        Accept-Language: en-US
      no_follow_redirects: false
      fail_if_ssl: false
      fail_if_not_ssl: false
      fail_if_matches_regexp:
        - "Could not connect to database"
      fail_if_not_matches_regexp:
        - "Download the latest version here"
      tls_config:
        insecure_skip_verify: false
      protocol: "tcp" # accepts "tcp/tcp4/tcp6", defaults to "tcp"
      preferred_ip_protocol: "ip4" # used for "tcp", defaults to "ip6"
  http_post_2xx:
    prober: http
    timeout: 5s
    http:
      method: POST
      headers:
        Content-Type: application/json
      body: '{}'
  tcp_connect_v4_example:
    prober: tcp
    timeout: 5s
    tcp:
      protocol: "tcp4"
  irc_banner_example:
    prober: tcp
    timeout: 5s
    tcp:
      query_response:
        - send: "NICK prober"
        - send: "USER prober prober prober :prober"
        - expect: "PING :([^ ]+)"
          send: "PONG ${1}"
        - expect: "^:[^ ]+ 001"
  icmp_example:
    prober: icmp
    timeout: 5s
    icmp:
      protocol: "icmp"
      preferred_ip_protocol: "ip4"
  dns_udp_example:
    prober: dns
    timeout: 5s
    dns:
      query_name: "www.prometheus.io"
      query_type: "A"
      valid_rcodes:
      - NOERROR
      validate_answer_rrs:
        fail_if_matches_regexp:
        - ".*127.0.0.1"
        fail_if_not_matches_regexp:
        - "www.prometheus.io.\t300\tIN\tA\t127.0.0.1"
      validate_authority_rrs:
        fail_if_matches_regexp:
        - ".*127.0.0.1"
      validate_additional_rrs:
        fail_if_matches_regexp:
        - ".*127.0.0.1"
  dns_tcp_example:
    prober: dns
    dns:
      protocol: "tcp" # accepts "tcp/tcp4/tcp6/udp/udp4/udp6", defaults to "udp"
      preferred_ip_protocol: "ip4" # used for "udp/tcp", defaults to "ip6"
      query_name: "www.prometheus.io"
HTTP, HTTPS (via the http prober), DNS, TCP socket and ICMP (v4 only, see permissions section) are currently supported. Additional modules can be defined to meet your needs.
Prometheus Configuration
The blackbox exporter needs to be passed the target as a parameter, this can be done with relabelling.
Example config:
scrape_configs:
  - job_name: 'blackbox'
    metrics_path: /probe
    params:
      module: [http_2xx]  # Look for a HTTP 200 response.
    static_configs:
      - targets:
        - prometheus.io   # Target to probe
    relabel_configs:
      - source_labels: [__address__]
        regex: (.*)(:80)?
        target_label: __param_target
        replacement: ${1}
      - source_labels: [__param_target]
        regex: (.*)
        target_label: instance
        replacement: ${1}
      - source_labels: []
        regex: .*
        target_label: __address__
        replacement: 127.0.0.1:9115  # Blackbox exporter.
Permissions
The ICMP probe requires elevated privileges to function:
•	Windows: Administrator privileges are required.
•	Linux: root user or CAP_NET_RAW capability is required.
o	Can be set by executing setcap cap_net_raw+ep blackbox_exporter
•	BSD / OS X: root user is required.






# [question] Dynamic Prometheus configuration • Issue #2041 • 
prometheus/prometheus https://github.com/prometheus/prometheus/issues/2041


Great, file_sd_configs worked nicely with my blackbox job.
As far the refresh_interval, the documentation says
# Refresh interval to re-read the files.
[ refresh_interval: <duration> | default = 5m ]
... however the refresh rate for me was a couple of secs.
I tried to configure the refresh_interval as:
scrape_configs:
  - job_name: 'blackbox-http-2xx-secure'
    metrics_path: /probe
    params:
      module: [http_2xx]  # Look for a HTTP 200 response.
    file_sd_configs:
      - files:
        - '/etc/prometheus/blackbox/*.yml'
      - refresh_interval: 10s
    relabel_configs:
      - source_labels: [__address__]
        regex: (.*)(:80)?
        target_label: __param_target
        replacement: ${1}
      - source_labels: [__param_target]
        regex: (.*)
        target_label: instance
        replacement: ${1}
      - source_labels: []
        regex: .*
        target_label: __address__
        replacement: 127.0.0.1:9115  # Blackbox exporter.
And it gives this error message:
time="2016-09-30T19:23:31Z" level=error msg="Error loading config: couldn't load configuration (-config.file=/etc/prometheus/prometheus.yml): file service discovery config must contain at least one path name" source="main.go:126"
it works fine without the refresh_interval on the job configuration.


@hgontijo That is odd. Refreshes resulting from the refresh timer should execute the same code path as the initial load or refreshes triggered by changes to the files.
By the way: you probably do not need to set your refresh interval to 10s. The file_sd SD mechanism automatically detects changes to any of the watched target files, so the refresh interval is only a safety guard in case a watched update ever gets lost due to some bug or something. Then it will still eventually get the new target state. Normally you should be able to keep it at 5 minutes or so.


@juliusv the error message happens when I configure refresh_interval under file_sd_configs and restart (stop/start) the service. As you suggested, I'll go without refresh_interval since the file change detection works fine .



# Prometheus won't read file_sd_config • Issue #909 
• prometheus/prometheus https://github.com/prometheus/prometheus/issues/909


I don't see errors upon my prometheus, version 0.17.0 (branch: stable, revision: 6e8d4e9). How do I check for an error?
I'm losing my mind why for example:
http://s.natalian.org/2016-04-13/prometheus.yml
http://s.natalian.org/2016-04-13/targets.yml
Is not working.



file_sd_configs



https://s.natalian.org/2016-04-13/prometheus.yml

scrape_configs:
  - job_name: 'foo'
    scrape_interval: 10s
    scrape_timeout: 10s
    metrics_path: /probe
    params:
      module: [http_2xx]  # Look for a HTTP 200 response.
    file_sd_configs:
      - names:
        - targets.yml
    relabel_configs:
      - source_labels: [__address__]
        regex: (.*)(:80)?
        target_label: __param_target
        replacement: ${1}
      - source_labels: [__param_target]
        regex: (.*)
        target_label: instance
        replacement: ${1}
      - source_labels: []
        regex: .*
        target_label: __address__
        replacement: 10.8.1.113:9115  # Blackbox exporter.


https://s.natalian.org/2016-04-13/targets.yml

targets.yml

- targets:
  - host1.example.com:9103
  - host2.example.com:9103
  - host3.example.com:9103
  - host4.example.com:9103
  - host5.example.com:9103
  labels:
    job: zookeeper




