



# SNMP Monitoring with Prometheus | Robust Perception 
https://www.robustperception.io/snmp-monitoring-with-prometheus/


SNMP Monitoring with Prometheus
Brian Brazil February 3, 2016
Prometheus isn’t limited to monitoring just machines and applications, it can provide insight for any system you can get metrics out of. That includes network devices, so let’s look at how to monitor SNMP.
First off, let’s install and run the SNMP exporter:
wget https://github.com/prometheus/snmp_exporter/releases/download/v0.1.0/snmp_exporter-0.1.0.linux-amd64.tar.gz
tar -xzf snmp_exporter-0.1.0.linux-amd64.tar.gz
cd snmp_exporter-0.1.0.linux-amd64/
./snmp_exporter
If you visit http://localhost:9116 you can verify it’s running.
Next let’s configure Prometheus to scrape it:
wget https://s3-eu-west-1.amazonaws.com/downloads.robustperception.io/prometheus/prometheus-linux-amd64-nightly.tar.gz
tar -xzf prometheus-linux-amd64-nightly.tar.gz
cd prometheus-*
cat <<'EOF' > prometheus.yml
global:
  scrape_interval: 10s
  evaluation_interval: 10s
scrape_configs:
  - job_name: 'snmp'
    metrics_path: /snmp
    params:
      module: [default]
    static_configs:
      - targets:
        - 192.168.1.2  # SNMP device - add your IPs here
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 127.0.0.1:9116  # SNMP exporter.
EOF
./prometheus &
If you wait a bit for some scrapes to happen, you can then visit http://localhost:9090/consoles/snmp.html to see interface statistics.
 
The SNMP exporter was deployed at FOSDEM last weekend, and we were able to produce a variety of useful dashboards in Grafanacovering things like bandwidth and WiFi usage.
 
ESSID usage during FOSDEM
  prometheus, snmp 



