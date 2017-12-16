import json, smtplib
import pika
if __name__ == "__main__":
    AMQP_SERVER = "localhost"
    AMQP_USER = "alert_user"
    AMQP_PASS = "alertme"
    AMQP_VHOST = "/"
    AMQP_EXCHANGE = "alerts"

    creds_broker = pika.PlainCredentials(AMQP_USER, AMQP_PASS)
    # 连接到代理服务器（用户名、密码、虚拟主机等）
    conn_params = pika.ConnectionParameters(AMQP_SERVER,
                                            virtual_host = AMQP_VHOST,
                                            credentials = creds_broker)
    conn_broker = pika.BlockingConnection(conn_params)
    channel = conn_broker.channel()
    
    # 声明topic类型的alerts交换器，
    # auto_delete=False最后一个消费者断开连接后交换器仍然会存在
    channel.exchange_declare(exchange=AMQP_EXCHANGE,
                             type="topic",
                             auto_delete=False)
    
    # 将所有标记以critical.起始的消息路由到critical队列
    # 将所有标记以.rate_limit结尾的消息路由到rate_limit队列
    # 使用"."来分隔分别匹配标记的各个部分
    # durable=True将消息存储到相对缓慢的硬盘上
    channel.queue_declare(queue="critical", auto_delete=False)
    channel.queue_bind(queue="critical",
                       exchange="alerts",
                       routing_key="critical.*")
    channel.queue_declare(queue="rate_limit",auto_delete=False)
    channel.queue_bind(queue="rate_limit",
                       exchange="alerts",
                       routing_key="*.rate_limit")

    # 将告警附加到处理器上
    # channel.basic_consume
    ## critical_notify回调函数
    ## queue="critical"指定队列
    ## no_ack=False最后一条消息处理完并发送确认消息，才发送新的消息
    ## consumer_tag是一个标识符
    channel.basic_consume(critical_notify,
                          queue="critical",
                          no_ack=False,
                          consumer_tag="critical")
    channel.basic_consume(rate_limit_notify,
                          queue="rate_limit",
                          no_ack=False,
                          consumer_tag="rate_limit")
    print "Ready for alerts!"
    channel.start_consuming()

# 回调函数被调用时，Pika会传入消息相关的四个参数
## channel： Rabbit通信的信道对象
## method：  方法帧对象，携带关联订阅的消费者标记以及投递标记
## header：  AMQP消息头的对象，携带可选的消息元数据
## body：    消息内容
def critical_notify(channel, method, header, body):
    """Sends CRITICAL alerts to administrators via e-mail."""
    EMAIL_RECIPS = ["ops.team@ourcompany.com",]
    message = json.loads(body)
    send_mail(EMAIL_RECIPS, "CRITICAL ALERT", message)
    print("Sent alert via e-mail! Alert Text: %s " + \
          "Recipients: %s") % (str(message), str(EMAIL_RECIPS))
    channel.basic_ack(delivery_tag=method.delivery_tag)