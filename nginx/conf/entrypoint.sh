#!/usr/bin/env bash
rm /etc/nginx/conf.d/*.conf
if [ "$ENCRYPTION_TYPE" = "auto" ]; then
	echo "ENCRYPTION_TYPE was auto, use a cert from letsencrypt" \
	&& cp /etc/nginx/conf.d/defaultautossl /etc/nginx/conf.d/defaultautossl.conf \
	&& (crontab -l 2>/dev/null; echo "30 2 * * 1 /usr/bin/certbot-auto renew --quiet --no-self-upgrade >> /var/log/letsencrypt/le-renew.log") | crontab - \
	&& mkdir -p /var/log/letsencrypt && touch /var/log/letsencrypt/install.log \
	&& if [ ! -f /etc/letsencrypt/live/${DOMAIN_NAME}/cert.pem ]; then
		echo "there was no cert, try to get one from letsencrypt" \
	    && certbot-auto certonly --standalone --non-interactive --agree-tos --email admin@${DOMAIN_NAME} -d ${DOMAIN_NAME} 2>&1 | tee /var/log/letsencrypt/install.log
	fi \
    && nginx -s reload
elif [ "$ENCRYPTION_TYPE" = "self" ]; then
    echo "ENCRYPTION_TYPE was self, use the provided ssl cert" \
    && cp /etc/nginx/conf.d/defaultselfssl /etc/nginx/conf.d/defaultselfssl.conf
elif [ "$ENCRYPTION_TYPE" = "none" ]; then
	echo "ENCRYPTION_TYPE was none, use http only" \
   	&& cp /etc/nginx/conf.d/default /etc/nginx/conf.d/default.conf
fi
nginx -g "daemon off;"
