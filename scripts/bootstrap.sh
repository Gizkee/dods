#!/usr/bin/env bash
set -euo pipefail

# DODS Server Bootstrap Script
# This script clones the repository and sets up the project structure
# Run this first on a fresh server before any other scripts

echo "=== Day of Defeat: Source Server Bootstrap ==="
echo "This script will clone the DODS server repository and set up the project."
echo ""

# More robust root detection
IS_ROOT=false
if [ "$EUID" -eq 0 ] || [ "$(id -u)" -eq 0 ] || [ "$USER" = "root" ] || [ "$USERNAME" = "root" ]; then
    IS_ROOT=true
fi

# Check if sudo is available when running as root (needed for user operations)
if [ "$IS_ROOT" = true ]; then
    echo "Detected running as root (UID: $(id -u), User: $(whoami))"
    if ! command -v sudo &> /dev/null; then
        echo "Sudo is not installed. Installing sudo first..."
        if command -v apt &> /dev/null; then
            apt update && apt install -y sudo
        else
            echo "This script is designed for Debian/Ubuntu systems with apt package manager."
            echo "Please install sudo manually and run this script again."
            exit 1
        fi
    fi
fi

# Optional user setup (if running as root)
if [ "$IS_ROOT" = true ]; then
    echo "Running as root. You can optionally create a dedicated user for the DODS server."
    echo "This is recommended for security and better organization."
    echo ""
    read -p "Do you want to create a new user for DODS? (y/n): " CREATE_USER
    
    if [[ $CREATE_USER =~ ^[Yy]$ ]]; then
        echo ""
        echo "=== User Setup ==="
        
        # Get username
        read -p "Enter username for DODS server (default: dods): " USERNAME
        USERNAME=${USERNAME:-dods}
        
        # Check if user already exists
        if id "$USERNAME" &>/dev/null; then
            echo "User '$USERNAME' already exists."
            read -p "Do you want to continue with existing user? (y/n): " CONTINUE_EXISTING
            if [[ ! $CONTINUE_EXISTING =~ ^[Yy]$ ]]; then
                echo "Exiting. Please choose a different username or remove the existing user."
                exit 1
            fi
        else
            # Create user with home directory and add to sudo group
            echo "Creating user '$USERNAME'..."
            useradd -m -s /bin/bash "$USERNAME"
            usermod -aG sudo "$USERNAME"
            
            # Set password
            echo "Setting password for user '$USERNAME':"
            passwd "$USERNAME"
            
            echo "User '$USERNAME' created successfully!"
        fi
        
        echo ""
        echo "=== User Created ==="
        echo "Please switch to the new user and run the bootstrap script again:"
        echo "  su - $USERNAME"
        echo "  curl -sSL https://raw.githubusercontent.com/Gizkee/dods/main/scripts/bootstrap.sh | bash"
        echo ""
        echo "Or if you have the script locally:"
        echo "  su - $USERNAME"
        echo "  cd /path/to/script && ./bootstrap.sh"
        echo ""
        exit 0
    else
        echo "Continuing as root user..."
        echo ""
    fi
fi

# Configuration - Update these variables for your setup
REPO_URL="${DODS_REPO_URL:-https://github.com/Gizkee/dods.git}"
INSTALL_DIR="${DODS_INSTALL_DIR:-$HOME/dods}"

# Check if git is available
if ! command -v git &> /dev/null; then
    echo "Git is not installed. Installing git..."
    
    # Install git (sudo is already available if needed)
    if command -v apt &> /dev/null; then
        if [ "$IS_ROOT" = true ]; then
            apt update && apt install -y git
        else
            sudo apt update && sudo apt install -y git
        fi
    else
        echo "This script is designed for Debian/Ubuntu systems with apt package manager."
        echo "Please install git manually and run this script again."
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
if [ "$IS_ROOT" = true ]; then
    echo "2. Consider creating a dedicated user (or run setup-user.sh):"
    echo "   ./scripts/setup-user.sh"
    echo ""
    echo "3. Install Docker:"
else
    echo "2. Install Docker:"
fi
echo "   ./scripts/install-docker.sh"
echo ""
if [ "$IS_ROOT" = true ]; then
    echo "4. Deploy the server:"
else
    echo "3. Deploy the server:"
fi
echo "   ./scripts/deploy.sh"
