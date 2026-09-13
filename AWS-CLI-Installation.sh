#!/bin/bash

# ============================================================
# Script Name : AWS-CLI-Installation.sh
# Description : Installs AWS CLI v2 on Ubuntu
# Author      : Naman Pandey
# ============================================================

# Exit immediately if any command fails
set -e

echo "=========================================="
echo "      AWS CLI Installation Script"
echo "=========================================="

# ------------------------------------------------------------
# Step 1: Check whether AWS CLI is already installed
# ------------------------------------------------------------

if command -v aws &> /dev/null
then
    echo "AWS CLI is already installed."
    aws --version
    exit 0
fi

# ------------------------------------------------------------
# Step 2: Update the package list
# ------------------------------------------------------------

echo "Updating package list..."

sudo apt update -y

# ------------------------------------------------------------
# Step 3: Install required packages
# ------------------------------------------------------------

echo "Installing required packages..."

sudo apt install -y curl unzip

# ------------------------------------------------------------
# Step 4: Download AWS CLI v2
# ------------------------------------------------------------

echo "Downloading AWS CLI v2..."

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
    -o "awscliv2.zip"

# ------------------------------------------------------------
# Step 5: Extract the downloaded ZIP file
# ------------------------------------------------------------

echo "Extracting AWS CLI package..."

unzip -q awscliv2.zip

# ------------------------------------------------------------
# Step 6: Install AWS CLI
# ------------------------------------------------------------

echo "Installing AWS CLI..."

sudo ./aws/install

# ------------------------------------------------------------
# Step 7: Verify AWS CLI installation
# ------------------------------------------------------------

echo "=========================================="
echo "AWS CLI Installation Completed"
echo "=========================================="

aws --version

# ------------------------------------------------------------
# Step 8: Remove temporary installation files
# ------------------------------------------------------------

echo "Cleaning up temporary files..."

rm -rf aws awscliv2.zip

echo "Cleanup completed."

echo ""
echo "AWS CLI is ready to use."
echo "Run 'aws configure' to configure your AWS credentials."