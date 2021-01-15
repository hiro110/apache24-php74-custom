# FROM php:7.4-apache-buster
FROM mcr.microsoft.com/oryx/php:7.4

ENV PHP_VERSION 7.4

COPY init_container.sh /bin/
COPY hostingstart.html /home/site/wwwroot/hostingstart.html

RUN chmod 755 /bin/init_container.sh \
    && mkdir -p /home/LogFiles/ \
    && echo "root:Docker!" | chpasswd \
    && echo "cd /home/site/wwwroot" >> /etc/bash.bashrc \
    && ln -s /home/site/wwwroot /var/www/html \
    && mkdir -p /opt/startup

# configure startup
COPY sshd_config /etc/ssh/
COPY apache2.conf /etc/apache2/
COPY ssh_setup.sh /tmp
COPY startup.sh /opt/startup
# RUN mkdir -p /opt/startup \
#     && chmod -R +x /opt/startup \
RUN chmod -R +x /opt/startup \
    && chmod -R +x /tmp/ssh_setup.sh \
    && (sleep 1;/tmp/ssh_setup.sh 2>&1 > /dev/null) \
    && rm -rf /tmp/*

RUN DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y tzdata
ENV TZ=Asia/Tokyo
RUN apt-get install -y tzdata

# RUN apt-get update \
#     && apt-get install -y --no-install-recommends \
#     libpng-dev \
#     libjpeg-dev \
#     libpq-dev \
#     libmcrypt-dev \
#     libldap2-dev \
#     libldb-dev \
#     libicu-dev \
#     libgmp-dev \
#     libmagickwand-dev \
#     openssh-server vim curl wget tcptraceroute \
#     # && chmod 755 /bin/init_container.sh \
#     # && echo "root:Docker!" | chpasswd \
#     # && echo "cd /home" >> /etc/bash.bashrc \
#     && ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so \
#     && ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so \
#     && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
#     && rm -rf /var/lib/apt/lists/* \
#     && pecl install imagick-beta \
#     && pecl install mcrypt-1.0.1 \
#     && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
#     && docker-php-ext-install gd \
#     mysqli \
#     opcache \
#     pdo \
#     pdo_mysql \
#     pdo_pgsql \
#     pgsql \
#     ldap \
#     intl \
#     gmp \
#     zip \
#     bcmath \
#     mbstring \
#     pcntl \
#     && docker-php-ext-enable imagick \
#     && docker-php-ext-enable mcrypt

RUN apt-get autoremove

ENV PORT 8080
ENV SSH_PORT 2222
EXPOSE 2222 8080
COPY sshd_config /etc/ssh/

ENV WEBSITE_ROLE_INSTANCE_ID localRoleInstance
ENV WEBSITE_INSTANCE_ID localInstance
ENV PATH ${PATH}:/home/site/wwwroot

RUN rm -f /usr/local/etc/php/conf.d/php.ini \
    && { \
        echo 'error_log=/dev/stderr'; \
        echo 'display_errors=Off'; \
        echo 'log_errors=On'; \
        echo 'display_startup_errors=Off'; \
        echo 'date.timezone=Asia/Tokyo'; \
        echo 'zend_extension=opcache'; \
        echo 'expose_php = off'; \
        echo 'mbstring.language = Japanese'; \
        echo 'mbstring.internal_encoding = UTF-8'; \
        echo 'mbstring.http_input = pass'; \
        echo 'mbstring.http_output = pass'; \
        echo 'mbstring.encoding_translation = Off'; \
        echo 'mbstring.detect_order = auto'; \
        echo 'session.cookie_httponly = 1'; \
        echo 'session.cookie_secure = 1'; \
        echo 'session.use_cookies = 1'; \
        echo 'session.use_only_cookies = 1'; \
        echo 'zlib.output_compression = On'; \
    } > /usr/local/etc/php/conf.d/php.ini

RUN rm -f /etc/apache2/conf-enabled/other-vhosts-access-log.conf

WORKDIR /home/site/wwwroot

ENTRYPOINT ["/bin/init_container.sh"]
