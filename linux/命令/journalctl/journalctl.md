

* [通过journalctl查找事件 - zhg1016 - 博客园 ](http://www.cnblogs.com/zhg1016/articles/5503788.html)
* [journalctl 中文手册 [金步国] ](http://www.jinbuguo.com/systemd/journalctl.html)


```bash
journalctl -xe
#-e, --pager-end
#在分页工具内立即跳转到日志的尾部。 此选项隐含了 -n1000 以确保分页工具不必缓存太多的日志行。 不过这个隐含的行数可以被明确设置的 -n 选项覆盖。 注意，此选项仅可用于 less(1) 分页器。
#-x, --catalog
#在日志的输出中增加一些解释性的短文本， 以帮助进一步说明日志的含义、 问题的解决方案、支持论坛、 开发文档、以及其他任何内容。 并非所有日志都有这些额外的帮助文本， 详见 Message Catalog Developer Documentation 文档。

注意，如果要将日志输出用于bug报告， 请不要使用此选项。
```

```sh
#不带任何选项与参数，表示显示全部日志
journalctl
#仅指定一个匹配条件， 显示所有符合该匹配条件的日志
journalctl _SYSTEMD_UNIT=avahi-daemon.service
#指定了两个不同字段的匹配条件， 显示同时满足两个匹配条件的日志
journalctl _SYSTEMD_UNIT=avahi-daemon.service _PID=28097
#指定了同一个字段的两个不同匹配条件， 显示满足其中任意一个条件的日志
journalctl _SYSTEMD_UNIT=avahi-daemon.service _SYSTEMD_UNIT=dbus.service
#使用 "+" 连接两组匹配条件， 相当于逻辑"OR"连接
journalctl _SYSTEMD_UNIT=avahi-daemon.service _PID=28097 + _SYSTEMD_UNIT=dbus.service
#显示所有 D-Bus 进程产生的日志
journalctl /usr/bin/dbus-daemon
#显示上一次启动所产生的所有内核日志
journalctl -k -b -1
#持续显示 apache.service 服务不断生成的日志
journalctl -f -u apache
```

# --no-pager

不想分页输出，那么可以使用 --no-pager 选项

* [journalctl 中文手册 - 喵喵喵喵喵！ - 博客园 ](http://www.cnblogs.com/zhangzeyu/p/6539227.html)
