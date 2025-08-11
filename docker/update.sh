
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
docker buildx build -t registry.gitlab.com/badpixxel-projects/php-sdk:php-7.2 docker/php-7.2                   --push

echo "[PHP 7.3] Build & Upload Docker Image"
docker buildx build -t registry.gitlab.com/badpixxel-projects/php-sdk:php-7.3 docker/php-7.3                   --push

echo "[PHP 7.4] Build & Upload Docker Image"
docker buildx build -t registry.gitlab.com/badpixxel-projects/php-sdk:php-7.4 docker/php-7.4                   --push

echo "[PHP 8.0] Build & Upload Docker Image"
docker buildx build -t registry.gitlab.com/badpixxel-projects/php-sdk:php-8.0 docker/php-8.0                   --push

echo "[PHP 8.1] Build & Upload Docker Image"
docker buildx build -t registry.gitlab.com/badpixxel-projects/php-sdk:php-8.1          docker/php-8.1          --push

echo "[PHP 8.2] Build & Upload Docker Image"
docker buildx build -t registry.gitlab.com/badpixxel-projects/php-sdk:php-8.2          docker/php-8.2          --push
docker buildx build -t registry.gitlab.com/badpixxel-projects/php-sdk:php-8.2-apache   docker/php-8.2-apache   --push

echo "[PHP 8.3] Build & Upload Docker Image"
docker buildx build -t registry.gitlab.com/badpixxel-projects/php-sdk:php-8.3          docker/php-8.3          --push
docker buildx build -t registry.gitlab.com/badpixxel-projects/php-sdk:php-8.3-apache   docker/php-8.3-apache   --push

echo "[PHP 8.4] Build & Upload Docker Image"
docker buildx build -t registry.gitlab.com/badpixxel-projects/php-sdk:php-8.4          docker/php-8.4          --push
docker buildx build -t registry.gitlab.com/badpixxel-projects/php-sdk:php-8.4-apache   docker/php-8.4-apache   --push

echo "[JEKYLL] Build & Upload Docker Image"
docker buildx build -t registry.gitlab.com/badpixxel-projects/php-sdk:jekyll docker/jekyll                     --push

echo "[JEKYLL PHP 7.4] Build & Upload Docker Image"
docker buildx build -t registry.gitlab.com/badpixxel-projects/php-sdk:jekyll-7.4 docker/jekyll-7.4             --push
