# Apache2
sudo apt-get install -y apache2
sudo systemctl enable apache2.service
sudo ufw allow 80/tcp comment 'accept Apache'
sudo ufw allow 443/tcp comment 'accept HTTPS connections'

# PHP on Ubuntu 20.04
sudo apt install -y php php-cli php-fpm php-json php-common php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath
sudo apt install -y php7.4-fpm
sudo apt install -y libapache2-mod-fcgid
sudo apt install -y php-intl php-mysqli php-pdo php-opcache php-calendar

# Configure Apache
sudo a2enmod proxy_fcgi setenvif
sudo a2enconf php7.4-fpm

# sudo apt-get install -y \
#     libfreetype6-dev \
#     libjpeg62-turbo-dev

# Quelques extesnions de php utiles
# sudo docker-php-ext-configure gd --with-freetype --with-jpeg
# sudo docker-php-ext-configure intl
# sudo docker-php-ext-install mysqli pdo pdo_mysql gd opcache intl
# sudo docker-php-ext-install calendar
# sudo docker-php-ext-install zip
# sudo pecl install apcu-5.1.5 && docker-php-ext-enable apcu
# sudo docker-php-ext-enable intl opcache

# Installation du client Symfony
sudo wget https://get.symfony.com/cli/installer -O - | bash
# sudo mv /root/.symfony/bin/symfony /usr/local/bin/symfony
sudo ls ${HOME}/.symfony/bin/
sudo mv ${HOME}/.symfony/bin/symfony /usr/local/bin/symfony

sudo apt-get install -y curl

# Setup Composer
export COMPOSER_ALLOW_SUPERUSER=1
sudo curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
sudo composer --version

# sudo curl -sO https://gordalina.github.io/cachetool/downloads/cachetool-3.2.2.phar \
#  && mv cachetool-3.2.2.phar /usr/local/bin/ \
#  && ln -s /usr/local/bin/cachetool-3.2.2.phar /usr/local/bin/cachetool \
#  && chmod +x /usr/local/bin/cachetool

# On copie le php.ini du repertoire actuel dans le conteneur
cp /mnt/c/dev/docker/docker-project/ubuntu/php.ini /etc/php/7.4/mods-available/app.ini
#  sudo cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini

# Active la configuration Optimind
sudo phpenmod app

# Configure Apache
sudo a2enmod rewrite
sudo a2enmod ssl
sudo a2enmod proxy proxy_http
sudo a2enmod headers

# Manually set up the apache environment variables
export APACHE_RUN_USER www-data
export APACHE_RUN_GROUP www-data
export APACHE_LOG_DIR /var/log/apache2
export APACHE_LOCK_DIR /var/lock/apache2
export APACHE_PID_FILE /var/sudo/apache2.pid

cp /mnt/c/dev/docker/docker-project/ubuntu/apache2.conf /etc/apache2/conf-enabled/optimind-apache2.conf

# Node 10 (not supported)
sudo curl -sL https://deb.nodesource.com/setup_10.x | bash -
sudo apt-get install -y nodejs
sudo apt-get install -y python npm gulp
sudo npm install -g n
sudo n install 10.20.1
sudo npm install gulp -g
