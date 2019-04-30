


Query


curl -XPOST localhost:9966/graph/history



curl -XPOST localhost:9966/graph/history -H "Content-Type: application/json" -d '{
        "start": 1470900343,
  "end": 1470910343,
        "cf": "AVERAGE",
        "endpoint_counters": [
            {
                "endpoint": "192.168.1.82",
                "counter": "container.cpu.usage.busy/id=9406e2933cfaed3dabbe456dc124e90e3664634080a5d83537c32c2054bc3553"
            },
          {
                "endpoint" : "192.168.1.82",
"counter" : "container.cpu.usage.system/id=9406e2933cfaed3dabbe456dc124e90e3664634080a5d83537c32c2054bc3553"
            },
          {
                "endpoint" : "192.168.1.82",
"counter" : "container.cpu.usage.user/id=9406e2933cfaed3dabbe456dc124e90e3664634080a5d83537c32c2054bc3553"
            },
          {
                "endpoint" : "192.168.1.82",
"counter" : "container.net.if.out.bytes/id=77a83fd61450923d2266fd3807d1796ef261027d3420623fea8d39a8ac74130d"
            }
        ]
}
'| python -m json.tool



查询单个graph

graph_http.go

http.HandleFunc("/graph/history", func(w http.ResponseWriter, r *http.Request) {

result, err := graph.QueryOne(request)


容器监控项

 

graph/graph.go 调用rrd查询Graph.Query

rpc调用获取结果
err := rpcConn.Call("Graph.Query", para, resp)





counter/all

http://192.168.1.135:9966/counter/all

graph/info

http://192.168.1.135:9966/graph/info

[{"endpoint": "192.168.1.82","counter": "container.cpu.usage.busy/id=9406e2933cfaed3dabbe456dc124e90e3664634080a5d83537c32c2054bc3553"}]

[
    {
        "endpoint": "192.168.1.82",
        "counter": "container.cpu.usage.busy/id=9406e2933cfaed3dabbe456dc124e90e3664634080a5d83537c32c2054bc3553",
        "consolFun": "GAUGE",
        "step": 60,
        "filename": "/opt/install-alarm/data/graph/6070/19/1928daf1972cf57aecb2584ae05a61da_GAUGE_60.rrd",
        "addr": "127.0.0.1:6070"
    }
]


graph/last根据cpu.usage.busy获取容器数据

http://192.168.0.179:9966/graph/last
[{
	"endpoint": "192.168.0.184",
	"counter": "container.cpu.usage.busy/id=ef86a87f89631c4b3766c8ab9ae84f10a7600146eea82177c61819f378b0fd28"}
]
[
    {
        "endpoint": "192.168.0.184",
        "counter": "container.cpu.usage.busy/id=ef86a87f89631c4b3766c8ab9ae84f10a7600146eea82177c61819f378b0fd28",
        "value": {
            "timestamp": 1473049260,
            "value": 0.054944
        }
    }
]


graph/last获取容器数据例子

http://192.168.1.135:9966/graph/last
[{"endpoint": "192.168.1.82","counter": "container.cpu.usage.busy/id=9406e2933cfaed3dabbe456dc124e90e3664634080a5d83537c32c2054bc3553"}]
[
    {
        "endpoint": "192.168.1.82",
        "counter": "container.cpu.usage.busy/id=9406e2933cfaed3dabbe456dc124e90e3664634080a5d83537c32c2054bc3553",
        "value": {
            "timestamp": 1470903120,
            "value": 0.044965
        }
    }
]

http://192.168.0.179:9966/graph/last
[{"endpoint": "192.168.0.184","counter": "container.cpu.usage.busy/id=9994e186bfe4fc715d9478dbb5eed252754c8f14c65dcc0ca3533a6471b55702"}]


graph/last/raw

http://192.168.1.135:9966/graph/last/raw
[{"endpoint": "192.168.1.82","counter": "container.cpu.usage.busy/id=9406e2933cfaed3dabbe456dc124e90e3664634080a5d83537c32c2054bc3553"}]

[
    {
        "endpoint": "192.168.1.82",
        "counter": "container.cpu.usage.busy/id=9406e2933cfaed3dabbe456dc124e90e3664634080a5d83537c32c2054bc3553",
        "value": {
            "timestamp": 1470903060,
            "value": 0
        }
    }
]

graph/history

http://192.168.1.135:9966/graph/history

{
        "start": 1470900343,
  		"end": 1470910343,
        "cf": "AVERAGE",
        "endpoint_counters": [
            {
                "endpoint": "192.168.1.82",
                "counter": "container.cpu.usage.busy/id=9406e2933cfaed3dabbe456dc124e90e3664634080a5d83537c32c2054bc3553"
            },
          {
                "endpoint" : "192.168.1.82",
			"counter" : "container.cpu.usage.system/id=9406e2933cfaed3dabbe456dc124e90e3664634080a5d83537c32c2054bc3553"
            },
          {
                "endpoint" : "192.168.1.82",
			"counter" : "container.cpu.usage.user/id=9406e2933cfaed3dabbe456dc124e90e3664634080a5d83537c32c2054bc3553"
            },
          {
                "endpoint" : "192.168.1.82",
			"counter" : "container.net.if.out.bytes/id=77a83fd61450923d2266fd3807d1796ef261027d3420623fea8d39a8ac74130d"
            }
        ]
}

/graph/history


df.bytes.free.percent/fstype=ext4,mount=/boot

df.bytes.free.percent/fstype=ext4,mount=/boot


curl -XPOST localhost:9966/graph/history -d '{
        "start": 1484622700,
		"end":1484623700,
        "cf": "AVERAGE",
        "endpoint_counters": [
            {
                "endpoint": "192.168.110.115",
				"counter":	"df.bytes.free.percent/fstype=ext4,mount=/boot"
            }
        ]
}
'| python -m json.tool

df.bytes.free.percent/fstype=ext4,mount=/

curl -XPOST localhost:9966/graph/history -d '{
        "start": 1484622700,
		"end":1484623700,
        "cf": "AVERAGE",
        "endpoint_counters": [
            {
                "endpoint": "192.168.110.115",
				"counter":	"df.bytes.free.percent/fstype=ext4,mount=/"
            }
        ]
}
'| python -m json.tool





/graph/history/accurate
E:\workspace\yh\OpenBridge-passos-proxy\open-faclon\src\query\http\graph_http.go



Bug graph/history有值，graph/history/accurate无值



curl -XPOST localhost:9966/graph/history -d '{
        "start": 1484622700,
		"end":1484625127,
        "cf": "AVERAGE",
		"step": 60,
        "endpoint_counters": [
            {
                "endpoint": "192.168.110.115",
				"counter":	"df.bytes.free.percent/fstype=ext4,mount=/boot"
            }
        ]
}
'| python -m json.tool
 


curl -XPOST localhost:9966/graph/history/accurate -d '{
        "start": 1484622700,
		"end":1484625127,
        "cf": "AVERAGE",
		"step": 60,
        "endpoint_counters": [
            {
                "endpoint": "192.168.110.115",
				"counter":	"df.bytes.free.percent/fstype=ext4,mount=/boot"
            }
        ]
}
'| python -m json.tool
 


df.bytes.free.percent/fstype=ext4,mount=/boot

curl -XPOST localhost:9966/graph/history/accurate -d '{
        "start": 1484622700,
		"end":1484625228,
        "cf": "AVERAGE",
		"step": 60,
        "endpoint_counters": [
            {
                "endpoint": "192.168.110.115",
				"counter":	"df.bytes.free.percent/fstype=ext4,mount=/boot"
            }
        ]
}
'| python -m json.tool



curl -XPOST localhost:9966/graph/history/accurate -d '{
        "start": 1484622700,
		"end":1484625127,
        "cf": "AVERAGE",
		"step": 60,
        "endpoint_counters": [
            {
                "endpoint": "192.168.110.115",
				"counter":	"df.bytes.free.percent/fstype=ext4,mount=/boot"
            }
        ]
}
'| python -m json.tool

AccurateQueryOne
E:\workspace\yh\OpenBridge-passos-proxy\open-faclon\src\query\graph\graph.go







