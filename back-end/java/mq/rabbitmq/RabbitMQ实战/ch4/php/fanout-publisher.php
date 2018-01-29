<?php
# 声明upload-pictures交换器，fanout类型并且durable为true
$channel->exchange_declare('upload-pictures','fanout',false,true,false);
# 创建消息元数据，并编码为JSON格式
$metadata = json_encode(array(
    'image_id' => $image_id,
    'user_id' => $user_id,
    'image_path' => $image_path
));
# delivery_mode=2使消息持久化
$msg = new AMQPMessage($metadata,
            array('content_type' => 'application/json',
                  'delivery_mode' => 2));
# 消息发布到upload-pictures交换器
$channel->basic_publish($msg, 'upload-pictures');
>