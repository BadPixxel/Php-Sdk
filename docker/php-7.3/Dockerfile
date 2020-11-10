FROM php:7.3-apache-stretch

################################################################
# Install Varions Tools
################################################################

RUN apt-get update && apt-get install --no-install-recommends -y git curl wget mysql-client  apt-utils iputils-ping systemd gnupg2

################################################################
# Install PHP Extensions
################################################################

# Zip | Xml | Soap | Bcmath | Mbstring
# Apcu | Mongodb | Gd
RUN apt-get update && apt-get install --no-install-recommends -y zlib1g-dev libzip-dev libxml2-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
    && pecl install apcu mongodb \
    && docker-php-ext-install zip xml soap bcmath mbstring \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-enable apcu \
    && docker-php-ext-enable mongodb \
    && docker-php-source delete \
    && pecl clear-cache

## Apcu
#RUN pecl install apcu \
#    && docker-php-source delete
## Mongodb
#RUN pecl install mongodb \
#    && docker-php-source delete
#
## Gd
#RUN apt-get update && apt-get install -y \
#        libfreetype6-dev \
#        libjpeg62-turbo-dev \
#        libpng-dev \
#    && docker-php-source delete

RUN php -m

################################################################
# Install Composer
################################################################

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

WORKDIR /var/www/html