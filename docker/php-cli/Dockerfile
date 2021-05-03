ARG BXDOCK_PHP_VERSION
ARG BASE_IMAGE_TAG_PREFIX=latest
FROM orendev/php-base:${BASE_IMAGE_TAG_PREFIX}-${BXDOCK_PHP_VERSION}

LABEL maintainer="Adelshin Abai <info@orendev.ru>"

# Set Environment Variables
ENV DEBIAN_FRONTEND noninteractive

ADD php.ini /etc/php/${BXDOCK_PHP_VERSION}/cli/conf.d/90-php.ini

ARG BXDOCK_MBSTRING_OVERLOAD=0
ARG TZ=Asia/Yekaterinburg
RUN echo "" >> /etc/php/${BXDOCK_PHP_VERSION}/cli/conf.d/90-php.ini \
    && echo "mbstring.func_overload=${BXDOCK_MBSTRING_OVERLOAD}" >> /etc/php/${BXDOCK_PHP_VERSION}/cli/conf.d/90-php.ini \
    && echo "date.timezone=${TZ}" >> /etc/php/${BXDOCK_PHP_VERSION}/cli/conf.d/90-php.ini

# Start as root
USER root

# Add a non-root user to prevent files being created with root permissions on host machine.
ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

ARG UBUNTU_SOURCE

COPY ./sources.sh /tmp/sources.sh

# always run apt update when start and after add new source list, then clean up at end.
RUN set -xe; \
    apt-get update -yqq && \
    pecl channel-update pecl.php.net && \
    groupadd -g ${PGID} bxdock && \
    useradd -u ${PUID} -g bxdock -m bxdock -G docker_env && \
    usermod -p "*" bxdock -s /bin/bash && \
    apt-get install -yqq \
    apt-utils \
    #
    #--------------------------------------------------------------------------
    # Mandatory Software's Installation
    #--------------------------------------------------------------------------
    #
    # Mandatory Software's such as ("php-cli", "git", "vim", ....) are
    # installed on the base image 'bxdock/workspace' image. If you want
    # to add more Software's or remove existing one, you need to edit the
    # base image (https://github.com/orendev/bxdock).
    #
    #
    libzip-dev zip unzip \
    # Install the zip extension
    php${BXDOCK_PHP_VERSION}-zip \
    # nasm
    nasm && \
    php -m | grep -q 'zip'

###########################################################################
# Set Timezone
###########################################################################

ARG TZ=Asia/Yekaterinburg
ENV TZ ${TZ}

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

###########################################################################
# User Aliases
###########################################################################
USER root

COPY ./aliases.sh /root/aliases.sh
COPY ./aliases.sh /home/bxdock/aliases.sh

RUN sed -i 's/\r//' /root/aliases.sh && \
    sed -i 's/\r//' /home/bxdock/aliases.sh && \
    chown bxdock:bxdock /home/bxdock/aliases.sh && \
    echo "" >> ~/.bashrc && \
    echo "# Load Custom Aliases" >> ~/.bashrc && \
    echo "source ~/aliases.sh" >> ~/.bashrc && \
    echo "" >> ~/.bashrc

USER bxdock

RUN echo "" >> ~/.bashrc && \
    echo "# Load Custom Aliases" >> ~/.bashrc && \
    echo "source ~/aliases.sh" >> ~/.bashrc && \
    echo "" >> ~/.bashrc

###########################################################################
# Composer:
###########################################################################

USER root

# Add the composer.json
COPY ./composer.json /home/bxdock/.composer/composer.json

# Add the auth.json for magento 2 credentials
COPY ./auth.json /home/bxdock/.composer/auth.json

# Make sure that ~/.composer belongs to bxdock
RUN chown -R bxdock:bxdock /home/bxdock/.composer

# Export composer vendor path
RUN echo "" >> ~/.bashrc && \
    echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> ~/.bashrc

USER bxdock

# Check if global install need to be ran
ARG COMPOSER_GLOBAL_INSTALL=false
ENV COMPOSER_GLOBAL_INSTALL ${COMPOSER_GLOBAL_INSTALL}

RUN if [ ${COMPOSER_GLOBAL_INSTALL} = true ]; then \
    # run the install
    composer global install \
    ;fi

# Check if auth file is disabled
ARG COMPOSER_AUTH=false
ENV COMPOSER_AUTH ${COMPOSER_AUTH}

RUN if [ ${COMPOSER_AUTH} = false ]; then \
    # remove the file
    rm /home/bxdock/.composer/auth.json \
    ;fi

ARG COMPOSER_REPO_PACKAGIST
ENV COMPOSER_REPO_PACKAGIST ${COMPOSER_REPO_PACKAGIST}

RUN if [ ${COMPOSER_REPO_PACKAGIST} ]; then \
    composer config -g repo.packagist composer ${COMPOSER_REPO_PACKAGIST} \
    ;fi

# Export composer vendor path
RUN echo "" >> ~/.bashrc && \
    echo 'export PATH="~/.composer/vendor/bin:$PATH"' >> ~/.bashrc

###########################################################################
# Non-root user : PHPUnit path
###########################################################################

# add ./vendor/bin to non-root user's bashrc (needed for phpunit)
USER bxdock

RUN echo "" >> ~/.bashrc && \
    echo 'export PATH="/var/www/local/vendor/bin:$PATH"' >> ~/.bashrc

###########################################################################
# Crontab
###########################################################################

USER root

COPY ./crontab /etc/cron.d

RUN chmod -R 644 /etc/cron.d


###########################################################################
# xDebug:
###########################################################################

USER root

ARG INSTALL_XDEBUG=false
ARG BXDOCK_PHP_VERSION

RUN if [ ${INSTALL_XDEBUG} = true ]; then \
    # Load the xdebug extension only with phpunit commands
    apt-get install -y php${BXDOCK_PHP_VERSION}-xdebug && \
    sed -i 's/^;//g' /etc/php/${BXDOCK_PHP_VERSION}/cli/conf.d/20-xdebug.ini \
    ;fi

# ADD for REMOTE debugging
COPY ./xdebug.ini /etc/php/${BXDOCK_PHP_VERSION}/cli/conf.d/xdebug.ini

RUN sed -i "s/xdebug.remote_autostart=0/xdebug.remote_autostart=1/" /etc/php/${BXDOCK_PHP_VERSION}/cli/conf.d/xdebug.ini && \
    sed -i "s/xdebug.remote_enable=0/xdebug.remote_enable=1/" /etc/php/${BXDOCK_PHP_VERSION}/cli/conf.d/xdebug.ini && \
    sed -i "s/xdebug.cli_color=0/xdebug.cli_color=1/" /etc/php/${BXDOCK_PHP_VERSION}/cli/conf.d/xdebug.ini


###########################################################################
# ssh:
###########################################################################

ARG INSTALL_SSH=false

COPY insecure_id_rsa /tmp/id_rsa
COPY insecure_id_rsa.pub /tmp/id_rsa.pub

RUN if [ ${INSTALL_SSH} = true ]; then \
    rm -f /etc/service/sshd/down && \
    cat /tmp/id_rsa.pub >> /root/.ssh/authorized_keys \
    && cat /tmp/id_rsa.pub >> /root/.ssh/id_rsa.pub \
    && cat /tmp/id_rsa >> /root/.ssh/id_rsa \
    && rm -f /tmp/id_rsa* \
    && chmod 644 /root/.ssh/authorized_keys /root/.ssh/id_rsa.pub \
    && chmod 400 /root/.ssh/id_rsa \
    && cp -rf /root/.ssh /home/bxdock \
    && chown -R bxdock:bxdock /home/bxdock/.ssh \
    ;fi

# MSMTP
#USER root
COPY msmtprc /etc/msmtprc
RUN chmod 777 /etc/msmtprc &&\
    touch /var/log/msmtp.log && \
    chmod 0600 /var/log/msmtp.log && \
    chown bxdock:bxdock /var/log/msmtp.log


#RUN chmod 0600 /etc/msmtprc && \
#    chown www-data:root /etc/msmtprc && \
#    touch /var/log/msmtp.log && \
#    chmod 0600 /var/log/msmtp.log && \
#    chown www-data:www-data /var/log/msmtp.log

USER bxdock
###########################################################################
# Node / NVM:
###########################################################################
# Check if NVM needs to be installed
ARG NODE_VERSION=node
ENV NODE_VERSION ${NODE_VERSION}
ARG INSTALL_NODE=false
ARG INSTALL_NPM_GULP=false
ARG INSTALL_NPM_BOWER=false
ARG INSTALL_NPM_VUE_CLI=false
ARG INSTALL_NPM_ANGULAR_CLI=false
ARG NPM_REGISTRY
ENV NPM_REGISTRY ${NPM_REGISTRY}
ENV NVM_DIR /home/bxdock/.nvm
ARG NVM_NODEJS_ORG_MIRROR
ENV NVM_NODEJS_ORG_MIRROR ${NVM_NODEJS_ORG_MIRROR}

RUN if [ ${INSTALL_NODE} = true ]; then \
    # Install nvm (A Node Version Manager)
    mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install ${NODE_VERSION} \
    && nvm use ${NODE_VERSION} \
    && nvm alias ${NODE_VERSION} \
    && if [ ${NPM_REGISTRY} ]; then \
    npm config set registry ${NPM_REGISTRY} \
    ;fi \
    && if [ ${INSTALL_NPM_GULP} = true ]; then \
    npm install -g gulp \
    ;fi \
    && if [ ${INSTALL_NPM_BOWER} = true ]; then \
    npm install -g bower \
    ;fi \
    && if [ ${INSTALL_NPM_VUE_CLI} = true ]; then \
    npm install -g @vue/cli \
    ;fi \
    && if [ ${INSTALL_NPM_ANGULAR_CLI} = true ]; then \
    npm install -g @angular/cli \
    ;fi \
    && ln -s `npm bin --global` /home/bxdock/.node-bin \
    ;fi

# Wouldn't execute when added to the RUN statement in the above block
# Source NVM when loading bash since ~/.profile isn't loaded on non-login shell
RUN if [ ${INSTALL_NODE} = true ]; then \
    echo "" >> ~/.bashrc && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.bashrc \
    ;fi

# Add NVM binaries to root's .bashrc
USER root

RUN if [ ${INSTALL_NODE} = true ]; then \
    echo "" >> ~/.bashrc && \
    echo 'export NVM_DIR="/home/bxdock/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.bashrc \
    ;fi

# Add PATH for node
ENV PATH $PATH:/home/bxdock/.node-bin

# Make it so the node modules can be executed with 'docker-compose exec'
# We'll create symbolic links into '/usr/local/bin'.
RUN if [ ${INSTALL_NODE} = true ]; then \
    find $NVM_DIR -type f -name node -exec ln -s {} /usr/local/bin/node \; && \
    NODE_MODS_DIR="$NVM_DIR/versions/node/$(node -v)/lib/node_modules" && \
    ln -s $NODE_MODS_DIR/bower/bin/bower /usr/local/bin/bower && \
    ln -s $NODE_MODS_DIR/gulp/bin/gulp.js /usr/local/bin/gulp && \
    ln -s $NODE_MODS_DIR/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -s $NODE_MODS_DIR/npm/bin/npx-cli.js /usr/local/bin/npx && \
    ln -s $NODE_MODS_DIR/vue-cli/bin/vue /usr/local/bin/vue && \
    ln -s $NODE_MODS_DIR/vue-cli/bin/vue-init /usr/local/bin/vue-init && \
    ln -s $NODE_MODS_DIR/vue-cli/bin/vue-list /usr/local/bin/vue-list \
    ;fi

RUN if [ ${NPM_REGISTRY} ]; then \
    . ~/.bashrc && npm config set registry ${NPM_REGISTRY} \
    ;fi

###########################################################################
# PNPM:
###########################################################################

USER bxdock

ARG INSTALL_PNPM=false

RUN if [ ${INSTALL_PNPM} = true ]; then \
    npx pnpm add -g pnpm \
    ;fi


###########################################################################
# YARN:
###########################################################################

USER bxdock

ARG INSTALL_YARN=false
ARG YARN_VERSION=latest
ENV YARN_VERSION ${YARN_VERSION}

RUN if [ ${INSTALL_YARN} = true ]; then \
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && \
    if [ ${YARN_VERSION} = "latest" ]; then \
    curl -o- -L https://yarnpkg.com/install.sh | bash; \
    else \
    curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version ${YARN_VERSION}; \
    fi && \
    echo "" >> ~/.bashrc && \
    echo 'export PATH="$HOME/.yarn/bin:$PATH"' >> ~/.bashrc \
    ;fi

# Add YARN binaries to root's .bashrc
USER root

RUN if [ ${INSTALL_YARN} = true ]; then \
    echo "" >> ~/.bashrc && \
    echo 'export YARN_DIR="/home/bxdock/.yarn"' >> ~/.bashrc && \
    echo 'export PATH="$YARN_DIR/bin:$PATH"' >> ~/.bashrc \
    ;fi

# Add PATH for YARN
ENV PATH $PATH:/home/bxdock/.yarn/bin


###########################################################################
# PHP V8JS:
###########################################################################

USER root

ARG INSTALL_V8JS=false

RUN set -xe; \
    if [ ${INSTALL_V8JS} = true ]; then \
    add-apt-repository -y ppa:pinepain/libv8-archived \
    && apt-get update -yqq \
    && apt-get install -y libv8-5.4 && \
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
    pecl install v8js-0.6.4; \
    else \
    pecl install v8js; \
    fi \
    && echo "extension=v8js.so" >> /etc/php/${BXDOCK_PHP_VERSION}/cli/php.ini \
    && php -m | grep -q 'v8js' \
    ;fi
###########################################################################
# PYTHON2:
###########################################################################

ARG INSTALL_PYTHON=false

RUN if [ ${INSTALL_PYTHON} = true ]; then \
    apt-get update -yqq \
    && apt-get -y install python python-pip python-dev build-essential  \
    && python -m pip install --upgrade pip  \
    && python -m pip install --upgrade virtualenv \
    ;fi

###########################################################################
# PYTHON3:
###########################################################################

ARG INSTALL_PYTHON3=false

RUN if [ ${INSTALL_PYTHON3} = true ]; then \
    apt-get update -yqq \
    && apt-get -y install python3 python3-pip python3-dev build-essential  \
    && python3 -m pip install --upgrade --force-reinstall pip  \
    && python3 -m pip install --upgrade virtualenv \
    ;fi
###########################################################################
# POWERLINE:
###########################################################################

USER root
ARG INSTALL_POWERLINE=false

RUN if [ ${INSTALL_POWERLINE} = true ]; then \
    if [ ${INSTALL_PYTHON} = true ]; then \
    python -m pip install --upgrade powerline-status && \
    echo "" >> /etc/bash.bashrc && \
    echo ". /usr/local/lib/python2.7/dist-packages/powerline/bindings/bash/powerline.sh" >> /etc/bash.bashrc \
    ;fi \
    ;fi
###########################################################################
# SUPERVISOR:
###########################################################################
ARG INSTALL_SUPERVISOR=false

RUN if [ ${INSTALL_SUPERVISOR} = true ]; then \
    if [ ${INSTALL_PYTHON} = true ]; then \
    python -m pip install --upgrade supervisor && \
    echo_supervisord_conf > /etc/supervisord.conf && \
    sed -i 's/\;\[include\]/\[include\]/g' /etc/supervisord.conf && \
    sed -i 's/\;files\s.*/files = supervisord.d\/*.conf/g' /etc/supervisord.conf \
    ;fi \
    ;fi
USER bxdock
#
#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------
#

USER root

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

WORKDIR /var/www

