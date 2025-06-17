#!/bin/bash
set -euo pipefail

echo "[INFO] Starting full system setup..."

# === Pre-checks ===
echo "[INFO] Running environment pre-checks..."
source ./scripts/prechecks.sh


# === Helm components installation ===
echo "[INFO] Installing Helm charts (Istio, RabbitMQ)..."
source ./scripts/helm_install.sh

# === Namespace setup ===
echo "[INFO] Setting up producer and consumer namespaces..."
source ./scripts/setup_producer_namespace.sh
source ./scripts/setup_consumer_namespace.sh

# === Telemetry setup ===
echo "[INFO] Configuring monitoring and telemetry..."
source ./scripts/telemetry_setup.sh

# === Wait for pods to be ready ===
echo "[INFO] Waiting for all pods to become ready..."
source ./scripts/wait_for_pods.sh

echo "[INFO] System should now be accessible via Istio ingress."


# === Docker image build ===
echo "[INFO] Building Docker images..."
docker build -t producer:latest ./docker/producer || { echo '[ERROR] Failed to build producer image.'; exit 1; }
docker build -t consumer:latest ./docker/consumer || { echo '[ERROR] Failed to build consumer image.'; exit 1; }

# === Load images into Kind ===
echo "[INFO] Loading images into Kind cluster..."
kind load docker-image producer:latest --name test || { echo '[ERROR] Failed to load producer image into Kind.'; exit 1; }
kind load docker-image consumer:latest --name test || { echo '[ERROR] Failed to load consumer image into Kind.'; exit 1; }

# Apply messaging manifests
kubectl apply -f manifests/messaging/producer-deployment.yaml
kubectl apply -f manifests/messaging/producer-service.yaml
kubectl apply -f manifests/messaging/consumer-deployment.yaml
kubectl apply -f manifests/messaging/consumer-service.yaml

# Apply messaging ingress configs
kubectl apply -f manifests/messaging/producer-gateway.yaml
kubectl apply -f manifests/messaging/producer-virtualservice.yaml
kubectl apply -f manifests/messaging/consumer-gateway.yaml
kubectl apply -f manifests/messaging/consumer-virtualservice.yaml

# Output RabbitMQ credentials
RABBIT_USER=$(kubectl get secret rabbitmq -o jsonpath="{.data.rabbitmq-username}" | base64 --decode)
RABBIT_PASS=$(kubectl get secret rabbitmq -o jsonpath="{.data.rabbitmq-password}" | base64 --decode)
echo "RabbitMQ username: $RABBIT_USER"
echo "RabbitMQ password: $RABBIT_PASS"


echo "[SUCCESS] Deployment complete. You can now test the system via curl or access the dashboard."
