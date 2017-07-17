const elasticsearch = require('elasticsearch');
const esClient = new elasticsearch.Client({
    host: '192.168.31.215:9200',
    log: 'error'
});

const search = function search(index, body) {
    return esClient.search({
        index: index,
        body: body
    });
};

let body = {
    "query": {
        "bool": {
            "filter": [{
                "range": {
                    "@timestamp": {
                        "from": "1499483992610",
                        "to": "1499583992610",
                        "include_lower": true,
                        "include_upper": true
                    }
                }
            }]
        }
    },
    "aggs": {
        "methodCount": {
            "terms": {
                "field": "uri.keyword",
                "size": 7,
                "order": [{
                        "_count": "desc"
                    },
                    {
                        "_term": "asc"
                    }
                ]
            },
            "aggregations": {
                "sum_request_time": {
                    "sum": {
                        "field": "request_time"
                    }
                }
            }
        }
    }
};

search('logstash-*', body).then(results => {
      console.log(`found ${results.hits.total} items in ${results.took}ms`);
      if (results.hits.total > 0) console.log(`returned article titles:`);
      results.hits.hits.forEach((hit, index) => console.log(`\t${++index} - ${hit._source.remote_addr} (score: ${hit._score})`));
      console.log(JSON.stringify(results, null, 4));
      console.log(`aggregations values.`);
      debugger
      results.aggregations.methodCount.buckets.forEach((hit, index) => console.log(`\t${++index} - ${hit.key} - ${hit.doc_count} `));
      console.log(new Date().getTime())
    })
    .catch(console.error);