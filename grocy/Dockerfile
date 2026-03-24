ARG BUILD_FROM=ghcr.io/home-assistant/aarch64-base:latest
FROM ${BUILD_FROM}

# Variables
ENV GROCY_VERSION=4.6.0
ENV LANG=C.UTF-8

# Ajout des dépôts edge pour PHP 8.3
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories

# Installation des dépendances
RUN apk add --no-cache \
    nginx \
    php83 \
    php83-fpm \
    php83-pdo \
    php83-pdo_sqlite \
    php83-sqlite3 \
    php83-gd \
    php83-intl \
    php83-mbstring \
    php83-opcache \
    php83-xml \
    php83-curl \
    php83-session \
    php83-fileinfo \
    php83-ctype \
    php83-tokenizer \
    php83-simplexml \
    php83-dom \
    php83-iconv \
    php83-json \
    php83-openssl \
    php83-zip \
    unzip \
    wget \
    ca-certificates

# Créer des liens symboliques pour php
RUN ln -sf /usr/bin/php83 /usr/bin/php \
    && ln -sf /usr/sbin/php-fpm83 /usr/sbin/php-fpm

# Téléchargement et installation de Grocy
RUN mkdir -p /var/www/grocy \
    && wget -q -O /tmp/grocy.zip \
        "https://github.com/grocy/grocy/releases/download/v${GROCY_VERSION}/grocy_${GROCY_VERSION}.zip" \
    && unzip -q /tmp/grocy.zip -d /var/www/grocy \
    && rm /tmp/grocy.zip \
    && chown -R nginx:nginx /var/www/grocy

# Copie des fichiers de configuration
COPY nginx.conf /etc/nginx/http.d/grocy.conf
COPY run.sh /
RUN chmod a+x /run.sh

# Configuration Nginx et PHP-FPM
RUN mkdir -p /run/nginx \
    && rm -f /etc/nginx/http.d/default.conf \
    && sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php83/php.ini \
    && sed -i 's/listen = 127.0.0.1:9000/listen = 127.0.0.1:9000/g' /etc/php83/php-fpm.d/www.conf \
    && sed -i 's/;clear_env = no/clear_env = no/g' /etc/php83/php-fpm.d/www.conf \
    && sed -i 's/user = nobody/user = nginx/g' /etc/php83/php-fpm.d/www.conf \
    && sed -i 's/group = nobody/group = nginx/g' /etc/php83/php-fpm.d/www.conf

EXPOSE 80

CMD ["/run.sh"]
