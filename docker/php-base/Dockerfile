FROM phusion/baseimage:0.11

LABEL maintainer="Adelshin Abai <info@orendev.ru>"

RUN DEBIAN_FRONTEND=noninteractive
RUN locale-gen en_US.UTF-8

ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LC_CTYPE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV TERM xterm

# Add the "PHP 7" ppa
RUN apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:ondrej/php

#
#--------------------------------------------------------------------------
# Software's Installation
#--------------------------------------------------------------------------
#

RUN echo 'DPkg::options { "--force-confdef"; };' >> /etc/apt/apt.conf

# Install "PHP Extentions", "libraries", "Software's"
RUN set -eux; \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --allow-downgrades --allow-remove-essential \
    --allow-change-held-packages \
    php7.3-cli \
    php7.3-common \
    php7.3-curl \
    php7.3-intl \
    php7.3-json \
    php7.3-xml \
    php7.3-mbstring \
    php7.3-mysql \
    php7.3-pgsql \
    php7.3-sqlite \
    php7.3-sqlite3 \
    php7.3-zip \
    php7.3-bcmath \
    php7.3-memcached \
    php7.3-memcache \
    php7.3-gd \
    php7.3-soap \
    php7.3-imagick \
    php7.3-dev \
    pkg-config \
    libcurl4-openssl-dev \
    libedit-dev \
    libssl-dev \
    libxml2-dev \
    xz-utils \
    libsqlite3-dev \
    rsync \
    sqlite3 \
    git \
    curl \
    php-apcu \
    php-apcu-bc \
    vim \
    nano \
    msmtp \
    mysql-client \
    postgresql-client; \
    rm -rf /var/lib/apt/lists/*

#COPY docker-php-source /usr/local/bin/
#COPY docker-php-ext-* docker-php-entrypoint /usr/local/bin/
#
#ENTRYPOINT ["docker-php-entrypoint"]

ENV PHP_INI_DIR /usr/local/etc/php
RUN set -eux; \
	mkdir -p "$PHP_INI_DIR/conf.d";

#####################################
# Composer:
#####################################
# Куда же без composer'а.
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER 1