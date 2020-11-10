FROM php:7.3-apache-stretch

################################################################
# Install Varions Tools
################################################################

RUN apt-get update && apt-get install -y git curl wget mysql-client  apt-utils iputils-ping systemd gnupg2

################################################################
# Install Varions Dependencies
################################################################

#RUN apk add --update libpng-dev libzip-dev libxml2-dev

################################################################
# Install PHP Extensions
################################################################

RUN apt-get update && apt-get install -y zlib1g-dev libzip-dev libxml2-dev \
    && docker-php-ext-install zip xml soap bcmath \
    && docker-php-source delete

RUN pecl install apcu \
    && docker-php-ext-enable apcu \
    && docker-php-source delete

RUN pecl install mongodb \
    && docker-php-ext-enable mongodb \
    && docker-php-source delete


RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-source delete


RUN php -m

################################################################
# Install Composer
################################################################

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

################################################################
# Install Apache2
################################################################


WORKDIR /var/www/html