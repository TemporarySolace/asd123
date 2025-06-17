#!/bin/bash
set -e

echo "Checking for required tools..."

install_if_missing() {
  CMD=$1
  INSTALL_CMD=$2
  if ! command -v $CMD &>/dev/null; then
    echo "⚠️  $CMD not found. Installing..."
    eval "$INSTALL_CMD"
  else
    echo "✅ $CMD is already installed."
  fi
}

# Docker
install_if_missing docker "curl -fsSL https://get.docker.com | bash && sudo usermod -aG docker \$USER"

# curl
install_if_missing curl "sudo apt-get update && sudo apt-get install -y curl"

# kubectl
install_if_missing kubectl "
  curl -LO https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl &&
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl &&
  rm kubectl
"

# helm
install_if_missing helm "
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
"

# kind
install_if_missing kind "
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64 &&
  chmod +x ./kind &&
  sudo mv ./kind /usr/local/bin/kind
"

echo "All required tools are installed."

# Create kind cluster if not exists
if ! kind get clusters | grep -q "^test$"; then
  echo "Creating kind cluster named 'test'..."
  kind create cluster --name test
else
  echo "Kind cluster 'test' already exists."
fi