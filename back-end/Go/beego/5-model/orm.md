

# https://beego.me/docs/mvc/model/orm.md

```sh
docker-machine start
eval $(docker-machine env)
docker pull mysql

# https://github.com/docker-library/mysql
# https://hub.docker.com/_/mysql/
docker run --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root -d mysql

# http://www.cnblogs.com/lwmp/p/6999742.html
winpty docker exec -it mysql sh 

# http://www.cnblogs.com/cnblogsfans/archive/2009/09/21/1570942.html
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

```go
orm.RegisterDataBase("default", "mysql", "root:root@tcp(192.168.99.100:3306)/f2k?charset=utf8")

// https://beego.me/docs/mvc/model/overview.md#简单示例
// create table
orm.RunSyncdb("default", false, true)
```