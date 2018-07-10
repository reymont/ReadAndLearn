#alertmanager
docker pull quay.io/prometheus/alertmanager
docker run -d --restart=always -p 9093:9093 --name=am prom/alertmanager
docker run -d --restart=always -p 9093:9093 --name=am -v /prometheus-data/alertmanager.conf:/alertmanager.conf prom/alertmanager -config.file=/alertmanager.conf