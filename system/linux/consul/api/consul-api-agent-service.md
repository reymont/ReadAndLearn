


* [Service - Agent - HTTP API - Consul by HashiCorp ](https://www.consul.io/api/agent/service.html)
* [使用consul实现服务的注册和发现 - 走马行酒醴，驱车布鱼肉 - CSDN博客 ](http://blog.csdn.net/mn960mn/article/details/51768678)

# 列表

```sh
$ curl \
    https://consul.rocks/v1/agent/services
http://192.168.0.140:8500/v1/agent/services
```

# 新增&覆盖

payload.json
```json
{
  "ID": "redis1",
  "Name": "redis",
  "Tags": [
    "primary",
    "v1"
  ],
  "Address": "127.0.0.1",
  "Port": 8000,
  "EnableTagOverride": false,
  "Check": {
    "DeregisterCriticalServiceAfter": "90m",
    "Script": "/usr/local/bin/check_redis.py",
    "HTTP": "http://localhost:5000/health",
    "Interval": "10s",
    "TTL": "15s"
  }
}
```

```sh
$ curl \
    --request PUT \
    --data @payload.json \
    https://consul.rocks/v1/agent/service/register
```


# 删除

```sh
$ curl \
    --request PUT \
    https://consul.rocks/v1/agent/service/deregister/my-service-id
curl -XPUT http://192.168.0.140:8500/v1/agent/service/deregister/svn
```