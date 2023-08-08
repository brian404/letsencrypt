## SSL Certificate Installer

This script automates the process of setting up an SSL certificate on your server using Certbot. It prompts you to choose between Apache and Nginx as your web server and then configures the SSL certificate accordingly.

### Instructions

1. Clone this repository to your server:

```bash
git clone https://github.com/brian404/ssl-cert-installer.git


cd ssl-cert-installer

chmod +x setup_ssl.sh

./setup_ssl.sh

#Follow the prompts to select your web server (Apache or Nginx) and let the script handle the SSL certificate setup.


