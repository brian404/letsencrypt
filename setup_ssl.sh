#!/bin/bash

# Install snapd if not already installed
if ! command -v snap >/dev/null; then
    sudo apt update
    sudo apt install snapd
fi

# Install core snap
sudo snap install core

# Refresh core snap
sudo snap refresh core

# Install certbot snap in classic mode
sudo snap install --classic certbot

# Create a symbolic link for certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# Prompt user for web server choice
echo "Select your web server:"
echo "1. Apache"
echo "2. Nginx"
read -p "Enter your choice (1 or 2): " choice

# Install and configure the chosen web server
case $choice in
    1)
        # Install apache2 if not already installed
        if ! command -v apache2 >/dev/null; then
            sudo apt update
            sudo apt install apache2
        fi

        # Run certbot with Apache plugin
        sudo certbot --apache
        ;;
    2)
        # Install nginx if not already installed
        if ! command -v nginx >/dev/null; then
            sudo apt update
            sudo apt install nginx
        fi

        # Run certbot with Nginx plugin
        sudo certbot --nginx
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Restart the chosen web server to apply changes
case $choice in
    1)
        sudo systemctl restart apache2
        ;;
    2)
        sudo systemctl restart nginx
        ;;
esac

