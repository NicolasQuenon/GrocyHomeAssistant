#!/usr/bin/with-contenv bashio

bashio::log.info "Démarrage de Grocy..."

# Configuration et démarrage des services
php-fpm81
nginx -g 'daemon off;'
