#!/bin/bash
set -euo pipefail

# Create namespaces (safe even if they already exist)
kubectl create namespace istio-system || true
kubectl create namespace monitoring || true
kubectl create namespace messaging || true
kubectl create namespace rabbitmq || true
echo "[INFO] Adding Helm repositories..."
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring

kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.26/samples/addons/prometheus.yaml

echo "[INFO] Installing Istio components..."
helm install istio-base istio/base -n istio-system --create-namespace
helm install istiod istio/istiod -n istio-system
helm install ingressgateway istio/gateway -n istio-system

echo "[INFO] Installing RabbitMQ..."
helm install rabbitmq bitnami/rabbitmq -n rabbitmq --create-namespace -f ../charts/rabbitmq/values-pv.yaml
kubectl label namespace rabbitmq istio-injection=enabled --overwrite

helm repo add kiali https://kiali.org/helm-charts
helm repo update

helm install --namespace istio-system kiali-server kiali/kiali-server --create-namespace