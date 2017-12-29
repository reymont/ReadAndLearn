

# https://github.com/reymont/fluentd2kibana

curl 127.0.0.1:3000
curl -XPOST 127.0.0.1:3000

curl localhost:9200/_cat/indices

curl -s 192.168.99.100:9200/_cat/indices
curl -s 192.168.99.100:9200/_search?pretty
curl -s 192.168.99.100:9200/.kibana/_search?pretty



```yml
{
	searchSourceJSON: {
		index: AWB8YHeaWrkYh5m47SqW,
		highlightAll: true,
		version: true,
		query: {
			match_all: {}
		},
		filter: [{
				$state: {
					store: appState
				},
				meta: {
					alias: 172.20.62.105,
					disabled: false,
					index: AWB8YHeaWrkYh5m47SqW,
					key: hostname,
					negate: false,
					type: phrase,
					value: 172.20.62.105
				},
				query: {
					match: {
						hostname: {
							query: 172.20.62.105,
							type: phrase
						}
					}
				}
			}, {
				meta: {
					index: AWB8YHeaWrkYh5m47SqW,
					negate: false,
					disabled: true,
					alias: business - adapter,
					type: phrase,
					key: micro_service,
					value: business - adapter
				},
				query: {
					match: {
						micro_service: {
							query: business - adapter,
							type: phrase
						}
					}
				},
				$state: {
					store: appState
				}
			}, {
				meta: {
					index: AWB8YHeaWrkYh5m47SqW,
					negate: false,
					disabled: true,
					alias: boss - callback,
					type: phrase,
					key: micro_service,
					value: boss - callback
				},
				query: {
					match: {
						micro_service: {
							query: boss - callback,
							type: phrase
						}
					}
				},
				$state: {
					store: appState
				}
			}, {
				meta: {
					index: AWB8YHeaWrkYh5m47SqW,
					negate: false,
					disabled: true,
					alias: business - lifeservice,
					type: phrase,
					key: micro_service,
					value: business - lifeservice
				},
				query: {
					match: {
						micro_service: {
							query: business - lifeservice,
							type: phrase
						}
					}
				},
				$state: {
					store: appState
				}
			}
		]
	}
}
```

```json
      {
        "_index" : ".kibana",
        "_type" : "search",
        "_id" : "AWCcB0QVnt-AeEgKJbIJ",
        "_score" : 1.0,
        "_source" : {
          "title" : "172.20.62.115",
          "description" : "",
          "hits" : 0,
          "columns" : [
            "msg"
          ],
          "sort" : [
            "@timestamp",
            "desc"
          ],
          "version" : 1,
          "kibanaSavedObjectMeta" : {
            "searchSourceJSON" : "{\"index\":\"AWB8YHeaWrkYh5m47SqW\",\"highlightAll\":true,\"version\":true,\"query\":{\"match_all\":{}},\"filter\":[{\"meta\":{\"index\":\"AWB8YHeaWrkYh5m47SqW\",\"negate\":false,\"disabled\":false,\"alias\":\"172.20.62.115\",\"type\":\"phrase\",\"key\":\"hostname\",\"value\":\"172.20.62.115\"},\"query\":{\"match\":{\"hostname\":{\"query\":\"172.20.62.115\",\"type\":\"phrase\"}}},\"$state\":{\"store\":\"appState\"}},{\"meta\":{\"index\":\"AWB8YHeaWrkYh5m47SqW\",\"negate\":false,\"disabled\":true,\"alias\":\"poi-service\",\"type\":\"phrase\",\"key\":\"micro_service\",\"value\":\"poi-service\"},\"query\":{\"match\":{\"micro_service\":{\"query\":\"poi-service\",\"type\":\"phrase\"}}},\"$state\":{\"store\":\"appState\"}},{\"meta\":{\"index\":\"AWB8YHeaWrkYh5m47SqW\",\"negate\":false,\"disabled\":true,\"alias\":\"voip-service\",\"type\":\"phrase\",\"key\":\"micro_service\",\"value\":\"voip-service\"},\"query\":{\"match\":{\"micro_service\":{\"query\":\"voip-service\",\"type\":\"phrase\"}}},\"$state\":{\"store\":\"appState\"}}]}"
          }
        }
      }

      {
        "_index" : ".kibana",
        "_type" : "search",
        "_id" : "AWCcB0QVnt-AeEgKJbIJ",
        "_score" : 1.0,
        "_source" : {
          "title" : "172.20.62.115",
          "description" : "",
          "hits" : 0,
          "columns" : [
            "msg"
          ],
          "sort" : [
            "@timestamp",
            "desc"
          ],
          "version" : 1,
          "kibanaSavedObjectMeta" : {
            "searchSourceJSON" : "{\"index\":\"AWB8YHeaWrkYh5m47SqW\",\"highlightAll\":true,\"version\":true,\"query\":{\"match_all\":{}},\"filter\":[{\"meta\":{\"index\":\"AWB8YHeaWrkYh5m47SqW\",\"negate\":false,\"disabled\":false,\"alias\":\"172.20.62.115\",\"type\":\"phrase\",\"key\":\"hostname\",\"value\":\"172.20.62.115\"},\"query\":{\"match\":{\"hostname\":{\"query\":\"172.20.62.115\",\"type\":\"phrase\"}}},\"$state\":{\"store\":\"appState\"}},{\"meta\":{\"index\":\"AWB8YHeaWrkYh5m47SqW\",\"negate\":false,\"disabled\":true,\"alias\":\"poi-service\",\"type\":\"phrase\",\"key\":\"micro_service\",\"value\":\"poi-service\"},\"query\":{\"match\":{\"micro_service\":{\"query\":\"poi-service\",\"type\":\"phrase\"}}},\"$state\":{\"store\":\"appState\"}},{\"meta\":{\"index\":\"AWB8YHeaWrkYh5m47SqW\",\"negate\":false,\"disabled\":true,\"alias\":\"voip-service\",\"type\":\"phrase\",\"key\":\"micro_service\",\"value\":\"voip-service\"},\"query\":{\"match\":{\"micro_service\":{\"query\":\"voip-service\",\"type\":\"phrase\"}}},\"$state\":{\"store\":\"appState\"}}]}"
          }
        }
      },
```