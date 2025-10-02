#!/usr/bin/env bash
set -euo pipefail

# Docker Installation Script for Ubuntu
# This script installs Docker Engine on Ubuntu 20.04+

echo "=== Docker Installation for Ubuntu ==="
echo "This script will install Docker Engine."
echo ""

# Check if running as regular user with sudo
if [[ $EUID -eq 0 ]]; then
   echo "This script should not be run as root. Please run as a regular user with sudo access."
   exit 1
fi

# Check if Docker is already installed
if command -v docker &> /dev/null; then
    echo "Docker is already installed. Version: $(docker --version)"
    read -p "Do you want to continue and update Docker? (y/n): " UPDATE_DOCKER
    if [[ ! $UPDATE_DOCKER =~ ^[Yy]$ ]]; then
        echo "Skipping Docker installation."
        exit 0
    fi
fi

# Update system packages
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install required packages for Docker installation
echo "Installing Docker prerequisites..."
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common

# Add Docker's official GPG key
echo "Adding Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "Adding Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index after adding repository
echo "Updating package index..."
sudo apt update

# Install Docker Engine
echo "Installing Docker..."
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Add current user to docker group
echo "Adding user $USER to docker group..."
sudo usermod -aG docker $USER

# Enable and start Docker service
echo "Enabling and starting Docker..."
sudo systemctl enable docker
sudo systemctl start docker

# Verify Docker installation
echo "Verifying Docker installation..."
if sudo docker run --rm hello-world &> /dev/null; then
    echo "Docker installed successfully!"
else
    echo "Docker installation verification failed."
    exit 1
fi

# Show Docker version
echo "Installed version:"
docker --version

echo "Docker installation complete!"
echo ""
echo "IMPORTANT: Please log out and log back in for Docker group changes to take effect."
echo "After logging back in, you can run Docker commands without sudo."
echo ""
echo "Test your installation with:"
echo "  docker run hello-world"
echo ""
