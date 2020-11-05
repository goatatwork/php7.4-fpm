FROM php:7.4-fpm

LABEL maintainer="goat <ryantgray@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        curl \
        zip \
        unzip \
        git \
        zlib1g-dev \
        libicu-dev \
        iputils-ping \
        default-mysql-client \
        tzdata \
        wget \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) pdo_mysql \
    && docker-php-ext-install -j$(nproc) pcntl \
    && docker-php-ext-install -j$(nproc) intl \
    && docker-php-ext-install -j$(nproc) bcmath \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install -j$(nproc) exif \
    && docker-php-ext-install -j$(nproc) sockets \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pecl install redis && docker-php-ext-enable redis

RUN mkdir /var/www/.composer && chown www-data.www-data /var/www/.composer
RUN mkdir /var/www/.config && chown www-data.www-data /var/www/.config
RUN mkdir /var/www/.npm && chown www-data.www-data /var/www/.npm
RUN mkdir /var/www/.ssh && chown www-data.www-data /var/www/.ssh

COPY auto-install-composer.sh /tmp
RUN /tmp/auto-install-composer.sh
RUN mv composer.phar /usr/bin/composer

RUN ln -fs /usr/share/zoneinfo/America/Chicago /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata

USER www-data

WORKDIR /var/www/html
