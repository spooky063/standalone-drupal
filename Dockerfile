# syntax=docker/dockerfile:1

ARG PHP_VERSION=8.4

FROM php:${PHP_VERSION}-cli-alpine AS common

RUN apk update \
    && apk upgrade \
    && apk add \
        $PHPIZE_DEPS \
        unzip \
        git \
        curl \
        icu-dev \
        libzip-dev \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        mysqli \
        exif \
        zip \
        intl \
        gd \
    && apk del --purge $PHPIZE_DEPS \
    && rm -rf /var/cache/apk/* /usr/share/doc /usr/share/man /tmp/*

FROM common AS builder

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_MEMORY_LIMIT=-1

WORKDIR /app

ARG DRUPAL_VERSION=11
RUN \
	composer create-project "drupal-composer/drupal-project:${DRUPAL_VERSION}" . --no-interaction; \
	composer clear-cache

FROM common AS runner

RUN apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    linux-headers

ARG XDEBUG_VERSION=3.4.1
RUN pecl install xdebug-${XDEBUG_VERSION} && docker-php-ext-enable xdebug

RUN pecl clear-cache \
    && apk del --purge $PHPIZE_DEPS \
    && rm -rf /var/cache/apk/* /usr/share/doc /usr/share/man /tmp/*

RUN echo "xdebug.mode=coverage" > /usr/local/etc/php/conf.d/xdebug.ini

WORKDIR /srv/app

COPY --from=builder /app .

ENV PATH="${PATH}:/srv/app/vendor/bin"