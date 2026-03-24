ARG BUILD_FROM
FROM $BUILD_FROM

# Installation de Grocy
RUN apk add --no-cache \
    nginx \
    php82 \
    php82-fpm \
    php82-json \
    php82-pdo \
    php82-pdo_sqlite \
    php82-session \
    php82-fileinfo \
    php82-gd \
    php82-intl \
    php82-mbstring \
    php82-opcache \
    php82-openssl \
    php82-ctype \
    php82-tokenizer \
    unzip \
    wget

# Création des répertoires nécessaires
RUN mkdir -p /var/www/grocy /run/nginx /run/php-fpm82

# Téléchargement de la dernière version de Grocy
RUN wget -O /tmp/grocy.zip https://github.com/grocy/grocy/releases/latest/download/grocy_latest.zip \
    && unzip /tmp/grocy.zip -d /var/www/grocy \
    && rm /tmp/grocy.zip \
    && chown -R nginx:nginx /var/www/grocy

# Configuration Nginx
COPY nginx.conf /etc/nginx/http.d/default.conf

# Configuration PHP-FPM
RUN sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php82/php.ini \
    && sed -i 's/listen = 127.0.0.1:9000/listen = \/run\/php-fpm82\/php-fpm.sock/g' /etc/php82/php-fpm.d/www.conf \
    && sed -i 's/;listen.owner = nobody/listen.owner = nginx/g' /etc/php82/php-fpm.d/www.conf \
    && sed -i 's/;listen.group = nobody/listen.group = nginx/g' /etc/php82/php-fpm.d/www.conf

COPY run.sh /
RUN chmod a+x /run.sh

EXPOSE 9283

CMD [ "/run.sh" ]
