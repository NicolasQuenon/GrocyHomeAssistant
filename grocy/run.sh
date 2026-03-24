#!/usr/bin/with-contenv bashio

bashio::log.info "Démarrage de Grocy v4.6.0 avec PHP 8.5..."

DATA_DIR="/config/grocy"
mkdir -p "${DATA_DIR}"

if [ ! -L "/var/www/grocy/data" ]; then
    rm -rf /var/www/grocy/data
    ln -sf "${DATA_DIR}" /var/www/grocy/data
fi

# Configuration Grocy pour Ingress
if [ ! -f "${DATA_DIR}/config.php" ]; then
    bashio::log.info "Initialisation de la configuration Grocy..."
    cp /var/www/grocy/config-dist.php "${DATA_DIR}/config.php"
    
    # Configuration pour Ingress
    cat >> "${DATA_DIR}/config.php" << 'EOF'

// Configuration Ingress Home Assistant
Setting('BASE_URL', '');
Setting('SUB_DIR', '');
Setting('DISABLE_AUTH', false);
EOF
fi

chown -R nginx:nginx /var/www/grocy "${DATA_DIR}"
mkdir -p /run/php

php-fpm85 -D
sleep 2

bashio::log.info "Grocy disponible sur le port 9283"
bashio::log.info "Ingress: Activez 'Afficher dans la barre latérale'"
exec nginx -g 'daemon off;'
