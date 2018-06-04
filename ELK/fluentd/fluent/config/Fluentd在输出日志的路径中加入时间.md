

# http://www.imekaku.com/2016/09/26/fluentd-put-time-in-path/

fluentd输出的日志，会按照path + time + “.log”的方式输出，参见。但是这只会使文件名加上名称，如果不断往这个路径中加入日志的话，那么产生的日志将会非常的多，所以需要在日志的路径中加入time。
思路是，首先使用record_reformer插件在record中加入time，再使用rewrite_tag_filter插件从record中提取time，放在tag中，再用forest插件放在路径中。
fluentd客户端配置文件

fluentd客户端配置文件Shell

<source>
  type forward
  port 24224
  bind 0.0.0.0
</source>

# 把时间加入record，并且key为local_time
<match docker.**>
  type record_reformer
  tag reformed.${tag}
  local_time ${time.strftime('%Y-%m-%d-%H')}
</match>

# 按照source，添加tag
<match reformed.docker.**>
  type rewrite_tag_filter
  rewriterule1 source stdout system_out.${tag}
  rewriterule2 source stderr system_err.${tag}
</match>

# 把record中的local_time字段的value加在tag上面
<match system_err.**>
  type rewrite_tag_filter
  rewriterule1 local_time ^(.+)$ $1.${tag}
</match>

# 同上
<match system_out.**>
  type rewrite_tag_filter
  rewriterule1 local_time ^(.+)$ $1.${tag}
</match>

# 根据内容再加上不同的tag
<match *.system_err.**>
  type copy
  <store>
    type grep
    regexp1 log \s+200\s+
    add_tag_prefix program_200
  </store>
  <store>
    type grep
    regexp1 log \s+304\s+
    add_tag_prefix program_304
  </store>
  <store>
    type grep
    regexp1 log \s+404\s+
    add_tag_prefix program_404
  </store>
</match>

<match **>
    type forward
    <server>
      host 192.168.126.136
      port 24224
      weight 30
    </server>
    <server>
      host 192.168.126.137
      port 24224
      weight 30
    </server>
    flush_interval 5s
</match>

<source>
  type forward
  port 24224
  bind 0.0.0.0
</source>
 
# 把时间加入record，并且key为local_time
<match docker.**>
  type record_reformer
  tag reformed.${tag}
  local_time ${time.strftime('%Y-%m-%d-%H')}
</match>
 
# 按照source，添加tag
<match reformed.docker.**>
  type rewrite_tag_filter
  rewriterule1 source stdout system_out.${tag}
  rewriterule2 source stderr system_err.${tag}
</match>
 
# 把record中的local_time字段的value加在tag上面
<match system_err.**>
  type rewrite_tag_filter
  rewriterule1 local_time ^(.+)$ $1.${tag}
</match>
 
# 同上
<match system_out.**>
  type rewrite_tag_filter
  rewriterule1 local_time ^(.+)$ $1.${tag}
</match>
 
# 根据内容再加上不同的tag
<match *.system_err.**>
  type copy
  <store>
    type grep
    regexp1 log \s+200\s+
    add_tag_prefix program_200
  </store>
  <store>
    type grep
    regexp1 log \s+304\s+
    add_tag_prefix program_304
  </store>
  <store>
    type grep
    regexp1 log \s+404\s+
    add_tag_prefix program_404
  </store>
</match>
 
<match **>
    type forward
    <server>
      host 192.168.126.136
      port 24224
      weight 30
    </server>
    <server>
      host 192.168.126.137
      port 24224
      weight 30
    </server>
    flush_interval 5s
</match>
fluentd服务器端配置文件

如果只需要输出的日志有log字段，那么需要file输出格式下，即template中加上：
output_tag false
output_time false
message_key log
format single_value
fluentd服务端配置文件Shell

# 从fluentd客户端传过来的log，其实time已经包含在tag中了，无论是放在路径中还是文件名中，都没问题
<source>
  type forward
  port 24224
  bind 0.0.0.0
</source>

<match *.system_out.reformed.docker.*.**>
  type forest
  subtype file
  <template>
    time_slice_format %Y%m%dT%H
    # 放在文件名中
    # path /home/lee/fluentd-log/${tag_parts[0]}/${tag_parts[5]}/${tag_parts[1]}.t3
    # 放在路径中
    path /home/lee/fluentd-log/${tag_parts[1]}/${tag_parts[0]}/${tag_parts[4]}/t3
    buffer_chunk_limit 256m
    buffer_queue_limit 128
    flush_interval 3m
    disable_retry_limit false
    retry_limit 17
    retry_wait 1s
  </template>
</match>

<match program_200.*.system_err.reformed.docker.*.**>
  type forest
  subtype file
  <template>
    time_slice_format %Y%m%dT%H
    path /home/lee/fluentd-log/${tag_parts[0]}/${tag_parts[1]}/${tag_parts[5]}/t3
    buffer_chunk_limit 256m
    buffer_queue_limit 128
    flush_interval 3m
    disable_retry_limit false
    retry_limit 17
    retry_wait 1s
  </template>
</match>

<match program_304.*.system_err.reformed.docker.*.**>
  type forest
  subtype file
  <template>
    time_slice_format %Y%m%dT%H
    path /home/lee/fluentd-log/${tag_parts[0]}/${tag_parts[1]}/${tag_parts[5]}/t3
    buffer_chunk_limit 256m
    buffer_queue_limit 128
    flush_interval 3m
    disable_retry_limit false
    retry_limit 17
    retry_wait 1s
  </template>
</match>

<match program_404.*.system_err.reformed.docker.*.**>
  type forest
  subtype file
  <template>
    time_slice_format %Y%m%dT%H
    path /home/lee/fluentd-log/${tag_parts[0]}/${tag_parts[1]}/${tag_parts[5]}/t3
    buffer_chunk_limit 256m
    buffer_queue_limit 128
    flush_interval 3m
    disable_retry_limit false
    retry_limit 17
    retry_wait 1s
  </template>
</match>

# 从fluentd客户端传过来的log，其实time已经包含在tag中了，无论是放在路径中还是文件名中，都没问题
<source>
  type forward
  port 24224
  bind 0.0.0.0
</source>
 
<match *.system_out.reformed.docker.*.**>
  type forest
  subtype file
  <template>
    time_slice_format %Y%m%dT%H
    # 放在文件名中
    # path /home/lee/fluentd-log/${tag_parts[0]}/${tag_parts[5]}/${tag_parts[1]}.t3
    # 放在路径中
    path /home/lee/fluentd-log/${tag_parts[1]}/${tag_parts[0]}/${tag_parts[4]}/t3
    buffer_chunk_limit 256m
    buffer_queue_limit 128
    flush_interval 3m
    disable_retry_limit false
    retry_limit 17
    retry_wait 1s
  </template>
</match>
 
<match program_200.*.system_err.reformed.docker.*.**>
  type forest
  subtype file
  <template>
    time_slice_format %Y%m%dT%H
    path /home/lee/fluentd-log/${tag_parts[0]}/${tag_parts[1]}/${tag_parts[5]}/t3
    buffer_chunk_limit 256m
    buffer_queue_limit 128
    flush_interval 3m
    disable_retry_limit false
    retry_limit 17
    retry_wait 1s
  </template>
</match>
 
<match program_304.*.system_err.reformed.docker.*.**>
  type forest
  subtype file
  <template>
    time_slice_format %Y%m%dT%H
    path /home/lee/fluentd-log/${tag_parts[0]}/${tag_parts[1]}/${tag_parts[5]}/t3
    buffer_chunk_limit 256m
    buffer_queue_limit 128
    flush_interval 3m
    disable_retry_limit false
    retry_limit 17
    retry_wait 1s
  </template>
</match>
 
<match program_404.*.system_err.reformed.docker.*.**>
  type forest
  subtype file
  <template>
    time_slice_format %Y%m%dT%H
    path /home/lee/fluentd-log/${tag_parts[0]}/${tag_parts[1]}/${tag_parts[5]}/t3
    buffer_chunk_limit 256m
    buffer_queue_limit 128
    flush_interval 3m
    disable_retry_limit false
    retry_limit 17
    retry_wait 1s
  </template>
</match>
转载请注明：Imekaku-Blog » Fluentd在输出日志的路径中加入时间