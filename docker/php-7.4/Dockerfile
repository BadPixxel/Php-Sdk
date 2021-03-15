FROM php:7.4-apache-buster

################################################################
# Install Varions Tools
################################################################

RUN apt-get update && apt-get install --no-install-recommends -y git curl wget default-mysql-client  apt-utils iputils-ping systemd gnupg2

################################################################
# Install PHP Extensions
################################################################

# Zip Xml Soap Bcmath
RUN apt-get update && apt-get install --no-install-recommends -y zlib1g-dev libzip-dev libxml2-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libmagickwand-dev \
    && pecl install apcu mongodb imagick \
    && docker-php-ext-install zip xml soap bcmath pdo_mysql pcntl intl exif \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-enable apcu \
    && docker-php-ext-enable mongodb \
    && docker-php-ext-enable imagick \
    && docker-php-source delete \
    && pecl clear-cache

RUN php -m

################################################################
# Configure Php
################################################################

RUN echo "memory_limit=3G" >> /usr/local/etc/php/conf.d/memory.ini

################################################################
# Install Composer
################################################################

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

WORKDIR /var/www/html