#!/bin/bash
# Docker Installation Script for Ubuntu
# Installs the latest Docker Engine and verifies the installation.

echo "=========================================="
echo "      🐳 DOCKER INSTALLATION SCRIPT 🐳     "
echo "=========================================="

echo "📦 Updating package index..."
sudo apt update

echo "------------------------------------------"
echo "📦 Installing required packages..."
sudo apt install -y ca-certificates curl gnupg lsb-release

echo "------------------------------------------"
echo "🔑 Adding Docker's official GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "------------------------------------------"
echo "📂 Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "------------------------------------------"
echo "📦 Updating package index..."
sudo apt update

echo "------------------------------------------"
echo "🐳 Installing Docker Engine..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "------------------------------------------"
echo "▶️ Starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

echo "------------------------------------------"
echo "👤 Adding current user to Docker group..."
sudo usermod -aG docker $USER

echo "------------------------------------------"
echo "✅ Docker Version:"
docker --version

echo "=========================================="
echo "🎉 Docker Installation Completed!"
echo "=========================================="
echo "ℹ️ Please log out and log back in"
echo "or run the following command:"
echo ""
echo "    newgrp docker"
echo ""
echo "Then verify Docker by running:"
echo "    docker run hello-world"
echo "=========================================="