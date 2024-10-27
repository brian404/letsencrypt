
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
            log "Advanced option selected. Please specify your web server type:"
            echo -e "${light_green}[+]${reset} 1. Lighttpd"
            echo -e "${light_green}[+]${reset} 2. Caddy"
            echo -e "${light_green}[+]${reset} 3. HAProxy"
            echo -e "${light_green}[+]${reset} 4. Custom Web Server"
            read -p "Enter your choice (1-4): " advanced_choice

            case $advanced_choice in
                1)
                    log "Running certbot for Lighttpd..."
                    sudo certbot certonly --webroot -w /var/www/lighttpd -d yourdomain.com --agree-tos --non-interactive --email "$email"
                    ;;
                2)
                    log "Running certbot for Caddy..."
                    sudo certbot certonly --standalone -d yourdomain.com --agree-tos --non-interactive --email "$email"
                    ;;
                3)
                    log "Running certbot for HAProxy..."
                    sudo certbot certonly --standalone -d yourdomain.com --agree-tos --non-interactive --email "$email"
                    ;;
                4)
                    log "For a custom web server, use the following instructions:"
                    log "To manually obtain and install certificates for custom web servers:"
                    log "1. Obtain a certificate using certbot in standalone or webroot mode:"
                    log "   - Standalone: sudo certbot certonly --standalone -d yourdomain.com"
                    log "   - Webroot: sudo certbot certonly --webroot -w /path/to/webroot -d yourdomain.com"
                    log "2. Follow the documentation for your specific web server to configure SSL."
                    log "Refer to the Certbot documentation for further guidance: https://certbot.eff.org/docs/"
                    exit 0
                    ;;
                *)
                    log "Invalid choice for advanced web server selection."
                    exit 1
                    ;;
            esac
            ;;
        *)
            log "Invalid choice."
            exit 1
            ;;
    esac
}

show_main_menu() {
    echo -e "${light_green}[+]${reset} Select an option:"
    echo -e "${light_green}[+]${reset} 1. Install Certbot and Configure Web Server"
    echo -e "${light_green}[+]${reset} 2. Exit"
}

main_menu() {
    while true; do
        show_main_menu
        read -p "Enter your choice: " main_choice
        
        case $main_choice in
            1)
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

                echo -e "${light_green}[+]${reset} Select your web server:"
                echo -e "${light_green}[+]${reset} 1. Apache"
                echo -e "${light_green}[+]${reset} 2. Nginx"
                echo -e "${light_green}[+]${reset} 3. Advanced (Custom Web Server)"
                read -p "Enter your choice (1, 2, or 3): " choice

                configure_web_server "$choice"

                log "Certbot setup completed successfully."
                ;;
            2)
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
