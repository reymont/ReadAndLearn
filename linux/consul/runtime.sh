curl -i -XPOST http://localhost:8080/v1/services -H "Content-Type: application/json" -d '{
  "ID":  "fool",
  "Service": "fool"
  "Name": "foo1",
  "Port": "8123",
  "Address": "192.168.0.42"
  "EnableTagOverride": true
}'

curl -XPOST localhost:8080/v1/services -v -d '{"Name": "foo1","Port": "8000","Address": "192.168.0.42"}'

curl -XGET localhost:8080/v1/global?key=runtime/config/dns-server
curl -X POST localhost:8080/v1/global/dns -v -d "{\"Messages\": [\"192.168.0\", \"that\"]}"

{"Messages": ["192.168.0.191", "114.114.114.114"]}