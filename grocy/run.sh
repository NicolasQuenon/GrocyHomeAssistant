#!/usr/bin/with-contenv bashio

bashio::log.info "Démarrage de Grocy v4.6.0..."

DATA_DIR="/config/grocy"
mkdir -p "${DATA_DIR}"

if [ ! -L "/var/www/grocy/data" ]; then
    rm -rf /var/www/grocy/data
    ln -sf "${DATA_DIR}" /var/www/grocy/data
fi

# Configuration pour sous-chemin /grocy/
bashio::log.info "Configuration sous-chemin /grocy/..."

cat > "${DATA_DIR}/config.php" << 'EOF'
<?php
Setting('BASE_URL', 'https://bonapart.duckdns.org/grocy');
Setting('BASE_PATH', '');
Setting('SUB_DIR', '');
Setting('MODE', 'production');
EOF

# Modifier les fichiers Grocy pour supporter le sous-chemin
# Patcher le fichier de configuration
if [ -f "/var/www/grocy/app.php" ]; then
    sed -i "s|define('GROCY_BASE_URL'.*|define('GROCY_BASE_URL', '/grocy');|" /var/www/grocy/app.php
fi

chown -R nginx:nginx /var/www/grocy "${DATA_DIR}"
mkdir -p /run/php /run/nginx

php-fpm85 -D
sleep 2

bashio::log.info "✅ Grocy prêt (BASE_URL: /grocy)"
exec nginx -g 'daemon off;'
