import pika, os

RABBITMQ_HOST = os.getenv("RABBITMQ_HOST", "rabbitmq.rabbitmq.svc.cluster.local")
RABBITMQ_QUEUE = os.getenv("RABBITMQ_QUEUE", "default_queue")

connection = pika.BlockingConnection(
    pika.ConnectionParameters(host="rabbitmq.rabbitmq.svc.cluster.local")
)
channel = connection.channel()
channel.queue_declare(queue=RABBITMQ_QUEUE, durable=True)

def callback(ch, method, properties, body):
    print(f"Received: {body.decode()}")

channel.basic_consume(queue=RABBITMQ_QUEUE, on_message_callback=callback, auto_ack=True)
print("Waiting for messages...")
channel.start_consuming()
