http://127.0.0.1:8080/api/v1/elk/request?start=1499657230262&apiPrefix=/api/v1&serverName=k8s.cloudos.yihecloud.com
#调用状态：200/400等，饼图
http://127.0.0.1:8080/api/v1/elk/status?start=1499657230262

http://127.0.0.1:8080/api/v1/elk/detail?start=1499657230262
#添加状态
http://127.0.0.1:8080/api/v1/elk/detail?start=1499657230262&status=400
#状态范围
http://127.0.0.1:8080/api/v1/elk/detail?start=1499657230262&statusStart=400&statusEnd=400
