#!/bin/sh

# Substitute environment variables into the Nginx config template
envsubst '$API_URL' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

# Start Nginx
exec nginx -g "daemon off;"
