
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

echo "[PHP 7.2] Build & Upload Docker Image"
docker build -t registry.gitlab.com/badpixxel-projects/php-sdk:php-7.2 docker/php-7.2
docker push registry.gitlab.com/badpixxel-projects/php-sdk:php-7.2

echo "[PHP 7.3] Build & Upload Docker Image"
docker build -t registry.gitlab.com/badpixxel-projects/php-sdk:php-7.3 docker/php-7.3
docker push registry.gitlab.com/badpixxel-projects/php-sdk:php-7.3

echo "[PHP 7.4] Build & Upload Docker Image"
docker build -t registry.gitlab.com/badpixxel-projects/php-sdk:php-7.4 docker/php-7.4
docker push registry.gitlab.com/badpixxel-projects/php-sdk:php-7.4

echo "[PHP 8.0] Build & Upload Docker Image"
docker build -t registry.gitlab.com/badpixxel-projects/php-sdk:php-8.0 docker/php-8.0
docker push registry.gitlab.com/badpixxel-projects/php-sdk:php-8.0

echo "[PAGES] Build & Upload Docker Image"
docker build -t registry.gitlab.com/badpixxel-projects/php-sdk:pages docker/pages
docker push registry.gitlab.com/badpixxel-projects/php-sdk:pages