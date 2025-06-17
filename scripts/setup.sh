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


# Apply RabbitMQ manifests
kubectl apply -f ../manifests/rabbitmq/
kubectl apply -f ../manifests/istio/
kubectl apply -f ../manifests/telemetry/prometheus-virtualservice.yaml -n monitoring

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
