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

echo "==> Config Travis"

echo "Composer => Force Composer 2";
composer self-update --2;

# Setup Travis PHP     
if [ "$TRAVIS_PHP_VERSION" != "hhvm" ];
then
  echo "Composer => Force Memory Limit";
  echo "memory_limit = -1" >> ~/.phpenv/versions/$(phpenv version-name)/etc/conf.d/travis.ini;
fi

# Setup Composer Stability if Required
if ! [ -z "$STABILITY" ];
then
  echo "Composer => Force minimum-stability ${STABILITY}";
  composer config minimum-stability ${STABILITY};
fi;
