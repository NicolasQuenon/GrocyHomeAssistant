ARG BUILD_FROM=ghcr.io/home-assistant/aarch64-base:latest
FROM ${BUILD_FROM}

# Variables
ENV GROCY_VERSION=4.2.0
ENV LANG=C.UTF-8

# Ajout des dépôts edge
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# Mise à jour et vérification des versions PHP disponibles
RUN apk update && apk search php8 | grep -E '^php8[0-9]+-[0-9]' | head -5

# Détection de la dernière version PHP disponible
RUN PHP_LATEST=$(apk search 'php8*-fpm' | grep -oE 'php8[0-9]+' | sort -V | tail -1) \
    && echo "Version PHP détectée: ${PHP_LATEST}" \
    && apk add --no-cache \
        nginx \
        ${PHP_LATEST} \
        ${PHP_LATEST}-fpm \
        ${PHP_LATEST}-pdo \
        ${PHP_LATEST}-pdo_sqlite \
        ${PHP_LATEST}-sqlite3 \
        ${PHP_LATEST}-gd \
        ${PHP_LATEST}-intl \
        ${PHP_LATEST}-mbstring \
        ${PHP_LATEST}-opcache \
        ${PHP_LATEST}-xml \
        ${PHP_LATEST}-curl \
        ${PHP_LATEST}-session \
        ${PHP_LATEST}-fileinfo \
        ${PHP_LATEST}-ctype \
        ${PHP_LATEST}-tokenizer \
        ${PHP_LATEST}-simplexml \
        ${PHP_LATEST}-dom \
        ${PHP_LATEST}-iconv \
        ${PHP_LATEST}-json \
        ${PHP_LATEST}-openssl \
        ${PHP_LATEST}-zip \
        unzip \
        wget \
        ca-certificates \
    && ln -sf /usr/bin/${PHP_LATEST} /usr/bin/php \
    && ln -sf /usr/sbin/php-fpm* /usr/sbin/php-fpm \
    && echo "${PHP_LATEST}" > /tmp/php_version.txt

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

# Configuration Nginx et PHP-FPM (dynamique)
RUN mkdir -p /run/nginx \
    && rm -f /etc/nginx/http.d/default.conf \
    && PHP_VER=$(cat /tmp/php_version.txt) \
    && sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/${PHP_VER}/php.ini \
    && sed -i 's/listen = 127.0.0.1:9000/listen = 127.0.0.1:9000/g' /etc/${PHP_VER}/php-fpm.d/www.conf \
    && sed -i 's/;clear_env = no/clear_env = no/g' /etc/${PHP_VER}/php-fpm.d/www.conf \
    && sed -i 's/user = nobody/user = nginx/g' /etc/${PHP_VER}/php-fpm.d/www.conf \
    && sed -i 's/group = nobody/group = nginx/g' /etc/${PHP_VER}/php-fpm.d/www.conf

EXPOSE 80

CMD ["/run.sh"]
