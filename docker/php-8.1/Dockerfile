FROM php:8.1-apache

################################################################
# Install Varions Tools
################################################################

RUN apt-get update && apt-get install --no-install-recommends -y git curl wget default-mysql-client apt-utils iputils-ping systemd gnupg2 unzip ssh rdiff-backup

################################################################
# Install PHP Extensions
################################################################

################################################################
# Zip | Xml | Soap | Bcmath | Mbstring | Gd
RUN apt-get update && apt-get install --no-install-recommends -y zlib1g-dev libzip-dev libxml2-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libmagickwand-dev libxslt-dev \
    && docker-php-ext-install zip xml soap bcmath pdo_mysql pcntl intl exif xsl sockets ftp \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-source delete \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

################################################################
# Apcu
RUN mkdir -p /usr/src/php/ext/apcu \
    && curl -fsSL https://pecl.php.net/get/apcu | tar xvz -C "/usr/src/php/ext/apcu" --strip 1 \
    && docker-php-ext-install apcu

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
RUN mkdir -p /usr/src/php/ext/mongodb \
    && curl -fsSL https://pecl.php.net/get/mongodb | tar xvz -C "/usr/src/php/ext/mongodb" --strip 1 \
    && docker-php-ext-install mongodb

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

RUN php -m

WORKDIR /var/www/html