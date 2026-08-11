#!/bin/bash

echo "=========================================="
echo "      🚀 JENKINS INSTALLATION"
echo "=========================================="

sudo apt update
sudo apt install fontconfig openjdk-17-jre -y

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
/usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
/etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install jenkins -y

sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "=========================================="
echo "✅ Jenkins Installed"
echo "Access Jenkins:"
echo "http://<server-ip>:8080"
echo ""
echo "Initial Admin Password:"
echo "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
echo "=========================================="