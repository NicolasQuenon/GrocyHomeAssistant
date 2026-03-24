#!/usr/bin/with-contenv bashio

bashio::log.info "Démarrage Grocy 4.6.0..."

DATA_DIR="/config/grocy"
mkdir -p "${DATA_DIR}"

if [ ! -L "/var/www/grocy/data" ]; then
    rm -rf /var/www/grocy/data
    ln -sf "${DATA_DIR}" /var/www/grocy/data
fi

if [ ! -f "${DATA_DIR}/config.php" ]; then
    cat > "${DATA_DIR}/config.php" << 'EOF'
<?php
Setting('BASE_URL', '');
Setting('BASE_PATH', '');
Setting('SUB_DIR', '');
Setting('MODE', 'production');
EOF
fi

chown -R nginx:nginx /var/www/grocy "${DATA_DIR}"
mkdir -p /run/php /run/nginx

php-fpm85 -D
sleep 2

bashio::log.info "✅ Grocy prêt (port 80 Ingress, 9283 direct)"
exec nginx -g 'daemon off;'
