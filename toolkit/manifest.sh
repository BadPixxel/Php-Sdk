#!/bin/sh
################################################################################
#
# Copyright (C) 2021 BadPixxel <www.badpixxel.com>
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
echo "--> TOOLKIT - Build Splash Manifest"
echo "----------------------------------------------------"

mkdir manifest
docker-compose exec -T toolkit php bin/console splash:server:manifest
docker-compose exec -T toolkit cat splash.json >> manifest/splash.json
docker-compose exec -T toolkit cat splash.yml >> manifest/splash.yml
