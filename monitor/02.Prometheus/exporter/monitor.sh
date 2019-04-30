#Rest接口对应Swagger Specification路径
http://127.0.0.1:8080/monitor/swagger-resources
#根据location的值获取api   json描述文件
http://127.0.0.1:8080/monitor/swagger-apidocs?group=%E6%89%80%E6%9C%89
#swagger-ui
http://127.0.0.1:8080/monitor/swagger-ui.html

go run main.go -config-file=config.json

curl -X POST localhost:8080/config/ss.yml -v -d "{\"Messages\": [\"192.168.0\", \"that\"]}"
curl -X POST localhost:9091/config/config/ss.yml -v -d "{\"Messages\": [\"192.168.0\", \"that\"]}"
curl -X POST 192.168.31.212:9091/config/config/ss.yml -v -d "{\"Messages\": [\"192.168.0\", \"that\"]}"

curl -X POST localhost:8080/v1/mail -v -d '{
    "To":"liyang@yihecloud.com",
    "Subject":"test",
    "Body":"test"
}'

curl -XPOST localhost:8080/api/v1/alerts -v -d '[{"labels": {
            "ENGINE_SYSTEM_K8S_NODE_NAME": "192.168.31.222",
            "ENGINE_SYSTEM_NODE_PROXY": "sdfdsf",
            "alertname": "g1_s2",
            "beta_kubernetes_io_arch": "amd64",
            "beta_kubernetes_io_os": "linux",
            "id": "/system.slice",
            "instance": "192.168.31.222",
            "job": "k8s-10255",
            "kubernetes_io_hostname": "192.168.31.222"
        },
        "annotations": {
            "description": "This device mem usage has exceeded the threshold with a value of +Inf",
            "summary": "Instance 192.168.31.222 mem usage is dangerously high"
        },
        "startsAt": "2017-06-24T10:42:37.803+08:00",
        "endsAt": "0001-01-01T00:00:00Z",
        "generatorURL": "http://4d9fe20542fd:9090/graph?g0.expr=job%3Acontainer_mem_used%3As3\u0026g0.tab=0"
    }, {
        "labels": {
            "ENGINE_SYSTEM_K8S_NODE_NAME": "192.168.31.222",
            "ENGINE_SYSTEM_NODE_PROXY": "sdfdsf",
            "alertname": "g1_s2",
            "beta_kubernetes_io_arch": "amd64",
            "beta_kubernetes_io_os": "linux",
            "container_name": "POD",
            "id": "/kubepods/besteffort/pod4ccf54aa-4c13-11e7-9fb4-0050569e67f7/713b9216825456376a5ef1daf4481b499a2c730293f86b3c094543ff4e250357",
            "image": "gcr.us.iotsoft.net/google_containers/pause-amd64:3.0",
            "instance": "192.168.31.222",
            "job": "k8s-10255",
            "kubernetes_io_hostname": "192.168.31.222",
            "name": "k8s_POD_kube-proxy-dd844_kube-system_4ccf54aa-4c13-11e7-9fb4-0050569e67f7_1",
            "namespace": "kube-system",
            "pod_name": "kube-proxy-dd844"
        },
        "annotations": {
            "description": "This device mem usage has exceeded the threshold with a value of +Inf",
            "summary": "Instance 192.168.31.222 mem usage is dangerously high"
        },
        "startsAt": "2017-06-24T10:42:37.803+08:00",
        "endsAt": "0001-01-01T00:00:00Z",
        "generatorURL": "http://4d9fe20542fd:9090/graph?g0.expr=job%3Acontainer_mem_used%3As3\u0026g0.tab=0"
    }]'