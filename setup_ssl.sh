#!/bin/bash

set -e

log_file="/var/log/certbot_setup.log"
light_green="\e[1;32m"
light_red="\e[1;31m"
reset="\e[0m"

log() {
    echo -e "$(date +"%Y-%m-%d %H:%M:%S") - ${light_green}[+]${reset} $1" | tee -a "$log_file"
}

error() {
    echo -e "$(date +"%Y-%m-%d %H:%M:%S") - ${light_red}[-]${reset} $1" | tee -a "$log_file"
}

sudo apt update

install_snapd() {
    log "Checking for snapd installation..."
    if ! command -v snap >/dev/null; then
        log "Installing snapd..."
        sudo apt install -y snapd
    else
        log "snapd is already installed."
    fi
}

install_certbot() {
    log "Installing core snap and certbot..."
    sudo snap install core
    sudo snap refresh core
    if ! command -v certbot >/dev/null; then
        sudo snap install --classic certbot
        sudo ln -s /snap/bin/certbot /usr/bin/certbot
    else
        log "Certbot is already installed."
    fi
}

configure_web_server() {
    case $1 in
        1)
            log "Installing Apache..."
            sudo apt install -y apache2
            log "Running certbot with Apache plugin..."
            sudo certbot --apache --agree-tos --non-interactive --email "$email"
            sudo systemctl restart apache2
            ;;
        2)
            log "Installing Nginx..."
            sudo apt install -y nginx
            log "Running certbot with Nginx plugin..."
            sudo certbot --nginx --agree-tos --non-interactive --email "$email"
            sudo systemctl restart nginx
            ;;
        3)
            read -p "Enter your domain (e.g., example.com): " domain
            log "Running certbot in standalone mode for domain $domain..."
            sudo certbot certonly --standalone --preferred-challenges http -d "$domain" --agree-tos --non-interactive --email "$email"
            ;;
        *)
            log "Invalid choice."
            exit 1
            ;;
    esac
}

renew_certificates() {
    log "Renewing certificates..."
    sudo certbot renew --non-interactive --quiet
    log "Certificates renewed successfully."
}

show_main_menu() {
    echo -e "${light_green}[+]${reset} Select an option:"
    echo -e "${light_green}[+]${reset} 1. Install Certbot and Configure Apache"
    echo -e "${light_green}[+]${reset} 2. Install Certbot and Configure Nginx"
    echo -e "${light_green}[+]${reset} 3. Use Certbot in Standalone Mode"
    echo -e "${light_green}[+]${reset} 4. Renew Certificates"
    echo -e "${light_green}[+]${reset} 5. Exit"
}

main_menu() {
    while true; do
        show_main_menu
        read -p "Enter your choice: " main_choice
        
        case $main_choice in
            1|2|3)
                install_snapd
                install_certbot

                while true; do
                    read -p "Enter your email address for certificate renewal notifications: " email

                    if [[ ! "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
                        error "Invalid email address format. Example: user@example.com"
                    else
                        break
                    fi
                done

                configure_web_server "$main_choice"
                log "Certbot setup completed successfully."
                ;;
            4)
                renew_certificates
                ;;
            5)
                log "Exiting."
                exit 0
                ;;
            *)
                log "Invalid choice. Please try again."
                ;;
        esac
    done
}

main_menu
