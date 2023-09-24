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
echo "--> TOOLKIT - Install Docker Compose & Start Container"
echo "----------------------------------------------------"

echo "Docker => Git & Docker Compose"
apk add --no-cache git curl bash docker-compose

echo "Docker => Init Logs Dir"
mkdir logs

echo "Docker => Start Docker Compose"
docker network create splashsync --attachable
docker-compose up -d