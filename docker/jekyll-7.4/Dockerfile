FROM php:7.4-apache

################################################################
# Install Various Tools
################################################################

RUN apt-get update \
    && apt-get install --no-install-recommends -y git curl wget default-mysql-client apt-utils iputils-ping systemd gnupg2 ca-certificates rsync subversion \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

################################################################
# Install PHP Extensions
################################################################

# Zip | Xml | Soap | Bcmath
# Apcu | Mongodb | Gd | Imagick
RUN apt-get update && apt-get install --no-install-recommends -y zlib1g-dev libzip-dev libxml2-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libmagickwand-dev libxslt-dev \
    && pecl install apcu mongodb imagick \
    && docker-php-ext-install zip xml soap bcmath pdo_mysql pcntl intl exif xsl sockets \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-enable apcu \
    && docker-php-ext-enable mongodb \
    && docker-php-ext-enable imagick \
    && docker-php-source delete \
    && pecl clear-cache \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


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


################################################################################
# Install Ruby Full
RUN apt-get update && apt-get install ruby-full build-essential zlib1g-dev -y -q \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

################################################################################
# Install & Config Gems
RUN echo '# Install Ruby Gems to ~/gems' >> ~/.bashrc \
    echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc \
    echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.bashrc \
    source ~/.bashrc

################################################################################
# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt update && apt install yarn -y -q \
    && yarn --version \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

################################################################################
# Install Jekyll
RUN gem install jekyll bundler

WORKDIR /var/www/html