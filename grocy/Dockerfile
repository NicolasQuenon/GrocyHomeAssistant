ARG BUILD_FROM
FROM $BUILD_FROM

# Installation de Grocy
RUN apk add --no-cache \
    nginx \
    php81 \
    php81-fpm \
    php81-json \
    php81-pdo \
    php81-pdo_sqlite \
    php81-session \
    php81-fileinfo \
    php81-gd

# Téléchargement de la dernière version de Grocy
RUN wget -O /tmp/grocy.zip https://github.com/grocy/grocy/releases/latest/download/grocy_latest.zip \
    && unzip /tmp/grocy.zip -d /var/www/grocy \
    && rm /tmp/grocy.zip

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
