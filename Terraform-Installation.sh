#!/usr/bin/env bash
# ============================================================
# Script Name : Terraform-Installation.sh
# Description : Installs Terraform on Ubuntu/Debian from HashiCorp's
#               official APT repository (so `apt upgrade` keeps it current).
# Author      : Naman Pandey
# ============================================================

set -euo pipefail

echo "=========================================="
echo "      🏗️  TERRAFORM INSTALLATION"
echo "=========================================="

if command -v terraform &>/dev/null; then
    echo "✅ Terraform is already installed:"
    terraform version
    exit 0
fi

echo "📦 Installing prerequisites..."
sudo apt update
sudo apt install -y gnupg software-properties-common curl lsb-release

echo "🔑 Adding HashiCorp GPG key..."
curl -fsSL https://apt.releases.hashicorp.com/gpg | \
    sudo gpg --dearmor --yes -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "📂 Adding HashiCorp repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null

echo "🏗️  Installing Terraform..."
sudo apt update
sudo apt install -y terraform

echo "=========================================="
echo "✅ Terraform installed:"
terraform version
echo "=========================================="
echo "Try it:  terraform init | terraform plan | terraform apply"
echo "Tip:     terraform -install-autocomplete"
