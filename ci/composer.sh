#!/bin/bash
################################################################################
#
# Copyright (C) 2020 BadPixxel <www.badpixxel.com>
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#
################################################################################

echo "----------------------------------------------------"
echo "--> Install Composer Dependencies"
echo "----------------------------------------------------"

################################################################################
# Verify Composer is Installed
if ! command -v composer &> /dev/null
then
  echo "Composer => Installation Required"
  echo "allow_url_fopen=On" >> /usr/local/etc/php/php.ini
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  php composer-setup.php --install-dir=/usr/local/bin --filename=composer
  php -r "unlink('composer-setup.php');"
fi


echo "Composer => Update"
composer update  --prefer-dist --no-interaction --no-progress
