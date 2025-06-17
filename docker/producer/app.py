import pika, os, time

RABBITMQ_HOST = os.getenv("RABBITMQ_HOST", "rabbitmq.rabbitmq.svc.cluster.local")
RABBITMQ_QUEUE = os.getenv("RABBITMQ_QUEUE", "default_queue")

connection = pika.BlockingConnection(
    pika.ConnectionParameters(host="rabbitmq.rabbitmq.svc.cluster.local")
)
channel = connection.channel()
channel.queue_declare(queue=RABBITMQ_QUEUE, durable=True)

while True:
    message = f"Message at {time.time()}"
    channel.basic_publish(exchange='',
                          routing_key=RABBITMQ_QUEUE,
                          body=message.encode(),
                          properties=pika.BasicProperties(delivery_mode=2))
    print(f"Sent: {message}")
    time.sleep(5)
