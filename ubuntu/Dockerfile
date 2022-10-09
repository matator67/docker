# image à utiliser
FROM ubuntu:22.04

## for apt to be noninteractive
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

# Quelques library necessaires
RUN apt update
RUN apt-get update
# RUN apt upgrade
RUN apt-get install -y --no-install-recommends locales \
       apt-utils \
       systemd \
       git \
       libicu-dev \
       g++ \
       libpng-dev \
       libzip-dev \
       wget \
       nano \
       zip

RUN apt-get install -y ufw curl

## preesed tzdata, update package index, upgrade packages and install needed software
RUN echo "tzdata tzdata/Areas select Europe" > /tmp/preseed.txt; \
    echo "tzdata tzdata/Zones/Europe select Paris" >> /tmp/preseed.txt; \
    debconf-set-selections /tmp/preseed.txt && \
    apt-get update && \
    apt-get install -y tzdata

# Apache2
RUN apt-get install -y apache2
RUN systemctl enable apache2.service
RUN ufw allow 80/tcp comment 'accept Apache'
RUN ufw allow 443/tcp comment 'accept HTTPS connections'

# PHP on Ubuntu 22.04
RUN apt-get install -y software-properties-common ca-certificates lsb-release apt-transport-https 
RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php 
RUN apt update

# RUN apt-get install -y php php-cli php-fpm php-json php-common php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath
# RUN apt upgrade
RUN apt install -y php7.4 php7.4-common libapache2-mod-php7.4
RUN apt install -y php7.4-fpm libapache2-mod-fcgid
# RUN apt install -y php-intl php-mysqli php-pdo php-opcache php-calendar
RUN apt-get install -y php7.4-intl php7.4-json php7.4-mysql php7.4-zip php7.4-gd php7.4-mbstring php7.4-curl php7.4-xml
RUN apt-get install -y php7.4-bcmath

# NodeJS
RUN apt-get install -y nodejs npm gulp

# Configure Apache
RUN a2enmod proxy_fcgi setenvif
RUN a2enconf php7.4-fpm

# Installation du client Symfony
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | sudo -E bash
RUN apt install symfony-cli

# Setup Composer
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer --version

# Active la configuration Optimind
RUN phpenmod app

# Configure Apache
RUN a2enmod rewrite
RUN a2enmod ssl
RUN a2enmod proxy proxy_http
RUN a2enmod headers

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

# On copie le php.ini du repertoire actuel dans le conteneur
COPY php.ini /etc/php/7.4/mods-available/app.ini
COPY apache2.conf /etc/apache2/conf-enabled/optimind-apache2.conf

# Gulp
RUN npm install gulp -g
RUN npm install -g yarn

RUN apt-get install -y rsync cron 
# RUN apt-get install -y inotify-tools
COPY rsync-perso.sh /root/rsync-perso.sh

ARG GIT_USERNAME
ARG GIT_PASSWORD

# Configuration Git
RUN composer config --global http-basic.github.com $GIT_USERNAME $GIT_PASSWORD

# Copy les fichiers de conf SSH
RUN apt-get install -y ssh
RUN mkdir /root/.ssh/
COPY ssh_config/* /root/.ssh/
COPY ssh_config/_perso.config /root/.ssh/config
RUN chmod 400 /root/.ssh/*

RUN apt-get install -y dos2unix
RUN dos2unix /root/rsync-perso.sh

# Autorise l'accès à la session
RUN chmod 777 /var/lib/php/sessions

# Envrionnement developpement
ENV SYMFONY_PROJECT none
COPY msync.sh /root/msync.sh
COPY run.sh /root/run.sh
ENV PATH $PATH:/root/
RUN dos2unix /root/msync.sh
RUN dos2unix /root/run.sh
RUN chmod +x /root/msync.sh
RUN chmod +x /root/run.sh

# RUN echo PS1='\[\033[1;36m\]\u\[\033[1;31m\]@\[\033[1;32m\]\h:\[\033[1;35m\]\w\[\033[1;31m\]\$\[\033[0m\]' >> /root/.bashrc

RUN wget https://cs.symfony.com/download/php-cs-fixer-v3.phar -O php-cs-fixer
RUN chmod a+x php-cs-fixer
RUN mv php-cs-fixer /usr/local/bin/php-cs-fixer

# le repertoire qui contient vos sources (attention : dans le conteneur, donc le repertoire à droite du mapping du docker-compose)
WORKDIR /var/www/

# By default start up apache in the foreground, override with /bin/bash for interative.
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
