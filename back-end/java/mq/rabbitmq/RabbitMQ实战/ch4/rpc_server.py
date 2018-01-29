import pika, json

creds_broker = pika.PlainCredentials("rpc_user", "rpcme")
conn_params = pika.ConnectionParameters("localhost",
                                         virtual_host = "/",
                                         credentials = creds_broker)
conn_broker = pika.BlockingConnetion(conn_params)
channel = conn_broker.channel()
# 设置典型的direct类型交换器并创建队列和绑定
channel.exchange_declare(exchange="rpc",
                         type="direct",
                         auto_delete=False)
channel.queue_declare(queue="ping", auto_delete=False)
channel.queue_bind(queue="ping",
                   exchange="rpc",
                   routing_key="ping")

def api_ping(channel, method, header, body):
    """'ping' API call."""
    channel.basic_ack(delivery_tag=method.delivery_tag)
    msg_dict = json.loads(body)
    print "Received API call ...replying..."
    # 使用reply_to作为发布应答消息的目的地
    # 同时发布的时候无需指定交换器
    channel.basic_publish(body="Pong!" + str(msg_dict["time"]),
                          exchange="",
                          routing_key=header.reply_to)

channel.basic_consume(api_ping,
                      queue="ping",
                      consume_tag="ping")
print "Waiting for RPC calls..."
channel.start_consuming()