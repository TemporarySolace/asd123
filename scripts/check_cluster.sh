#!/bin/bash
set -euo pipefail
if ! command -v kubectl &>/dev/null; then echo "kubectl missing"; exit 1; fi
if ! kubectl cluster-info &>/dev/null; then echo "cluster not reachable"; exit 1; fi
echo "Kubernetes cluster is accessible."

