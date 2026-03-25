#!/usr/bin/with-contenv bashio

bashio::log.info "Démarrage de Grocy v4.6.0..."

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

# Créer un fichier PHP pour forcer les cookies
bashio::log.info "Configuration cookies SameSite=None..."

cat > /var/www/grocy/public/cookie_fix.php << 'EOFPHP'
<?php
// Forcer les paramètres de cookies pour iframe
session_set_cookie_params([
    'lifetime' => 0,
    'path' => '/',
    'domain' => '',
    'secure' => true,
    'httponly' => true,
    'samesite' => 'None'
]);

// Démarrer la session
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
EOFPHP

# Modifier index.php pour inclure ce fichier
if ! grep -q "cookie_fix.php" /var/www/grocy/public/index.php; then
    sed -i '2i require_once __DIR__ . "/cookie_fix.php";' /var/www/grocy/public/index.php
fi

chown -R nginx:nginx /var/www/grocy "${DATA_DIR}"
mkdir -p /run/php /run/nginx

php-fpm85 -D
sleep 2

bashio::log.info "✅ Grocy prêt (cookies SameSite=None forcés)"
exec nginx -g 'daemon off;'
