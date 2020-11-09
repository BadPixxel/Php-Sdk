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

echo -e "\e[104m Configure for Symfony                  \e[49m"

# Setup Symfony Version if Required  
if [ "$SF_VERSION" != "" ];
then
  echo "Symfony => Update to Symfony $SF_VERSION";
  composer require --no-update symfony/symfony=$SF_VERSION;
fi;

# Create Database
echo "Symfony => Create Database (symfony)"
mysql -e 'CREATE DATABASE IF NOT EXISTS symfony;'
