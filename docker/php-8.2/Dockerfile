
################################################################################
# Image Arguments
# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG PHP_VERSION=8.2
ARG TARGETPLATFORM

################################################################################
# "php" stage
FROM --platform=$BUILDPLATFORM dunglas/frankenphp:php${PHP_VERSION}-alpine

################################################################
# Install Varions Tools
################################################################

RUN apk add --no-cache bash git make curl wget iputils busybox-extras openssh unzip rdiff-backup

################################################################
# Install PHP Extensions
################################################################

#################################################################################
## Install Php Extensions
RUN install-php-extensions intl zip soap opcache apcu xml bcmath pcntl exif xsl sockets ftp gd imagick
RUN install-php-extensions @composer pdo_mysql pdo_sqlite mongodb

################################################################################
# Configure Caddy Webserver
ENV CADDY_GLOBAL_OPTIONS="auto_https disable_redirects"
ARG SERVER_ROOT=/var/www/html
ENV SERVER_NAME=":80"

################################################################
# Configure Php
################################################################

RUN echo "memory_limit=3G" >> /usr/local/etc/php/conf.d/memory.ini
RUN echo "apc.enable_cli=1" >> /usr/local/etc/php/conf.d/acpu.ini

################################################################
# Install Wall-E
################################################################

RUN php -r "copy('https://github.com/BadPixxel/Php-Robo/blob/2.0/bin/wall-e.phar?raw=true', '/usr/local/bin/wall-e');" \
    && chmod +x /usr/local/bin/wall-e

RUN php -m

WORKDIR /var/www/html