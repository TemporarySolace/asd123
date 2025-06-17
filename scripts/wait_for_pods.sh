#!/bin/bash
set -euo pipefail

NAMESPACE=$1
kubectl wait --for=condition=Ready pods --all -n $NAMESPACE --timeout=120s
