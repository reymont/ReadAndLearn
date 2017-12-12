

docker-compose up -d
# inject some log entries
nc localhost 5000 < /path/to/logfile.log
# Run this command to create a Kibana index pattern:
curl -XPUT -D- 'http://localhost:9200/.kibana/doc/index-pattern:docker-elk' \
    -H 'Content-Type: application/json' \
    -d '{"type": "index-pattern", "index-pattern": {"title": "logstash-*", "timeFieldName": "@timestamp"}}'