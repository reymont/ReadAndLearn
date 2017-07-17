var ejs = require('ejs'),
    people = ['geddy', 'neil', 'alex'],
    html = ejs.render('<%= people.join(", "); %>', {people: people});

var users = ['geddy', 'neil', 'alex'];
// Just one template
html2 = ejs.render('<?= users.join(" | "); ?>', {users: users},
    {delimiter: '?'});
// => 'geddy | neil | alex'

// Or globally
ejs.delimiter = '$';
html3 = ejs.render('<$= users.join(" | "); $>', {users: users});
// => 'geddy | neil | alex'

console.log(html);
console.log(html2);
console.log(html3);

var elk = {
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
                "result_agg": {
                    "date_histogram": {
                        "field": "@timestamp",
                        "interval": "day",
                        "min_doc_count": 0,
                        "extended_bounds": {
                            "min": "1499483992610",
                            "max": "1499583992610"
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
                }
            }
        }

elk.query.test = {
                                "key": "success",
                                "from": 200.0,
                                "to": 300.0
                            }

console.log(elk.aggs);
console.log(elk.query);