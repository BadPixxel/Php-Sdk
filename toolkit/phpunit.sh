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
echo "--> TOOLKIT - Execute PHPUNIT Tests"
echo "----------------------------------------------------"

mkdir reports
docker-compose exec -T toolkit php vendor/bin/phpunit --log-junit test-report.xml
docker cp "$(docker-compose ps -q toolkit)":/app/test-report.xml  reports/test-report.xml
