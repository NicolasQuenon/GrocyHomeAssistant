ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base:7.3.3
FROM ${BUILD_FROM}

# Variables
ENV GROCY_VERSION=4.2.0
ENV LANG=C.UTF-8

# Installation des dépendances
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        nginx \
        php-fpm \
        php-sqlite3 \
        php-gd \
        php-intl \
        php-mbstring \
        php-opcache \
        php-xml \
        php-curl \
        unzip \
        wget \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Détection de la version PHP installée
RUN PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;') \
    && echo "PHP version: ${PHP_VERSION}" \
    && ln -sf /etc/php/${PHP_VERSION}/fpm/php.ini /etc/php/fpm/php.ini \
    && ln -sf /etc/php/${PHP_VERSION}/fpm/pool.d /etc/php/fpm/pool.d

# Téléchargement et installation de Grocy
RUN mkdir -p /var/www/grocy \
    && wget -q -O /tmp/grocy.zip \
        "https://github.com/grocy/grocy/releases/download/v${GROCY_VERSION}/grocy_${GROCY_VERSION}.zip" \
    && unzip -q /tmp/grocy.zip -d /var/www/grocy \
    && rm /tmp/grocy.zip \
    && chown -R www-data:www-data /var/www/grocy

# Configuration Nginx
RUN rm -f /etc/nginx/sites-enabled/default \
    && echo 'server { \n\
    listen 80 default_server; \n\
    root /var/www/grocy/public; \n\
    index index.php; \n\
    client_max_body_size 100M; \n\
    location / { \n\
        try_files $uri /index.php$is_args$args; \n\
    } \n\
    location ~ \.php$ { \n\
        fastcgi_split_path_info ^(.+\.php)(/.+)$; \n\
        fastcgi_pass unix:/run/php/php-fpm.sock; \n\
        fastcgi_index index.php; \n\
        include fastcgi_params; \n\
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name; \n\
    } \n\
}' > /etc/nginx/sites-enabled/grocy

# Copie du script de démarrage
COPY run.sh /
RUN chmod a+x /run.sh

EXPOSE 80

CMD ["/run.sh"]
