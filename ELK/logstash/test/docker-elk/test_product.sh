curl -XPUT "http://192.168.31.215:9200/test_index/product/1" -d '{
  "title": "Product1",
  "description": "Product1 Description",
  "price": 100
}'

curl -XPUT "http://192.168.31.215:9200/test_index/product/2" -d '{
  "title": "Product2",
  "description": "Product2 Description",
  "price": 200
}'

curl -XGET 192.168.31.215:9200/test_index/product/1