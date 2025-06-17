#!/bin/bash
set -euo pipefail

kubectl apply -f manifests/telemetry/
kubectl apply -f monitoring/grafana/configmap-grafana-dashboards.yaml