#!/bin/sh
# Entrypoint for the all-in-one image. Generates conf.d/00-real-ip.conf from
# TRUSTED_PROXY_CIDRS (same logic as web/docker-entrypoint.d/10-real-ip.sh),
# then hands over to supervisord, which keeps both nginx and the API server
# running and forwards the stop signal to them in order.
set -eu

: "${TRUSTED_PROXY_CIDRS:=10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 127.0.0.1/32 ::1/128}"

conf=/etc/nginx/conf.d/00-real-ip.conf
{
    echo '# Generated at container start from $TRUSTED_PROXY_CIDRS. Do not edit by hand.'
    echo 'real_ip_header X-Forwarded-For;'
    echo 'real_ip_recursive on;'
    for cidr in $TRUSTED_PROXY_CIDRS; do
        echo "set_real_ip_from $cidr;"
    done
} > "$conf"

exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
