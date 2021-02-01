# Docker image for PHP-FPM 7.4x on a Amazon Linux2 OS for Drupal 9

[![](https://images.microbadger.com/badges/image/ljay/amaz-drupal.svg)](http://microbadger.com/images/ljay/amaz-drupal)

[![Docker build](http://dockeri.co/image/ljay/amaz-drupal)](https://hub.docker.com/r/ljay/amaz-drupal/)

This repo creates a Docker image for PHP-FPM running on Amazon Linux 2 used for Drupal..
Customized for ECS load-balances environment with nginx, redis backend cache, ..
Composer v2.0.8 installed.

Use with caution!

## PHP versions

Version | Git branch | Tag name
--------| ---------- |---------
7.4.11  | php-fpm    | php-fpm


# Build and Test

run and output php modules
```sh
docker run -it drupal-php php -m
```

run test script
```sh
docker run -it -v ${PWD}:/var/www/html drupal-php \
    php php-info.php
```

check ImageMagick version
```sh
docker run -it drupal-php convert -version
```
