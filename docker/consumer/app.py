import pika, os

RABBITMQ_QUEUE = os.getenv("RABBITMQ_QUEUE", "default_queue")
rabbitmq_user = os.environ.get("RABBITMQ_USERNAME")
rabbitmq_pass = os.environ.get("RABBITMQ_PASSWORD")
rabbitmq_host = os.environ.get("RABBITMQ_HOST")
rabbitmq_port = int(os.environ.get("RABBITMQ_PORT"))

credentials = pika.PlainCredentials(rabbitmq_user, rabbitmq_pass)
parameters = pika.ConnectionParameters(
    host=rabbitmq_host,
    port=rabbitmq_port,
    credentials=credentials
)

connection = pika.BlockingConnection(parameters)
channel = connection.channel()
channel.queue_declare(queue=RABBITMQ_QUEUE, durable=True)

def callback(ch, method, properties, body):
    print(f"Received: {body.decode()}")

channel.basic_consume(queue=RABBITMQ_QUEUE, on_message_callback=callback, auto_ack=True)
print("Waiting for messages...")
channel.start_consuming()
