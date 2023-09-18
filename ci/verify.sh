
################################################################################
#
#  This file is part of SplashSync Project.
#
#  Copyright (C) Splash Sync <www.splashsync.com>
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
#  For the full copyright and license information, please view the LICENSE
#  file that was distributed with this source code.
#
#  @author Bernard Paquier <contact@splashsync.com>
#
################################################################################

set -e

################################################################################
# Docker Compose Container you want to check
CONTAINERS="php-8.2,php-8.1,php-8.0,php-7.4,php-7.3,php-7.2"

################################################################################
# Start Docker Compose Stack
echo '===> Start Docker Stack'
docker-compose up -d

######################################
# Walk on Docker Compose Container
for ID in $(echo $CONTAINERS | tr "," "\n")
do
    echo "----------------------------------------------------"
    echo "===> CHECKS ON $ID"
    echo "----------------------------------------------------"
    docker-compose exec $ID composer update -q || docker-compose exec $ID composer update
    docker-compose exec $ID php vendor/bin/grumphp run --testsuite=travis
    docker-compose exec $ID php vendor/bin/grumphp run --testsuite=csfixer
    docker-compose exec $ID php vendor/bin/grumphp run --testsuite=phpstan
done
