FROM php:8.0.0RC3-apache

################################################################
# Install Varions Tools
################################################################

RUN apt-get update && apt-get install --no-install-recommends -y git curl wget default-mysql-client apt-utils iputils-ping systemd gnupg2

################################################################
# Install PHP Extensions
################################################################

# Zip | Xml | Soap | Bcmath | Mbstring | Gd
RUN apt-get update && apt-get install --no-install-recommends -y zlib1g-dev libzip-dev libxml2-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
    && docker-php-ext-install zip xml soap bcmath pdo_mysql pcntl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-source delete

# Apcu
RUN mkdir -p /usr/src/php/ext/apcu \
    && curl -fsSL https://pecl.php.net/get/apcu | tar xvz -C "/usr/src/php/ext/apcu" --strip 1 \
    && docker-php-ext-install apcu

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