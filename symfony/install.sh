#!/bin/sh
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
echo "--> Install Symfony"
echo "----------------------------------------------------"

echo "Symfony => Build Dependencies"
composer update  --prefer-dist --no-interaction  --no-progress

echo "Symfony => Configure Database"
php bin/console doctrine:schema:update --force  --no-interaction --no-debug

echo "Symfony => Start Web Server"
php bin/console server:start

echo "Symfony => Link Symfony Test Container Xml"
find var/cache/dev/*.xml | while read -r i; do cp "$i" var/cache/dev/testContainer.xml; done
ls -l var/cache/dev/*.xml
