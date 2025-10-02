#!/usr/bin/env bash
set -euo pipefail

# DODS Server Bootstrap Script
# This script clones the repository and sets up the project structure
# Run this first on a fresh server before any other scripts

echo "=== Day of Defeat: Source Server Bootstrap ==="
echo "This script will clone the DODS server repository and set up the project."
echo ""

# Configuration - Update these variables for your setup
REPO_URL="${DODS_REPO_URL:-https://github.com/Gizkee/dods.git}"
INSTALL_DIR="${DODS_INSTALL_DIR:-$HOME/dods}"

# Check if git is available
if ! command -v git &> /dev/null; then
    echo "Git is not installed. Installing git..."
    
    # Check if sudo is available, install if missing
    if ! command -v sudo &> /dev/null; then
        echo "Sudo is not installed. Installing sudo first..."
        if command -v apt &> /dev/null; then
            apt update && apt install -y sudo
        elif command -v yum &> /dev/null; then
            yum install -y sudo
        elif command -v dnf &> /dev/null; then
            dnf install -y sudo
        else
            echo "Unable to install sudo automatically. Please install sudo manually and run this script again."
            exit 1
        fi
    fi
    
    # Now install git with sudo
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y git
    elif command -v yum &> /dev/null; then
        sudo yum install -y git
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y git
    else
        echo "Unable to install git automatically. Please install git manually and run this script again."
        exit 1
    fi
fi

# Create installation directory
echo "Creating installation directory: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

# Check if directory is empty or if it's an existing git repository
if [ -d "$INSTALL_DIR/.git" ]; then
    echo "Found existing git repository in $INSTALL_DIR"
    cd "$INSTALL_DIR"
    echo "Updating existing repository..."
    git pull
elif [ "$(ls -A "$INSTALL_DIR" 2>/dev/null)" ]; then
    echo "Directory $INSTALL_DIR is not empty and not a git repository."
    echo "Please either:"
    echo "1. Remove the directory: rm -rf $INSTALL_DIR"
    echo "2. Choose a different directory by setting DODS_INSTALL_DIR environment variable"
    echo "3. Initialize git repository manually in the existing directory"
    exit 1
else
    echo "Cloning repository from $REPO_URL to $INSTALL_DIR..."
    if git clone "$REPO_URL" "$INSTALL_DIR"; then
        echo "Repository cloned successfully!"
        cd "$INSTALL_DIR"
    else
        echo "Failed to clone repository. Please check:"
        echo "1. Repository URL is correct: $REPO_URL"
        echo "2. You have access to the repository"
        echo "3. Your network connection is working"
        echo ""
        echo "You can set a custom repository URL with:"
        echo "DODS_REPO_URL='https://github.com/your-username/your-repo.git' $0"
        exit 1
    fi
fi

# Make all scripts executable
echo "Making scripts executable..."
chmod +x scripts/*.sh

# Show next steps
echo ""
echo "=== Bootstrap Complete ==="
echo "DODS server repository has been set up in: $INSTALL_DIR"
echo ""
echo "Next steps:"
echo "1. Navigate to the project directory:"
echo "   cd $INSTALL_DIR"
echo ""
echo "2. If you need to set up a user (run as root):"
echo "   sudo ./scripts/setup-user.sh"
echo ""
echo "3. Install Docker:"
echo "   ./scripts/install-docker.sh"
echo ""
echo "4. Deploy the server:"
echo "   ./scripts/deploy.sh"
