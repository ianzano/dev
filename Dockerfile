FROM php:latest

USER ${USER}

VOLUME /data
WORKDIR /data

RUN \
  apt-get update && \
  apt-get install -y git zip unzip zlib1g-dev libzip-dev nodejs npm && \
  pecl install xdebug && \
  docker-php-ext-install zip && \
  docker-php-ext-enable xdebug

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

COPY --chown=$USER:$GROUP docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]