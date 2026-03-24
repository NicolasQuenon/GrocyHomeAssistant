ARG BUILD_FROM=ghcr.io/home-assistant/aarch64-base:latest
FROM ${BUILD_FROM}

ENV GROCY_VERSION=4.6.0
ENV LANG=C.UTF-8

RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && apk update --no-cache

RUN apk add --no-cache \
    nginx php85 php85-fpm php85-pdo php85-pdo_sqlite php85-sqlite3 \
    php85-gd php85-intl php85-mbstring php85-xml php85-curl \
    php85-session php85-fileinfo php85-ctype php85-tokenizer \
    php85-simplexml php85-dom php85-iconv php85-openssl php85-zip \
    unzip wget ca-certificates

RUN ln -sf /usr/bin/php85 /usr/bin/php \
    && ln -sf /usr/sbin/php-fpm85 /usr/sbin/php-fpm

RUN mkdir -p /var/www/grocy \
    && wget -q -O /tmp/grocy.zip \
        "https://github.com/grocy/grocy/releases/download/v${GROCY_VERSION}/grocy_${GROCY_VERSION}.zip" \
    && unzip -q /tmp/grocy.zip -d /var/www/grocy \
    && rm /tmp/grocy.zip \
    && chown -R nginx:nginx /var/www/grocy

COPY nginx.conf /etc/nginx/http.d/grocy.conf
COPY run.sh /
RUN chmod a+x /run.sh

RUN mkdir -p /run/nginx \
    && rm -f /etc/nginx/http.d/default.conf \
    && sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php85/php.ini \
    && sed -i 's/listen = 127.0.0.1:9000/listen = 127.0.0.1:9000/g' /etc/php85/php-fpm.d/www.conf \
    && sed -i 's/;clear_env = no/clear_env = no/g' /etc/php85/php-fpm.d/www.conf \
    && sed -i 's/user = nobody/user = nginx/g' /etc/php85/php-fpm.d/www.conf \
    && sed -i 's/group = nobody/group = nginx/g' /etc/php85/php-fpm.d/www.conf

EXPOSE 80
CMD ["/run.sh"]
