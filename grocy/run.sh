#!/usr/bin/with-contenv bashio

bashio::log.info "Démarrage de Grocy..."

# Création des répertoires de données si nécessaire
if [ ! -d "/data/viewcache" ]; then
    bashio::log.info "Initialisation des données Grocy..."
    mkdir -p /data/viewcache
    mkdir -p /data/plugins
    mkdir -p /data/settingoverrides
    cp -r /var/www/grocy/data/* /data/ 2>/dev/null || true
fi

# Lien symbolique vers les données persistantes
rm -rf /var/www/grocy/data
ln -sf /data /var/www/grocy/data

# Permissions
chown -R nginx:nginx /var/www/grocy
chown -R nginx:nginx /data

# Démarrage PHP-FPM
bashio::log.info "Démarrage de PHP-FPM..."
php-fpm82

# Démarrage Nginx
bashio::log.info "Démarrage de Nginx..."
nginx -g 'daemon off;'
