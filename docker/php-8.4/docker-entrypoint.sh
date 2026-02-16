#!/bin/sh
set -e

################################################################
# If first arg starts with "-" (default CMD), run FrankenPHP in foreground
# This is the normal behavior for docker compose
if [ "${1#-}" != "$1" ]; then
    exec frankenphp run "$@"
fi

################################################################
# Otherwise (CI/CD), start FrankenPHP in background then exec command
frankenphp run --config /etc/frankenphp/Caddyfile --adapter caddyfile &
sleep 2

exec "$@"
