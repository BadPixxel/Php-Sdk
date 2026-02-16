#!/bin/sh
set -e

################################################################
# If first arg starts with "-" (default CMD), run FrankenPHP in foreground
# This is the normal behavior for docker compose
if [ "${1#-}" != "$1" ]; then
    exec frankenphp run "$@"
fi

################################################################
# CI/CD mode: ensure SERVER_ROOT exists and start FrankenPHP in background
if [ -n "$SERVER_ROOT" ] && [ ! -d "$SERVER_ROOT" ]; then
    mkdir -p "$SERVER_ROOT"
    echo "<html><body><h1>FrankenPHP Ready</h1></body></html>" > "$SERVER_ROOT/index.html"
fi

frankenphp run --config /etc/frankenphp/Caddyfile --adapter caddyfile &
sleep 2

exec "$@"
