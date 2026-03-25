#!/usr/bin/with-contenv bashio

bashio::log.info "Démarrage de Grocy v4.6.0 avec PHP 8.5..."

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

bashio::log.info "✅ Grocy prêt (PHP 8.5, port 9283)"
exec nginx -g 'daemon off;'
