FROM php:7.4-fpm AS php-build

ARG USER_ID=1000
ARG GROUP_ID=1000

ENV PHP_EXTENSIONS="bcmath calendar exif gettext imagick intl mysqli opcache pcntl pdo_mysql redis soap sockets xdebug zip"

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/
RUN install-php-extensions ${PHP_EXTENSIONS}
RUN apt-get update && apt-get install unzip && apt-get purge -y ${PHPIZE_DEPS} && apt-get autoremove -y --purge

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
    composer global require hirak/prestissimo;

COPY files /

RUN if getent passwd www-data ; then userdel -f www-data; fi &&\
    if getent group www-data ; then groupdel www-data; fi &&\
    groupadd -g ${GROUP_ID} www-data &&\
    useradd -l -u ${USER_ID} -g www-data www-data &&\
    install -d -m 0755 -o www-data -g www-data /home/www-data &&\
    chown --changes --silent --no-dereference --recursive \
            --from=33:33 ${USER_ID}:${GROUP_ID} \
            /home/www-data \
            /var/www

WORKDIR /var/www

ENTRYPOINT ["/entrypoint.sh"]
