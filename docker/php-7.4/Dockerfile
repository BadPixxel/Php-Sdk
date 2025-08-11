FROM php:7.4-apache-buster

################################################################
# Update sources.list to use archive repositories for Buster
RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list \
    && sed -i 's/security.debian.org/archive.debian.org/g' /etc/apt/sources.list \
    && sed -i '/stretch-updates/d' /etc/apt/sources.list

################################################################
# Install Varions Tools
################################################################

RUN apt-get update \
    && apt-get install --no-install-recommends -y git curl wget default-mysql-client  apt-utils iputils-ping systemd gnupg2 unzip ssh rdiff-backup \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

################################################################
# Install PHP Extensions
################################################################

################################################################
# Zip | Xml | Soap | Bcmath | Apcu | Gd
RUN apt-get update && apt-get install --no-install-recommends -y zlib1g-dev libzip-dev libxml2-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libssl-dev libxslt-dev \
    && pecl install apcu \
    && docker-php-ext-install zip xml soap bcmath pdo_mysql pcntl intl exif xsl sockets ftp \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-enable apcu \
    && docker-php-source delete \
    && pecl clear-cache \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

################################################################
# Imagick
RUN apt-get update && apt-get install -y libmagickwand-dev --no-install-recommends \
    && printf "\n" | pecl install imagick \
    && docker-php-ext-enable imagick \
    && docker-php-source delete \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

################################################################
# Mongodb
RUN pecl install mongodb-1.20.1 \
    && docker-php-ext-enable mongodb \
    && docker-php-source delete \
    && pecl clear-cache

################################################################
# Configure Php
################################################################

RUN echo "memory_limit=3G" >> /usr/local/etc/php/conf.d/memory.ini
RUN echo "apc.enable_cli=1" >> /usr/local/etc/php/conf.d/acpu.ini

################################################################
# Install Wall-E
# + Install Composer
################################################################

RUN php -r "copy('https://github.com/BadPixxel/Php-Robo/blob/1.0/bin/wall-e.phar?raw=true', '/usr/local/bin/wall-e');" \
    && chmod +x /usr/local/bin/wall-e \
    && wall-e add:composer

RUN php -m

WORKDIR /var/www/html