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

echo -e "\e[104m Grumphp Code Quality Tests Suite       \e[49m"

# Grumphp Travis Testsuite
php vendor/bin/grumphp run -n --testsuite=travis

# Grumphp CsFixer Testsuite
php vendor/bin/grumphp run -n --testsuite=csfixer

# Grumphp Phpstan Testsuite
php vendor/bin/grumphp run -n --testsuite=phpstan
