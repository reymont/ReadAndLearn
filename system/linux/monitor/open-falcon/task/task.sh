#索引数据的全量更新
curl -s "127.0.0.1:6071/index/updateAll"
#待索引全量更新完成后，发起过期索引删除
curl -s "127.0.0.1:8002/index/delete"