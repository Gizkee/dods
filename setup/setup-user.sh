#!/usr/bin/env bash
set -euo pipefail

# User Setup Script for Debian/Ubuntu Server
# This script creates a new user with sudo access
# Run this as root or with sudo

echo "=== Debian/Ubuntu User Setup ==="
echo "This script will create a new user with sudo access."
echo ""

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ] && [ "$(id -u)" -ne 0 ] && [ "${USER:-}" != "root" ] && [ "${USERNAME:-}" != "root" ]; then
   echo "This script must be run as root or with sudo."
   echo "Usage: sudo ./scripts/setup-user.sh"
   exit 1
fi

# Get username from user input
read -p "Enter username for the new user (default: dods): " NEW_USERNAME
NEW_USERNAME=${NEW_USERNAME:-dods}

# Check if user already exists
if id "$NEW_USERNAME" &>/dev/null; then
    echo "User $NEW_USERNAME already exists."
    read -p "Do you want to add this user to sudo group? (y/n): " ADD_SUDO
    if [[ $ADD_SUDO =~ ^[Yy]$ ]]; then
        usermod -aG sudo "$NEW_USERNAME"
        echo "User $NEW_USERNAME added to sudo group."
    fi
else
    # Create the user
    echo "Creating user: $NEW_USERNAME"
    useradd -m -s /bin/bash "$NEW_USERNAME"
    
    # Add to sudo group
    usermod -aG sudo "$NEW_USERNAME"
    echo "User $NEW_USERNAME created and added to sudo group."
    
    # Set up SSH directory
    mkdir -p "/home/$NEW_USERNAME/.ssh"
    chown "$NEW_USERNAME:$NEW_USERNAME" "/home/$NEW_USERNAME/.ssh"
    chmod 700 "/home/$NEW_USERNAME/.ssh"
fi

# Configure sudoers for passwordless sudo (optional)
read -p "Do you want to configure passwordless sudo for $NEW_USERNAME? (y/n): " PASSWORDLESS
if [[ $PASSWORDLESS =~ ^[Yy]$ ]]; then
    echo "$NEW_USERNAME ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$NEW_USERNAME"
    echo "Passwordless sudo configured for $NEW_USERNAME."
fi

# Set up SSH key (optional)
read -p "Do you want to set up SSH key authentication for $NEW_USERNAME? (y/n): " SSH_KEY
if [[ $SSH_KEY =~ ^[Yy]$ ]]; then
    echo "Please paste the public SSH key for $NEW_USERNAME (end with Ctrl+D):"
    cat > "/home/$NEW_USERNAME/.ssh/authorized_keys"
    chown "$NEW_USERNAME:$NEW_USERNAME" "/home/$NEW_USERNAME/.ssh/authorized_keys"
    chmod 600 "/home/$NEW_USERNAME/.ssh/authorized_keys"
    echo "SSH key configured for $NEW_USERNAME."
fi

echo ""
echo "=== User Setup Complete ==="
echo "User: $NEW_USERNAME"
echo "Home directory: /home/$NEW_USERNAME"
echo ""
echo "Next steps:"
echo "1. Switch to the new user: su - $NEW_USERNAME"
echo "2. Or SSH as the new user: ssh $NEW_USERNAME@your-server-ip"
echo ""
echo "Note: If you configured SSH keys, you can now SSH without a password."
echo "If not, you'll need to set a password for the user:"
echo "sudo passwd $NEW_USERNAME"
