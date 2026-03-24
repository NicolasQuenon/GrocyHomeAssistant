ARG BUILD_FROM=ghcr.io/home-assistant/aarch64-base:latest
FROM ${BUILD_FROM}

# Variables
ENV GROCY_VERSION=4.2.0
ENV LANG=C.UTF-8

# Installation des dépendances
RUN apk add --no-cache \
    nginx \
    php82 \
    php82-fpm \
    php82-sqlite3 \
    php82-gd \
    php82-intl \
    php82-mbstring \
    php82-opcache \
    php82-xml \
    php82-curl \
    php82-pdo \
    php82-pdo_sqlite \
    php82-session \
    php82-fileinfo \
    php82-ctype \
    php82-tokenizer \
    php82-simplexml \
    php82-dom \
    unzip \
    wget \
    ca-certificates

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
    location / { \n\
        try_files $uri /index.php$is_args$args; \n\
    } \n\
    location ~ \.php$ { \n\
        fastcgi_split_path_info ^(.+\.php)(/.+)$; \n\
        fastcgi_pass 127.0.0.1:9000; \n\
        fastcgi_index index.php; \n\
        include fastcgi_params; \n\
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name; \n\
    } \n\
}' > /etc/nginx/http.d/grocy.conf

# Configuration PHP-FPM
RUN sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php82/php.ini \
    && sed -i 's/listen = 127.0.0.1:9000/listen = 127.0.0.1:9000/g' /etc/php82/php-fpm.d/www.conf \
    && sed -i 's/;clear_env = no/clear_env = no/g' /etc/php82/php-fpm.d/www.conf

# Copie du script de démarrage
COPY run.sh /
RUN chmod a+x /run.sh

EXPOSE 80

CMD ["/run.sh"]
