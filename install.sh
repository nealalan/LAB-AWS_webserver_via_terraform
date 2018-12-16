#!/bin/bash

###############################################################################
### Neal Dreher / nealalan.com / nealalan.github.io/tf-201812-nealalan.com
### Recreate nealalan.* & neonaluminum.* on Ubuntu (AWS EC2)
### 2018-12-06
###
### Something I like to do after install is edit the ~/.bashrc PS1= statment to include (\D{%F %T}) at the beginning
###
###############################################################################

## check for remote package updated and refresh the local package reference
sudo apt -y update
sudo apt -y upgrade

# nginx might already be installed...
sudo apt install -y nginx

# overwrite the generic ip-###-##-##-### hostname
echo "nealalan.com" | sudo tee /etc/hostname

# add domain names as localhosts
sudo sed -i '1s/^/127.0.0.1 nealalan.com\n/' /etc/hosts
sudo sed -i '1s/^/127.0.0.1 www.nealalan.com\n/' /etc/hosts
sudo sed -i '1s/^/127.0.0.1 neonaluminum.com\n/' /etc/hosts
sudo sed -i '1s/^/127.0.0.1 www.neonaluminum.com\n/' /etc/hosts

# certbot
sudo add-apt-repository -y ppa:certbot/certbot
sudo apt -y update
sudo apt -y upgrade
sudo apt -y install python-certbot-nginx

# Configure NGINX webserver files
sudo mkdir -p /var/www/nealalan.com/html
sudo mkdir -p /var/www/neonaluminum.com/html
ln -s /var/www/nealalan.com/html /home/ubuntu/nealalan.com
ln -s /var/www/neonaluminum.com/html /home/ubuntu/neonaluminum.com
sudo chown -R ubuntu:ubuntu /var/www/nealalan.com/html
sudo chown -R ubuntu:ubuntu /var/www/neonaluminum.com/html
ln -s /etc/nginx/sites-available /home/ubuntu/sites-available
ln -s /etc/nginx/sites-enabled /home/ubuntu/sites-enabled


sudo tee -a /home/ubuntu/sites-available/nealalan.com << END
server {
	listen 80;
	server_name nealalan.com www.nealalan.com;
}
server {
	listen 443 ssl; # managed by Certbot
	server_name nealalan.com www.nealalan.com;

	#  HTTP Strict Transport Security (HSTS) within the 443 SSL server block.
	add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
	# Server_tokens off
	server_tokens off;
	# Disable content-type sniffing on some browsers
	add_header X-Content-Type-Options nosniff;
	# Set the X-Frame-Options header to same origin
	add_header X-Frame-Options SAMEORIGIN;
	# enable cross-site scripting filter built in, See: https://www.owasp.org/index.php/List_of_useful_HTTP_headers
	add_header X-XSS-Protection "1; mode=block";
	# disable sites with potentially harmful code, See: https://content-security-policy.com/
	add_header Content-Security-Policy "default-src 'self'; script-src 'self' ajax.googleapis.com; object-src 'self';";
	# referrer policy
	add_header Referrer-Policy "no-referrer-when-downgrade";
  # Feature Policy will allow a site to enable or disable certain browser features and APIs in the interest of better security and privacy
  #Feature-Policy: vibrate 'self'; usermedia *; sync-xhr 'self' https://nealalan.com
	# certificate transparency, See: https://thecustomizewindows.com/2017/04/new-security-header-expect-ct-header-nginx-directive/
	add_header Expect-CT max-age=3600;
	# HTML folder
	root /var/www/nealalan.com/html;
	index index.html;
}
END

sudo tee -a /home/ubuntu/sites-available/neonaluminum.com << END
server {
	listen 80;
	server_name neonaluminum.com www.neonaluminum.com;
}
server {
	listen 443 ssl; # managed by Certbot
	server_name neonaluminum.com www.neonaluminum.com;
	#  HTTP Strict Transport Security (HSTS) within the 443 SSL server block.
	add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
	# Server_tokens off
	server_tokens off;
	# Disable content-type sniffing on some browsers
	add_header X-Content-Type-Options nosniff;
	# Set the X-Frame-Options header to same origin
	add_header X-Frame-Options SAMEORIGIN;
	# enable cross-site scripting filter built in, See: https://www.owasp.org/index.php/List_of_useful_HTTP_headers
	add_header X-XSS-Protection "1; mode=block";
	# disable sites with potentially harmful code, See: https://content-security-policy.com/
	add_header Content-Security-Policy "default-src 'self'; script-src 'self' ajax.googleapis.com; object-src 'self';";
	# referrer policy
	add_header Referrer-Policy "no-referrer-when-downgrade";
  # Feature Policy will allow a site to enable or disable certain browser features and APIs in the interest of better security and privacy
  #Feature-Policy: vibrate 'self'; usermedia *; sync-xhr 'self' https://neonaluminum.com
	# certificate transparency, See: https://thecustomizewindows.com/2017/04/new-security-header-expect-ct-header-nginx-directive/
	add_header Expect-CT max-age=3600;
	# HTML folder
	root /var/www/neonaluminum.com/html;
	index index.html;
}
END

sudo rm /home/ubuntu/sites-enabled/default

# CREATE LINKS FROM SITES-AVAILABLE TO SITES-ENABLED
sudo ln -s /etc/nginx/sites-available/nealalan.com /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/neonaluminum.com /etc/nginx/sites-enabled/

# restart NGINX
echo sudo systemctl kill nginx
sudo systemctl kill nginx

# RUN CERTBOT for all domains
#   https://certbot.eff.org/docs/using.html#certbot-commands
#
# Note: if you missed some and need to run again you will need to run 'ps aux' to get
#       the nginx process and use 'sudo kill <pid>' on the nginx main process
#       Next, run the same command with --expand on the end
echo
echo sudo certbot --authenticator standalone --installer nginx -d nealalan.com -d www.nealalan.com -d neonaluminum.com -d www.neonaluminum.com --pre-hook 'sudo service nginx stop' --post-hook 'sudo service nginx start' -m neal@nealalan.com --agree-tos --eff-email --redirect -q
sudo certbot --authenticator standalone --installer nginx -d nealalan.com -d www.nealalan.com -d neonaluminum.com -d www.neonaluminum.com --pre-hook 'sudo service nginx stop' --post-hook 'sudo service nginx start' -m neal@nealalan.com --agree-tos --eff-email --redirect -q

# Ensure the latest git api is installed
sudo apt install git

# pull the websites from github down to the webserver
git clone https://github.com/nealalan/nealalan.com.git /home/ubuntu/nealalan.com
git clone https://github.com/nealalan/neonaluminum.com.git /home/ubuntu/neonaluminum.com

# install speedtest command; toilet text formatter
sudo apt install -y speedtest-cli toilet

# OPTIONAL
sudo reboot
