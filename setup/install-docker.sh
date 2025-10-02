#!/usr/bin/env bash
set -euo pipefail

# Docker Installation Script for Ubuntu
# This script installs Docker Engine on Ubuntu 20.04+

echo "=== Docker Installation for Ubuntu ==="
echo "This script will install Docker Engine."
echo ""

# Detect if running as root or regular user with sudo
IS_ROOT=false
if [ "$EUID" -eq 0 ] || [ "$(id -u)" -eq 0 ] || [ "${USER:-}" = "root" ] || [ "${USERNAME:-}" = "root" ]; then
    IS_ROOT=true
fi

if [[ $IS_ROOT == true ]]; then
    echo "Running as root user."
else
    echo "Running as regular user. Will use sudo for installation."
    # Check if user has sudo access
    if ! sudo -n true 2>/dev/null; then
        echo "This script requires sudo access. Please ensure you can run sudo commands."
        exit 1
    fi
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
if [[ $IS_ROOT == true ]]; then
    apt update && apt upgrade -y
else
    sudo apt update && sudo apt upgrade -y
fi

# Install required packages for Docker installation
echo "Installing Docker prerequisites..."
if [[ $IS_ROOT == true ]]; then
    apt install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        software-properties-common
else
    sudo apt install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        software-properties-common
fi

# Add Docker's official GPG key
echo "Adding Docker GPG key..."
if [[ $IS_ROOT == true ]]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
else
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
fi

# Add Docker repository
echo "Adding Docker repository..."
if [[ $IS_ROOT == true ]]; then
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
else
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
fi

# Update package index after adding repository
echo "Updating package index..."
if [[ $IS_ROOT == true ]]; then
    apt update
else
    sudo apt update
fi

# Install Docker Engine
echo "Installing Docker..."
if [[ $IS_ROOT == true ]]; then
    apt install -y docker-ce docker-ce-cli containerd.io
else
    sudo apt install -y docker-ce docker-ce-cli containerd.io
fi

# Add current user to docker group
echo "Adding user $USER to docker group..."
if [[ $IS_ROOT == true ]]; then
    usermod -aG docker $USER
else
    sudo usermod -aG docker $USER
fi

# Enable and start Docker service
echo "Enabling and starting Docker..."
if [[ $IS_ROOT == true ]]; then
    systemctl enable docker
    systemctl start docker
else
    sudo systemctl enable docker
    sudo systemctl start docker
fi

# Verify Docker installation
echo "Verifying Docker installation..."
if [[ $IS_ROOT == true ]]; then
    if docker run --rm hello-world &> /dev/null; then
        echo "Docker installed successfully!"
    else
        echo "Docker installation verification failed."
        exit 1
    fi
else
    if sudo docker run --rm hello-world &> /dev/null; then
        echo "Docker installed successfully!"
    else
        echo "Docker installation verification failed."
        exit 1
    fi
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
