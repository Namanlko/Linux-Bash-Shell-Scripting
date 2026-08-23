#!/bin/bash
# Docker + Docker Compose V2 Installation Script for Ubuntu
# Installs Docker Engine, Docker Buildx, and Docker Compose V2.
# Also enables Docker service and verifies the installation.

echo "=========================================="
echo "   🐳 DOCKER + COMPOSE V2 INSTALLATION   "
echo "=========================================="

echo "📦 Updating package index..."
sudo apt update

echo "------------------------------------------"
echo "📦 Installing required packages..."
sudo apt install -y ca-certificates curl gnupg lsb-release

echo "------------------------------------------"
echo "🔑 Adding Docker's official GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc

sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "------------------------------------------"
echo "📂 Adding Docker repository..."

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "------------------------------------------"
echo "📦 Updating package index..."
sudo apt update

echo "------------------------------------------"
echo "🐳 Installing Docker Engine..."
sudo apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

echo "------------------------------------------"
echo "▶️ Starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

echo "------------------------------------------"
echo "👤 Adding current user to Docker group..."
sudo usermod -aG docker "$USER"

echo "------------------------------------------"
echo "✅ Docker Version:"
docker --version

echo "------------------------------------------"
echo "✅ Docker Compose Version:"
docker compose version

echo "------------------------------------------"
echo "🔧 Docker Service Status:"
sudo systemctl is-active docker

echo "=========================================="
echo "🎉 Docker + Docker Compose V2 Installed!"
echo "=========================================="

echo "ℹ️ Please log out and log back in"
echo "or run the following command:"
echo ""
echo "    newgrp docker"
echo ""

echo "Then verify Docker:"
echo "    docker run hello-world"
echo ""

echo "Verify Docker Compose V2:"
echo "    docker compose version"
echo ""

echo "Example:"
echo "    docker compose up -d"
echo "=========================================="