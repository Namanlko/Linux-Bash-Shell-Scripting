#!/bin/bash
# Minikube Installation Script for Ubuntu
# Installs Docker, kubectl, and Minikube.
# Configures Docker for the current user and starts a Minikube cluster.

echo "=========================================="
echo "     ☸️ MINIKUBE INSTALLATION SCRIPT ☸️"
echo "=========================================="

echo "📦 Updating package index..."
sudo apt update

echo "------------------------------------------"
echo "📦 Installing required packages..."
sudo apt install -y curl wget apt-transport-https ca-certificates gnupg lsb-release

echo "------------------------------------------"
echo "🐳 Installing Docker Engine..."

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "------------------------------------------"
echo "📦 Installing Docker..."

sudo apt update

sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "------------------------------------------"
echo "▶️ Enabling and Starting Docker..."

sudo systemctl enable docker
sudo systemctl start docker

echo "------------------------------------------"
echo "👤 Adding current user to Docker group..."

sudo usermod -aG docker $USER

echo "------------------------------------------"
echo "☸️ Installing kubectl..."

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

rm kubectl

echo "------------------------------------------"
echo "🚀 Downloading Minikube..."

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

sudo install minikube-linux-amd64 /usr/local/bin/minikube

rm minikube-linux-amd64

echo "------------------------------------------"
echo "🔄 Activating Docker group..."

newgrp docker <<EOF

echo "Docker Group Activated."

echo "------------------------------------------"
echo "▶️ Starting Minikube using Docker driver..."

minikube start --driver=docker

EOF

echo "------------------------------------------"
echo "✅ Installed Versions"

echo "Docker    : $(docker --version)"
echo "Kubectl   : $(kubectl version --client)"
echo "Minikube  : $(minikube version | head -n 1)"

echo "=========================================="
echo "🎉 Minikube Installation Completed!"
echo "=========================================="

echo "Useful Commands:"
echo ""
echo "🔹 Check Docker"
echo "   docker ps"
echo ""
echo "🔹 Check Minikube Status"
echo "   minikube status"
echo ""
echo "🔹 View Cluster Nodes"
echo "   kubectl get nodes"
echo ""
echo "🔹 View All Pods"
echo "   kubectl get pods -A"
echo ""
echo "🔹 View Services"
echo "   kubectl get svc"
echo ""
echo "🔹 Open Kubernetes Dashboard"
echo "   minikube dashboard"
echo ""
echo "🔹 SSH into Minikube Node"
echo "   minikube ssh"
echo ""
echo "🔹 Stop Minikube"
echo "   minikube stop"
echo ""
echo "🔹 Start Minikube"
echo "   minikube start"
echo ""
echo "🔹 Delete Minikube Cluster"
echo "   minikube delete"
echo "=========================================="