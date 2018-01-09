http://192.168.31.212:9090/api/v1/targets
#获取所有的alert
http://192.168.31.212:9090/api/v1/alertmanagers
#获取label的值
http://192.168.31.212:9090/api/v1/label/instance/values
http://192.168.31.212:9090/api/v1/label/alertname/values
http://192.168.31.212:9090/api/v1/label/job/values
#获取label为id的值，包括docker id等
http://192.168.31.212:9090/api/v1/label/id/values