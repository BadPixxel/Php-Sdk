FROM php:7.4-apache-buster

################################################################
# Install Varions Tools
################################################################

RUN apt-get update && apt-get install --no-install-recommends -y git curl wget default-mysql-client  apt-utils iputils-ping systemd gnupg2 unzip ssh rdiff-backup

################################################################
# Install PHP Extensions
################################################################

# Zip | Xml | Soap | Bcmath
# Apcu | Mongodb | Gd | Imagick
RUN apt-get update && apt-get install --no-install-recommends -y zlib1g-dev libzip-dev libxml2-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libmagickwand-dev libxslt-dev \
    && pecl install apcu mongodb imagick \
    && docker-php-ext-install zip xml soap bcmath pdo_mysql pcntl intl exif xsl sockets ftp \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-enable apcu \
    && docker-php-ext-enable mongodb \
    && docker-php-ext-enable imagick \
    && docker-php-source delete \
    && pecl clear-cache \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN php -m

################################################################
# Configure Php
################################################################

RUN echo "memory_limit=3G" >> /usr/local/etc/php/conf.d/memory.ini

################################################################
# Install Wall-E
# + Install Composer
################################################################

RUN php -r "copy('https://github.com/BadPixxel/Php-Robo/blob/main/bin/wall-e.phar?raw=true', '/usr/local/bin/wall-e');" \
    && chmod +x /usr/local/bin/wall-e \
    && wall-e add:composer

WORKDIR /var/www/html