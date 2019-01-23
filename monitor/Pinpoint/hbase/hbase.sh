

### 1. 查看有哪些表
docker exec -it pinpoint-hbase bash
/opt/hbase/hbase-1.2.6/bin/hbase shell
list
scan 'SqlMetaData_Ver2',{LIMIT=>10}
### 2. hbase控制台
http://172.20.62.129:16010