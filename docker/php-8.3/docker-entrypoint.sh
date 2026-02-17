#!/bin/sh
set -e

echo "[entrypoint] started | SERVER_ROOT=${SERVER_ROOT:-undefined} | SERVER_NAME=${SERVER_NAME:-undefined}"

################################################################
# If first arg starts with "-" (default CMD), run FrankenPHP in foreground
# This is the normal behavior for docker compose
if [ "${1#-}" != "$1" ]; then
    echo "[entrypoint] foreground mode (docker compose)"
    exec frankenphp run "$@"
fi

echo "[entrypoint] CI/CD mode detected"

################################################################
# CI/CD mode: ensure SERVER_ROOT exists for FrankenPHP
if [ -n "$SERVER_ROOT" ] && [ ! -d "$SERVER_ROOT" ]; then
    echo "[entrypoint] creating SERVER_ROOT: $SERVER_ROOT"
    mkdir -p "$SERVER_ROOT"
    echo "<html><body><h1>FrankenPHP Ready</h1></body></html>" > "$SERVER_ROOT/index.html"
fi

################################################################
# Start web server in background
# Try FrankenPHP php-server first, fallback to PHP built-in server
echo "[entrypoint] starting web server..."
nohup frankenphp php-server --listen :80 --root "${SERVER_ROOT:-/var/www/html}" > /dev/null 2>&1 &
SERVER_PID=$!
sleep 2

if kill -0 $SERVER_PID 2>/dev/null; then
    echo "[entrypoint] FrankenPHP php-server running (PID $SERVER_PID)"
else
    echo "[entrypoint] FrankenPHP failed, fallback to PHP built-in server"
    nohup php -S 0.0.0.0:80 -t "${SERVER_ROOT:-/var/www/html}" > /dev/null 2>&1 &
    SERVER_PID=$!
    sleep 1
    if kill -0 $SERVER_PID 2>/dev/null; then
        echo "[entrypoint] PHP built-in server running (PID $SERVER_PID)"
    else
        echo "[entrypoint] WARNING: no web server available"
    fi
fi

exec "$@"
