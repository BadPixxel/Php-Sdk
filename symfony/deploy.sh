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
echo "--> Deploy Symfony"
echo "----------------------------------------------------"

if [ -f "tests/config/parameters.yml.dist" ];
then
  echo "Symfony => Configuring Parameters"
  cp tests/config/parameters.yml.dist tests/config/parameters.yml
fi;

if [ -f "app/config/parameters.yml.dist" ];
then
  echo "Symfony => Configuring Parameters"
  cp app/config/parameters.yml.dist app/config/parameters.yml
fi;

if [ -f ".env.dist" ];
then
  echo "Symfony => Configuring DotEnv"
  cp .env.dist .env
fi;

if [ ! -f "bin" ];
then
  echo "Symfony => Create Bin Dir"
  mkdir bin
fi;

if [ -f "tests/console" ];
then
  echo "Symfony => Configuring Console"
  cp tests/console bin/console
fi;

if [ -d "tests/public" ];
then
  echo "Symfony => Configuring Public Folder"
  mkdir public
  cp tests/public/* public
  cp tests/public/.htaccess public/.htaccess
fi;