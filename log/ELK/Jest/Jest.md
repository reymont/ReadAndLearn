

# searchbox-io/Jest: Elasticsearch Java Rest Client. 
https://github.com/searchbox-io/Jest

Jest is a Java HTTP Rest client for ElasticSearch.
ElasticSearch is an Open Source (Apache 2), Distributed, RESTful, Search Engine built on top of Apache Lucene.
ElasticSearch already has a Java API which is also used by ElasticSearch internally, but Jest fills a gap, it is the missing client for ElasticSearch Http Rest interface.
Read great introduction to ElasticSearch and Jest from IBM Developer works.
Documentation
For the usual Jest Java library, that you can use as a maven dependency, please refer to the README at jest module.
For the Android port please refer to the README at jest-droid module.
Compatibility
Jest Version	Elasticsearch Version
>= 2.0.0	2.0
0.1.0 - 1.0.0	1.0
<= 0.0.6	< 1.0
Also see changelog for detailed version history.
Support and Contribution
All questions, bug reports and feature requests are handled via the GitHub issue tracker which also acts as the knowledge base. Please see the Contribution Guidelines for more information.
Comparison to native API
There are several alternative clients available when working with ElasticSearch from Java, like Jest that provides a POJO marshalling mechanism on indexing and for the search results. In this example we are using the Client that is included in ElasticSearch. By default the client doesn't use the REST API but connects to the cluster as a normal node that just doesn't store any data. It knows about the state of the cluster and can route requests to the correct node but supposedly consumes more memory. For our application this doesn't make a huge difference but for production systems that's something to think about. -- Florian Hopf
So if you have several ES clusters running different versions, then using the native (or transport) client will be a problem, and you will need to go HTTP (and Jest is the main option I think). If versioning is not an issue, the native client will be your best option as it is cluster aware (thus knows how to route your queries and does not need another hop), and also moves some computation away from your ES cluster (like merging search results that will be done locally instead of on the data node). -- Rotem Hermon
ElasticSearch does not have Java rest client. It has only native client comes built in. That is the gap. You can add security layer to HTTP but native API. That is why none of SAAS offerings can be used with native api. -- Searchly
