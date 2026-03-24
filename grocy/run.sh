#!/usr/bin/with-contenv bashio

bashio::log.info "Démarrage de Grocy v${GROCY_VERSION}..."

# Détection de la version PHP
PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')
bashio::log.info "Version PHP détectée: ${PHP_VERSION}"

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

# Création du répertoire pour PHP-FPM
mkdir -p /run/php

# Configuration PHP-FPM pour écouter sur un socket Unix
PHP_FPM_CONF="/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"
if [ -f "${PHP_FPM_CONF}" ]; then
    sed -i 's/listen = .*/listen = \/run\/php\/php-fpm.sock/g' "${PHP_FPM_CONF}"
    sed -i 's/;listen.owner = .*/listen.owner = www-data/g' "${PHP_FPM_CONF}"
    sed -i 's/;listen.group = .*/listen.group = www-data/g' "${PHP_FPM_CONF}"
    sed -i 's/;listen.mode = .*/listen.mode = 0660/g' "${PHP_FPM_CONF}"
fi

# Démarrage PHP-FPM
bashio::log.info "Démarrage de PHP-FPM ${PHP_VERSION}..."
service php${PHP_VERSION}-fpm start

# Attendre que PHP-FPM soit prêt
sleep 3

# Vérifier que le socket existe
if [ ! -S /run/php/php-fpm.sock ]; then
    bashio::log.error "Le socket PHP-FPM n'a pas été créé!"
    exit 1
fi

# Démarrage Nginx
bashio::log.info "Démarrage de Nginx..."
bashio::log.info "Grocy disponible sur le port 9283"

exec nginx -g 'daemon off;'
