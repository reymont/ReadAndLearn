<?php
# 声明upload-pictures交换器，fanout类型并且durable为true
$channel->exchange_declare('upload-pictures','fanout',false,true,false);
# 声明队列
$channel->queue_declare('add-points', false, true, false, false);
# 绑定队列
$channel->queue_bind('add-points', 'upload-pictures');
$consumer = function($msg){};
# 开始消费消息
$channel->basic_consume($queue,$consumer_tag,false,false,false,false,$consumer);
>