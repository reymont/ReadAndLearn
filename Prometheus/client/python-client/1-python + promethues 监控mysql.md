python + promethues 监控mysql - 简书 https://www.jianshu.com/p/27b979554ef8

需求

今天写了个exporter监控下刚投入使用的mysql主从的主机。主要用到了python的flask和pymysql模块。

程序

引入模块。没有的需要自己pip安装

```py
# coding=utf-8
#author:OrangeLoveMlian
#!/bin/python
#coding=utf-8
import pymysql
import pymysql.cursors
import sys
import prometheus_client
from prometheus_client.core import CollectorRegistry
from prometheus_client import Gauge
from flask import Response,Flask
登陆mysql，写了一个探测函数，如果不能连接到mysql，返回0.说明mysql可能出现问题了。

###参数字典
config = {
    'host':'ip',
    'port':port,
    'user':'user',
    'password':'pwd',
    }

###获取连接状态

def connection_status():
    try:
        connection = pymysql.connect(**config)
        connection_status = 1
        return connection_status
        connection.close()
    except:
        connection_status = 0
        return connection_status
```

mysql的监控参数主要通过show status获得。利用pymysql执行sql语句。取到参数值，并转换成可读性高的字典

```py
###获取mysql的状态参数，返回元组.如果连接不上，获取的参数为0，程序退出
def getPara():
    i = connection_status()
    if i == 1:
        connection = pymysql.connect(**config)
        cursor = connection.cursor()
        sql = "show status"
        try:
            
            cursor.execute(sql)
            statusPara =  cursor.fetchall()
            return statusPara

        except Exception,e:
            return e
            print 'execute failed!'
            sys.exit()
    else:
        return 0
        print 'connection failed!'
        sys.exit()

###将获取的参数元组转换成可读性高的字典
def getMysqlStatusDic():

    tup = ()
    tup = getPara()
    tup = list(tup)
    for i in range(len(tup)):
        tup[i] = list(tup[i])
    statusDic = dict(tup)
    return statusDic
```

promethues使用pull的方式获取参数的。所以用flask起了一个接口，返回gauge参数。抓取了一些自己认为重要的参数，有待完善。

```py
###起个flask接口,返回mysql的状态参数查询
app = Flask(__name__)
REGISTRY = CollectorRegistry(auto_describe=False)
##注册的值
mysqlConnect = Gauge("mysqlConnect","Value is:",registry=REGISTRY)
mysqlUptime = Gauge("mysqlUptime","Value is:",registry=REGISTRY)
mysqlSlow_queries = Gauge("mysqlSlow_queries","Value is:",registry=REGISTRY)
mysqlThreads_connected = Gauge("mysqlThreads_connected","Value is:",registry=REGISTRY)
mysqlThreads_running = Gauge("mysqlThreads_running","Value is:",registry=REGISTRY)
mysqlConnection_errors_internal = Gauge("mysqlConnection_errors_internal","Value is:",registry=REGISTRY)
mysqlAborted_connects = Gauge("mysqlAborted_connects","Value is:",registry=REGISTRY)
mysqlInnodb_buffer_pool_pages_data = Gauge("mysqlInnodb_buffer_pool_pages_data","Value is:",registry=REGISTRY)
@app.route("/metrics")
def mysqlStatus():
    MS = getMysqlStatusDic()
    ###mysql是否可以连接
    
    mysqlConnect.set(connection_status())
    
    ###mysql启动时间
    
    mysqlUptime.set(MS['Uptime'])
    
    ###慢查询的个数
        
    mysqlSlow_queries.set(MS['Slow_queries'])

    #连接
    ###客户端连接数，当前开放的连接
        
    mysqlThreads_connected.set(MS['Threads_connected'])
    ###当前运行的连接
        
    mysqlThreads_running.set(MS['Threads_running'])
    ###服务器醋无导致的失败的连接数
        
    mysqlConnection_errors_internal.set(MS['Connection_errors_internal'])
    ###尝试与服务器连接失败的个数
        
    mysqlAborted_connects.set(MS['Aborted_connects'])

    #缓冲池使用情况
    ###缓冲池中的总页数
    
    mysqlInnodb_buffer_pool_pages_data.set(MS['Innodb_buffer_pool_pages_data'])
    ###资源池无法满足的请求
        
    mysqlInnodb_buffer_pool_reads.set(MS['Innodb_buffer_pool_reads'])

    return Response(prometheus_client.generate_latest(REGISTRY),mimetype="text/plain")
    

if __name__ == "__main__":
    app.run(host='0.0.0.0',port=3534)
```

利用grafana展示抓取到的数据，并设置告警


grafana展示
小礼物走一走，来简书关注我

作者：OrangeLoveMilan
链接：https://www.jianshu.com/p/27b979554ef8
來源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。