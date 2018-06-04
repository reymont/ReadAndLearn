

# http://fluentbit.io/documentation/current/output/elasticsearch.html

fluent-bit -i cpu -t cpu -o es -p Host=172.20.62.42 -p Port=9200 \
    -p Index=my_index -p Type=my_type -o stdout -m '*'

# 健康检查
curl localhost:9200/_cluster/health?pretty
# 查看索引
curl localhost:9200/_cat/indices