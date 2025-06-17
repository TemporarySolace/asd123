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
install_if_missing kubectl "sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg;
 curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg; 
 sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg;
 echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list;
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list;   # helps tools such as command-not-found to work correctly
sudo apt-get update && sudo apt-get install -y kubectl
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