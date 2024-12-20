
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

echo "[PHP 8.1] Build & Upload Docker Image"
docker build -t registry.gitlab.com/badpixxel-projects/php-sdk:php-8.1 docker/php-8.1
docker push registry.gitlab.com/badpixxel-projects/php-sdk:php-8.1

echo "[PHP 8.2] Build & Upload Docker Image"
docker build -t registry.gitlab.com/badpixxel-projects/php-sdk:php-8.2 docker/php-8.2
docker push registry.gitlab.com/badpixxel-projects/php-sdk:php-8.2

echo "[PHP 8.3] Build & Upload Docker Image"
docker build -t registry.gitlab.com/badpixxel-projects/php-sdk:php-8.3 docker/php-8.3
docker push registry.gitlab.com/badpixxel-projects/php-sdk:php-8.3

echo "[JEKYLL] Build & Upload Docker Image"
docker build -t registry.gitlab.com/badpixxel-projects/php-sdk:jekyll docker/jekyll
docker push registry.gitlab.com/badpixxel-projects/php-sdk:jekyll

echo "[JEKYLL PHP 7.4] Build & Upload Docker Image"
docker build -t registry.gitlab.com/badpixxel-projects/php-sdk:jekyll-7.4 docker/jekyll-7.4
docker push registry.gitlab.com/badpixxel-projects/php-sdk:jekyll-7.4