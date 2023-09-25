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
docker cp "$(docker-compose ps -q toolkit)":/app/splash.json  $CI_PROJECT_DIR/manifest/splash.json
docker cp "$(docker-compose ps -q toolkit)":/app/splash.yml   $CI_PROJECT_DIR/manifest/splash.yml
