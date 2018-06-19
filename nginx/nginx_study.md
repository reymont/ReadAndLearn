# config

*   [Nginx启用, 停止, 平滑重启命令 - 老鹰之歌的学习笔记 - 博客频道 - CSDN.NET](http://blog.csdn.net/black_ox/article/details/18737077)

        /usr/nginx/sbin/nginx -t
        kill -HUP 住进称号或进程号文件路径  
        /usr/nginx/sbin/nginx -s reload

    [](http://blog.csdn.net/black_ox/article/details/18737077)
*   [nginx配置url重定向-反向代理 - 大風 - 51CTO技术博客](http://lansgg.blog.51cto.com/5675165/1575274)
*   [nginx proxy_pass后的url加不加/的区别 - 竹阴下 - 51CTO技术博客](http://ftlynx.blog.51cto.com/2833447/839607)
*   [Nginx配置proxy_pass转发的/路径问题 - 孤剑 - 博客园](http://www.cnblogs.com/AloneSword/p/3673829.html)
*   [nginx配置中proxy_redirect的作用(转) - bluedest - ITeye技术网站](http://bluedest.iteye.com/blog/740302)
*   [nginx documentation](http://nginx.org/en/docs/)
*   [Nginx开发从入门到精通 — Nginx开发从入门到精通](http://tengine.taobao.org/book/index.html)
*   [nginx服务器安装及配置文件详解 - Sean's Notes - SegmentFault](https://segmentfault.com/a/1190000002797601) （详细介绍全局配置main, http）
*   [nginx的log、upstream和server - GITTODO](https://my.oschina.net/u/2246410/blog/618798) （全面的nginx参数）
*   [关于Nginx的server_name。 - 相濡以沫 - 51CTO技术博客](http://onlyzq.blog.51cto.com/1228/535279)

# 原理

*   [Nginx 工作原理和优化、漏洞（上）](https://mp.weixin.qq.com/s/0SgVX72C6SQeomzUtYG9sw)
*   [Nginx 工作原理和优化、漏洞（下）](https://mp.weixin.qq.com/s/Binm-lvaBUybEWZCScF7Kg)
*   [Nginx源码分析：3张图看懂启动及进程工作原理](https://mp.weixin.qq.com/s/n-tVjv8sJBNVouqiOh7Nqw)
*   [资源汇集：nginx教程从入门到精通-软件 ◆ 分享|Linux.中国-开源社区](https://linux.cn/article-4279-weixin.html)
*   [Nginx – 运维生存时间](http://www.ttlsa.com/nginx/)

# 时间

*   [如何挖掘Nginx日志中隐藏的金矿？](https://mp.weixin.qq.com/s/2H_MdOCEhkqaqt7P8oKlhA)
*   [aqingsao/nana](https://github.com/aqingsao/nana): A lightweight Nginx log analyzer written in shell(statistics of traffic/rate/response time/upstream servers/spiders/response codes)
*   [Nginx 日志分析及性能排查](http://mp.weixin.qq.com/s/A1ufVgi3VFuSGRh4Ju5puA)
*   [nginx日志如何正确显示整个http请求的服务端处理时间？ - zhouzhe8013的回答 - SegmentFault](https://segmentfault.com/q/1010000004034343/a-1020000004036067) （$request_time：从接受用户请求的第一个字节到发送完响应数据的时间，即包括接收请求数据时间、程序响应时间、输出响应数据时间。$upstream_response_time指从Nginx向后端建立连接开始到接受完数据然后关闭连接为止的时间。）
*   [nginx日志如何正确显示整个http请求的服务端处理时间？ - 知乎](https://www.zhihu.com/question/37801925)
*   [nginx的请求处理阶段 (90%) — Nginx开发从入门到精通](http://tengine.taobao.org/book/chapter_12.html)
*   [nginx运维小纪 // 灰主流创业者](https://bhsc881114.github.io/2015/07/18/nginx%E8%BF%90%E7%BB%B4%E5%B0%8F%E7%BA%AA/)

# log

*   [为什么，nginx的log被自动压缩？ - 开源中国社区](https://www.oschina.net/question/948305_136423) （/etc/logrotate.d/nginx）

        /var/log/nginx/*.log {
                daily
                missingok
                rotate 52
                compress
                delaycompress
                notifempty
                create 666 nginx adm
                sharedscripts
                postrotate
                        if [ -f /var/run/nginx.pid ]; then
                                kill -USR1 `cat /var/run/nginx.pid`
                        fi
                endscript
        }
        #配置日志权限，用户和组
        create 666 nginx adm

*   [nginx日志配置 – 运维生存时间](http://www.ttlsa.com/linux/the-nginx-log-configuration/)

# proxy

*   [nginx做负载均衡器以及proxy缓存配置 - Sean's Notes - SegmentFault](https://segmentfault.com/a/1190000002873747)

# sub_filter

*   [Nginx HttpSubModule sub_filter模块的过滤功能 - archoncap - 博客园](http://www.cnblogs.com/archoncap/p/4956456.html)

# upstream

*   [Nginx配置upstream实现负载均衡_服务器应用_Linux公社-Linux系统门户网站](http://www.linuxidc.com/Linux/2015-03/115207.htm)