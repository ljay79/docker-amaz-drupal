FROM amazonlinux:2

# File Author / Maintainer
MAINTAINER ljay

# update amazon software repo
RUN set -eux; \
    yum -y update && yum -y install shadow-utils procps; \
    amazon-linux-extras install -y php8.1; \
	yum clean metadata; \
	yum -y install php-cli php-pdo php-fpm php-json php-mysqlnd php-xml; \
	yum -y install php-mbstring php-opcache php-curl php-gd php-oauth php-bcmath; \
	yum -y install php-pear php-devel; \
    yum -y install make gcc; \
    yum -y install ImageMagick ImageMagick-devel ImageMagick-perl; \
    pecl channel-update pecl.php.net && pecl update-channels; \
	printf "\n" | pecl install redis; \
    printf "\n" | pecl install imagick; \
	printf "\n" | pecl install apcu; \
    pecl install uploadprogress; \
    # Set UTC timezone
    #ln -snf /usr/share/zoneinfo/UTC /etc/localtime && echo UTC > /etc/timezone
    printf '[PHP]\ndate.timezone = "%s"\n', UTC > /etc/php.d/tzone.ini; \
    "date"

COPY --from=composer:2.7 /usr/bin/composer /usr/local/bin/

RUN set -eux; \
    [ ! -d /var/www/html ]; \
    mkdir -p /var/www/html; \
    # allow running as an arbitrary user
    groupadd -g 500 www-data; \
    useradd -d /var/www/html -s /sbin/nologin -u 500 -g 500 www-data; \
    chown -R www-data:www-data /var/www/html; \
    chmod 0775 /var/www/html; \
    # smoke test
    php --version

COPY docker-php-entrypoint /usr/local/bin/

ENTRYPOINT ["docker-php-entrypoint"]

WORKDIR /var/www/html

RUN set -eux; \
    chmod +x /usr/local/bin/docker-php-entrypoint; \
    cd /etc; \
    { \
        echo '[global]'; \
        echo 'error_log = /proc/self/fd/2'; \
        echo; \
        echo '[www]'; \
        echo '; if we send this to /proc/self/fd/1, it never appears'; \
        echo 'access.log = /proc/self/fd/2'; \
        echo; \
        echo 'clear_env = no'; \
        echo; \
        echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
        echo 'catch_workers_output = yes'; \
    } | tee php-fpm.d/docker.conf; \
    { \
        echo '[global]'; \
        echo 'daemonize = no'; \
        echo; \
        echo '[www]'; \
        echo 'listen = 9000'; \
    } | tee php-fpm.d/zz-docker.conf

# cleanup
RUN yum update -y && yum -y autoremove make gcc

# Override stop signal to stop process gracefully
# https://github.com/php/php-src/blob/17baa87faddc2550def3ae7314236826bc1b1398/sapi/fpm/php-fpm.8.in#L163
STOPSIGNAL SIGQUIT

EXPOSE 9000

CMD ["php-fpm"]
