

# logging - Monitoring log files using some metrics exporter + Prometheus + Grafana - Stack Overflow 
http://stackoverflow.com/questions/41160883/monitoring-log-files-using-some-metrics-exporter-prometheus-grafana



I need to monitor very different log files for errors, success status etc. And I need to grab corresponding metrics using Prometheus and show in Grafana + set some alerting on it. Prometheus + Grafana are OK I already use them a lot with different exporters like node_exporter or mysql_exporter etc. Also alerting in new Grafana 4.x works very well.
But I have quite a problem to find suitable exporter/ program which could analyze log files "on fly" and extract metrics from them.
So far I tried:
•	mtail (https://github.com/google/mtail) - works but existing version cannot easily monitor more files - in general it cannot bind specific mtail program (receipt for analysis) to some specific log file + I cannot easily add log file name into tag
•	grok_exporter (https://github.com/fstab/grok_exporter) - works but I can extract only limited information + one instance can monitor only one log file which mean I would have to start more instances exporting on more ports and configure all off them in prometheus - which makes too many new points of failure
•	fluentd prometheus exporter (https://github.com/kazegusuri/fluent-plugin-prometheus) - works but looks like I can extract only very simple metrics and I cannot make any advanced regexp analysis of a line(s) from log file
Does any one here has a really running solution for monitoring advanced metrics from log files using "some exporter" + Prometheus + Grafana? Or instead of exporter some program from which I could grab results using Prometheus push gateway. Thanks.


