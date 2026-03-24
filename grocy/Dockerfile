ARG BUILD_FROM=ghcr.io/home-assistant/aarch64-base:latest
FROM ${BUILD_FROM}

# Variables
ENV GROCY_VERSION=4.2.0
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

# Configuration Nginx
RUN mkdir -p /run/nginx \
    && rm -f /etc/nginx/http.d/default.conf \
    && echo 'server { \n\
    listen 80 default_server; \n\
    root /var/www/grocy/public; \n\
    index index.php; \n\
    client_max_body_size 100M; \n\
    location / { \n\
        try_files $uri /index.php$is
