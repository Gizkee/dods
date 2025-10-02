#!/usr/bin/env bash
set -euo pipefail

# User Setup Script for Ubuntu Server
# This script creates a new user with sudo access
# Run this as root or with sudo

echo "=== Ubuntu User Setup ==="
echo "This script will create a new user with sudo access."
echo ""

# Check if running as root or with sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root or with sudo."
   echo "Usage: sudo ./scripts/setup-user.sh"
   exit 1
fi

# Get username from user input
read -p "Enter username for the new user (default: dods): " USERNAME
USERNAME=${USERNAME:-dods}

# Check if user already exists
if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists."
    read -p "Do you want to add this user to sudo group? (y/n): " ADD_SUDO
    if [[ $ADD_SUDO =~ ^[Yy]$ ]]; then
        usermod -aG sudo "$USERNAME"
        echo "User $USERNAME added to sudo group."
    fi
else
    # Create the user
    echo "Creating user: $USERNAME"
    useradd -m -s /bin/bash "$USERNAME"
    
    # Add to sudo group
    usermod -aG sudo "$USERNAME"
    echo "User $USERNAME created and added to sudo group."
    
    # Set up SSH directory
    mkdir -p "/home/$USERNAME/.ssh"
    chown "$USERNAME:$USERNAME" "/home/$USERNAME/.ssh"
    chmod 700 "/home/$USERNAME/.ssh"
fi

# Configure sudoers for passwordless sudo (optional)
read -p "Do you want to configure passwordless sudo for $USERNAME? (y/n): " PASSWORDLESS
if [[ $PASSWORDLESS =~ ^[Yy]$ ]]; then
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$USERNAME"
    echo "Passwordless sudo configured for $USERNAME."
fi

# Set up SSH key (optional)
read -p "Do you want to set up SSH key authentication for $USERNAME? (y/n): " SSH_KEY
if [[ $SSH_KEY =~ ^[Yy]$ ]]; then
    echo "Please paste the public SSH key for $USERNAME (end with Ctrl+D):"
    cat > "/home/$USERNAME/.ssh/authorized_keys"
    chown "$USERNAME:$USERNAME" "/home/$USERNAME/.ssh/authorized_keys"
    chmod 600 "/home/$USERNAME/.ssh/authorized_keys"
    echo "SSH key configured for $USERNAME."
fi

echo ""
echo "=== User Setup Complete ==="
echo "User: $USERNAME"
echo "Home directory: /home/$USERNAME"
echo ""
echo "Next steps:"
echo "1. Switch to the new user: su - $USERNAME"
echo "2. Or SSH as the new user: ssh $USERNAME@your-server-ip"
echo ""
echo "Note: If you configured SSH keys, you can now SSH without a password."
echo "If not, you'll need to set a password for the user:"
echo "sudo passwd $USERNAME"
