

# https://docs.docker.com/engine/admin/logging/fluentd/#tag

Before using this logging driver, launch a Fluentd daemon. The logging driver connects to this daemon through localhost:24224 by default. Use the fluentd-address option to connect to a different address.

docker run --log-driver=fluentd --log-opt fluentd-address=fluentdhost:24224
If container cannot connect to the Fluentd daemon, the container stops immediately unless the fluentd-async-connect option is used.

# https://www.v2ex.com/t/327855
另外默认模式下如果你配置得地址没有正常服务，容器无法启动。你也可以使用fluentd-async-connect形式启动， docker daemon 则能在后台尝试连接并缓存日志。