# image à utiliser
FROM php:7.1-apache

# On envoie le nom du serveur à apache, c'est avec ça que l'on appelera nos pages
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Quelques library necessaires
RUN apt-get update \
    && apt-get install -y --no-install-recommends locales \
       apt-utils \
       git \
       libicu-dev \
       g++ \
       libpng-dev \
       libzip-dev \
       zip

# les locales, toujours utiles
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen

# On copie le php.ini du repertoire actuel dans le contenaire
# COPY php.ini /usr/local/etc/php/php.ini
RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
RUN echo "date.timezone =\"Europe/Paris\"" >> /usr/local/etc/php/php.ini
RUN echo "error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT" >> /usr/local/etc/php/php.ini
RUN echo "error_log = /var/www/log/php71_errors.log" >> /usr/local/etc/php/php.ini

# Quelques extesnions de php utiles
RUN docker-php-ext-configure intl
RUN docker-php-ext-install mysqli pdo pdo_mysql gd opcache intl calendar zip
# RUN pecl install apcu-5.1.5 && docker-php-ext-enable apcu

#setup composer
RUN curl -sS https://getcomposer.org/installer | php \
        && mv composer.phar /usr/local/bin/ \
        && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

RUN a2enmod rewrite
RUN a2enmod ssl

# On créé un utilisateur avec le même gid/uid que votre local
# cela va permettre que les fichiers qui sont créés dans le contenaire auront vos droits
RUN addgroup --system gponty --gid 1000 && adduser --system gponty --uid 1000 --ingroup gponty


RUN echo "error_log2 = /var/www/log/php71_errors.log" >> /usr/local/etc/php/php.ini

# le repertoire qui contient vos sources (attention : dans le contenaire, donc le repertoire à droite du mapping du docker-compose)
WORKDIR /var/www/
