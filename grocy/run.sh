#!/usr/bin/with-contenv bashio

bashio::log.info "Démarrage de Grocy v4.6.0..."
bashio::log.info "PHP version: 8.5.4"

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
chown -R nginx:nginx /var/www/grocy
chown -R nginx:nginx "${DATA_DIR}"

# Création du répertoire pour PHP-FPM
mkdir -p /run/php

# Démarrage PHP-FPM
bashio::log.info "Démarrage de PHP-FPM 8.5..."
php-fpm85 -D

# Attendre que PHP-FPM soit prêt
sleep 2

# Démarrage Nginx
bashio::log.info "Démarrage de Nginx..."
bashio::log.info "Grocy disponible sur le port 9283"
bashio::log.info "Identifiants par défaut - Utilisateur: admin / Mot de passe: admin"

exec nginx -g 'daemon off;'
