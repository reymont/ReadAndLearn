

# http://www.imekaku.com/2016/09/19/docker-log-driver-buff-fluentd-buff/

Docker使用log-driver收集日志，会有一个buff，如果在运行docker容器的机器上的fluentd程序挂了，那么日志就会打在这个缓冲区中，官网说明。
客户端fluentd向服务器fluentd转发日志的时候，也会有一个buff，如果服务器fluentd挂了，那么日志就会暂留在这个缓冲区中，官网说明。
Docker-log-driver发送到Fluentd缓冲区

docker log-driver支持下列选项
fluentd-buffer-limit: specify the maximum size of the fluentd log buffer [8MB]
fluentd-retry-wait: initial delay before a connection retry (after which it increases exponentially) [1000ms]
fluentd-max-retries: maximum number of connection retries before abrupt failure of docker [1073741824]
fluentd-async-connect: whether to block on initial connection or not [false]
fluentd-buffer-limit选项默认是8M，如果在fluentd挂了之后，docker容器也一直往fluentd打日志，

如果日志超过了8M，是否会影响容器的运行？

我没有在官网找到相关说明，但是我测试之后，是不会影响容器运行的，但是期间的日志会被覆盖掉。

Fluentd Buffer Structure

缓冲区的结构如下:

Shell

queue
+---------+
|         |
|  chunk <-- write events to the top chunk
|         |
|  chunk  |
|         |
|  chunk  |
|         |
|  chunk --> write out the bottom chunk
|         |
+---------+

queue
+---------+
|         |
|  chunk <-- write events to the top chunk
|         |
|  chunk  |
|         |
|  chunk  |
|         |
|  chunk --> write out the bottom chunk
|         |
+---------+
When the top chunk exceeds the specified size or time limit (buffer_chunk_limit and flush_interval, respectively), a new empty chunk is pushed to the top of the queue. The bottom chunk is written out immediately when new chunk is pushed.
If the bottom chunk write out fails, it will remain in the queue and Fluentd will retry after waiting several seconds (retry_wait). If the retry limit has not been disabled (disable_retry_limit is false) and the retry count exceeds the specified limit (retry_limit), the chunk is trashed. The retry wait time doubles each time (1.0sec, 2.0sec, 4.0sec, …) until max_retry_wait is reached. If the queue length exceeds the specified limit (buffer_queue_limit), new events are rejected.
粗略翻译：
当chunk到达指定的大小或者时间限制是(两个限制符：buffer_chunk_limit或者flush_interval )，新的chunk将被放进队列的顶部，此时底部的chunk会被立即输出。
如果底部的chunk输出失败，那么它将会保留在队列中，并且fluentd会在几秒钟之后(即字段：retry_wait)，尝试重连。
如果尝试重连不是disable（即：diable_retry_limit是false），并且重连的次数达到指定的限制次数(retry_limit字段)，那么这个chunk被销毁。重连的时间是翻倍的增长的(1s，2s，4s…)直到到达max_retry_wait。
如果队列的长度达到指定的长度buffer_queue_limit，新的事件将会被拒绝。
支持参数：

Shell

<match pattern>
  # omit the part about @type and other output parameters

  buffer_type memory
  buffer_chunk_limit 256m
  buffer_queue_limit 128
  flush_interval 60s
  disable_retry_limit false
  retry_limit 17
  retry_wait 1s
  max_retry_wait 10s # default is infinite
</match>

<match pattern>
  # omit the part about @type and other output parameters
 
  buffer_type memory
  buffer_chunk_limit 256m
  buffer_queue_limit 128
  flush_interval 60s
  disable_retry_limit false
  retry_limit 17
  retry_wait 1s
  max_retry_wait 10s # default is infinite
</match>
转载请注明：Imekaku-Blog » Docker-log-driver缓冲区&Fluentd out_file, out_forward缓冲区
