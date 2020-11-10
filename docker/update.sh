########################################################
# Connect Docker to GitLab
docker login https://registry.gitlab.com -u BadPixxel
########################################################
# [PHP-7.3] Build & Upload Splash Docker Image
docker build -t registry.gitlab.com/badpixxel/php-sdk:php-7.3 docker/php-7.3
docker push registry.gitlab.com/badpixxel/php-sdk:php-7.3
