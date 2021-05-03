
ARG BXDOCK_PHP_VERSION
ARG BASE_IMAGE_TAG_PREFIX=latest
FROM orendev/php-base:${BASE_IMAGE_TAG_PREFIX}-${BXDOCK_PHP_VERSION}

LABEL maintainer="Adelshin Abai <info@orendev.ru>"

ARG BXDOCK_PHP_VERSION

# Set Environment Variables
ENV DEBIAN_FRONTEND noninteractive

# Install FPM
RUN apt-get update \
    && apt-get -y --no-install-recommends install \
    php${BXDOCK_PHP_VERSION}-fpm \
    php${BXDOCK_PHP_VERSION}-xdebug \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

STOPSIGNAL SIGQUIT

# PHP-FPM packages need a nudge to make them docker-friendly
COPY overrides.conf /etc/php/${BXDOCK_PHP_VERSION}/fpm/pool.d/z-overrides.conf
ADD php.ini /etc/php/${BXDOCK_PHP_VERSION}/fpm/conf.d/90-php.ini
ADD php.ini /etc/php/${BXDOCK_PHP_VERSION}/cli/conf.d/90-php.ini

ARG BXDOCK_MBSTRING_OVERLOAD=0
ARG TZ=Asia/Yekaterinburg
RUN echo "" >> /etc/php/${BXDOCK_PHP_VERSION}/fpm/conf.d/90-php.ini \
    && echo "mbstring.func_overload=${BXDOCK_MBSTRING_OVERLOAD}" >> /etc/php/${BXDOCK_PHP_VERSION}/fpm/conf.d/90-php.ini \
    && echo "date.timezone=${TZ}" >> /etc/php/${BXDOCK_PHP_VERSION}/fpm/conf.d/90-php.ini

RUN echo "" >> /etc/php/${BXDOCK_PHP_VERSION}/cli/conf.d/90-php.ini \
    && echo "mbstring.func_overload=${BXDOCK_MBSTRING_OVERLOAD}" >> /etc/php/${BXDOCK_PHP_VERSION}/cli/conf.d/90-php.ini \
    && echo "date.timezone=${TZ}" >> /etc/php/${BXDOCK_PHP_VERSION}/cli/conf.d/90-php.ini


USER root

# MSMTP
COPY msmtprc /etc/msmtprc
RUN chmod 777 /etc/msmtprc &&\
    touch /var/log/msmtp.log && \
    chmod 0600 /var/log/msmtp.log && \
    chown www-data:www-data /var/log/msmtp.log

# Configure non-root user.
ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

RUN groupmod -o -g ${PGID} www-data && \
    usermod -o -u ${PUID} -g www-data www-data


# Configure locale.
ARG LOCALE=POSIX
ARG BXDOCK_PHP_VERSION
ENV LC_ALL ${LOCALE}

WORKDIR /var/www


CMD ["/usr/sbin/php-fpm7.4", "-O" ]

EXPOSE 9000