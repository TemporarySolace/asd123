#!/bin/bash
set -euo pipefail

echo "[INFO] Starting full system setup..."

# === Pre-checks ===
echo "[INFO] Running environment pre-checks..."
source ./precheck.sh


# === Helm components installation ===
echo "[INFO] Installing Helm charts (Istio, RabbitMQ)..."
source ./helm_install.sh


# === Wait for pods to be ready ===
echo "[INFO] Waiting for all pods to become ready..."
source ./wait_for_pods.sh istio-system

echo "[INFO] System should now be accessible via Istio ingress."


# === Docker image build ===
echo "[INFO] Building Docker images..."
docker build -t producer:latest ../docker/producer || { echo '[ERROR] Failed to build producer image.'; exit 1; }
docker build -t consumer:latest ../docker/consumer || { echo '[ERROR] Failed to build consumer image.'; exit 1; }

# === Load images into Kind ===
echo "[INFO] Loading images into Kind cluster..."
kind load docker-image producer:latest --name test || { echo '[ERROR] Failed to load producer image into Kind.'; exit 1; }
kind load docker-image consumer:latest --name test || { echo '[ERROR] Failed to load consumer image into Kind.'; exit 1; }

# Apply messaging manifests
kubectl apply -f ../manifests/messaging/producer-deployment.yaml
kubectl apply -f ../manifests/messaging/producer-service.yaml
kubectl apply -f ../manifests/messaging/consumer-deployment.yaml
kubectl apply -f ../manifests/messaging/consumer-service.yaml

# Apply messaging ingress configs
kubectl apply -f ../manifests/messaging/producer-gateway.yaml
kubectl apply -f ../manifests/messaging/producer-virtualservice.yaml
kubectl apply -f ../manifests/messaging/consumer-gateway.yaml
kubectl apply -f ../manifests/messaging/consumer-virtualservice.yaml
kubectl apply -f ../charts/istio/templates/gateway.yaml
kubectl apply -f ../charts/istio/templates/virtualservices.yaml
# Apply RabbitMQ manifests
kubectl apply -f ../charts/rabbitmq/templates/deployment.yaml
kubectl apply -f ../charts/rabbitmq/templates/service.yaml
kubectl apply -f ../manifests/rabbitmq/rabbitmq-gateway.yaml
kubectl apply -f ../manifests/rabbitmq/rabbitmq-virtualservice.yaml

#show all pods
echo "[INFO] Displaying all pods in the cluster..."
kubectl get pods --all-namespaces
#show all ips
echo "[INFO] Displaying all services in the cluster..."
kubectl get svc --all-namespaces
#show all gateways
echo "[INFO] Displaying all gateways in the cluster..."
kubectl get gateways --all-namespaces
#show all virtualservices
echo "[INFO] Displaying all virtual services in the cluster..."
kubectl get virtualservices --all-namespaces
#show all deployments
echo "[INFO] Displaying all deployments in the cluster..."
kubectl get deployments --all-namespaces
#show all services
echo "[INFO] Displaying all services in the cluster..."
kubectl get services --all-namespaces
#show all namespaces
echo "[INFO] Displaying all namespaces in the cluster..."
kubectl get namespaces
#show url for RabbitMQ dashboard
echo "[INFO] RabbitMQ dashboard is accessible at: http://localhost:15672"
#show url for producer
echo "[SUCCESS] Deployment complete. You can now test the system via curl or access the dashboard."
