https://github.com/tesir/dubbo-admin-api

dubbo-admin-api

dubbo-admin前后台分离，对外提供REST API，供前台调用。

目前提供3个接口： 1、获取服务列表 GET /services/summary 返回消息： [ { "serviceName": "com.mor.server.dubbo.service.DemoServer", "providersNum": 3, "appName": "hello-world-app", "consumersNum": 0 }, { "serviceName": "com.alibaba.dubbo.monitor.MonitorService", "providersNum": 1, "appName": "simple-monitor", "consumersNum": 0 } ]

2、获取指定服务详情 GET /services/{service}

返回消息： { "consumers": [ { "address": "10.254.1.154", "application": "consumer-of-helloworld-app", "statistics": null, "collected": null, "expired": null, "alived": 0 }, { "address": "10.254.1.158", "application": "consumer-of-helloworld-app", "statistics": null, "collected": null, "expired": null, "alived": 0 } ], "methods": [ "sayHello" ], "providers": [ { "address": "10.51.29.174:61075", "dynamic": true, "enabled": true, "weight": 100, "application": "hello-world-app", "expired": null, "alived": 0 }, { "address": "10.51.29.174:61074", "dynamic": true, "enabled": true, "weight": 100, "application": "hello-world-app", "expired": null, "alived": 0 }, { "address": "10.51.29.174:61076", "dynamic": true, "enabled": true, "weight": 100, "application": "hello-world-app", "expired": null, "alived": 0 } ], "serviceName": "com.mor.server.dubbo.service.DemoServer" }

如果服务不存在，返回错误信息： { "code": "NOT_FOUND", "errMsg": "Services not exist!" }

3、获取总体统计信息 GET /stat/total { "serviceTotalNum": 2, "providerTotalNum": 4, "consumerTotalNum": 5, "appTotalNum": 3 }