import pika, os, time

RABBITMQ_QUEUE = os.getenv("RABBITMQ_QUEUE", "default_queue")
rabbitmq_user = os.environ.get("RABBITMQ_USERNAME")
rabbitmq_pass = os.environ.get("RABBITMQ_PASSWORD")
rabbitmq_host = os.environ.get("RABBITMQ_HOST", "rabbitmq.rabbitmq.svc.cluster.local")
rabbitmq_port = int(os.environ.get("RABBITMQ_PORT", "5672"))

credentials = pika.PlainCredentials(rabbitmq_user, rabbitmq_pass)
parameters = pika.ConnectionParameters(
    host=rabbitmq_host,
    port=rabbitmq_port,
    credentials=credentials
)

connection = pika.BlockingConnection(parameters)
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
