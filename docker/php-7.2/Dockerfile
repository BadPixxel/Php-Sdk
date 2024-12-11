FROM php:7.2-apache

################################################################
# Install Varions Tools
################################################################

RUN apt-get update \
    && apt-get install --no-install-recommends -y git curl wget default-mysql-client apt-utils iputils-ping systemd gnupg2 unzip ssh rdiff-backup \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

################################################################
# Install PHP Extensions
################################################################

################################################################
# Zip | Xml | Soap | Bcmath | Mbstring | Gd
RUN apt-get update && apt-get install --no-install-recommends -y zlib1g-dev libzip-dev libxml2-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libxslt-dev \
    && docker-php-ext-install zip xml soap bcmath mbstring pdo_mysql pcntl intl exif xsl sockets \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-source delete

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
RUN pecl install mongodb-1.16.2 \
    && docker-php-ext-enable mongodb \
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