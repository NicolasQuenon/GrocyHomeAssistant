#!/usr/bin/with-contenv bashio

bashio::log.info "Démarrage de Grocy v${GROCY_VERSION}..."

# Répertoire de données persistantes
DATA_DIR="/config/grocy"
mkdir -p "${DATA_DIR}"

# Lien symbolique vers les données
if [ ! -L "/var/www/grocy/data" ]; then
    bashio::log.info "Configuration du stockage persistant..."
    rm -rf /var/www/grocy/data
    ln -sf "${DATA_DIR}" /var/www/grocy/data
fi

# Initialisation de la configuration
if [ ! -f "${DATA_DIR}/config.php" ]; then
    bashio::log.info "Initialisation de la configuration Grocy..."
    cp /var/www/grocy/config-dist.php "${DATA_DIR}/config.php"
fi

# Permissions
chown -R www-data:www-data /var/www/grocy
chown -R www-data:www-data "${DATA_DIR}"

# Démarrage PHP-FPM
bashio::log.info "Démarrage de PHP-FPM..."
service php8.2-fpm start

# Démarrage Nginx
bashio::log.info "Démarrage de Nginx..."
bashio::log.info "Grocy disponible sur le port 9283"

exec nginx -g 'daemon off;'
