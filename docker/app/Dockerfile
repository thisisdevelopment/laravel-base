FROM php:7.4-fpm AS php-build

ENV PHP_EXTENSIONS="bcmath calendar exif gettext imagick intl mysqli opcache pcntl pdo_mysql redis soap sockets xdebug zip"

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/
RUN install-php-extensions ${PHP_EXTENSIONS}
RUN apt-get install unzip && apt-get purge -y ${PHPIZE_DEPS} && apt-get autoremove -y --purge

COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY --from=nginx:stable /usr/sbin/nginx* /usr/sbin/
COPY --from=nginx:stable /usr/lib/nginx /usr/lib/nginx
COPY --from=nginx:stable /etc/nginx /etc/nginx
COPY --from=node:latest /usr/local /usr/local
COPY --from=node:latest /opt/yarn* /opt/

RUN set -eux; \
    curl -Lo s6.tar.gz https://github.com/just-containers/s6-overlay/releases/download/v1.22.1.0/s6-overlay-amd64.tar.gz; \
    tar -x -C / -f s6.tar.gz; \
    rm s6.tar.gz; \
    rm -rf /var/lib/apt/lists/*; \
    ln -s /usr/local/etc/php /etc/php; \
    rm /etc/php/conf.d/docker-php-ext-xdebug.ini; \
    mv /etc/php/php.ini-production /etc/php/php.ini; \
    rm -rf /var/www/html; \
    mkdir -p /var/log/nginx /var/cache/nginx; \
    composer global remove hirak/prestissimo;

COPY files /

WORKDIR /var/www
ENTRYPOINT ["/init"]
