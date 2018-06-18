#!/usr/bin/env bash

if [ "$ENCRYPTION_TYPE" = "auto" ]; then
	echo "ENCRYPTION_TYPE was auto, gonna use letsencrypt" \
	&& (crontab -l 2>/dev/null; echo "30 2 * * 1 /usr/bin/certbot-auto renew --quiet --no-self-upgrade >> /var/log/letsencrypt/le-renew.log") | crontab - \
	&& mkdir -p /var/log/letsencrypt && touch /var/log/letsencrypt/install.log \
	&& if [ ! -f /etc/letsencrypt/live/${DOMAIN_NAME}/cert.pem ]; then
		echo "there was no cert, gonna try letsencrypt" \
	    && certbot-auto certonly --standalone --non-interactive --agree-tos --email admin@${DOMAIN_NAME} -d ${DOMAIN_NAME} 2>&1 | tee /var/log/letsencrypt/install.log \
	   	&& if [ -f /etc/letsencrypt/live/${DOMAIN_NAME}/cert.pem ]; then
	       	echo "letsencrypt was successful, use generated cert" \
	        && mv /etc/nginx/conf.d/defaultssl /etc/nginx/conf.d/defaultssl.conf && nginx -s reload
	    else
			echo "letsencrypt failed, use regular http" \
		   	&& mv /etc/nginx/conf.d/default /etc/nginx/conf.d/default.conf
		fi
	fi
elif [ "$ENCRYPTION_TYPE" = "user" ]; then
    echo "ENCRYPTION_TYPE was user" \
    && mv /etc/nginx/conf.d/defaultownssl /etc/nginx/conf.d/defaultownssl.conf
elif [ "$ENCRYPTION_TYPE" = "none" ]; then
	echo "ENCRYPTION_TYPE was none" \
   	&& mv /etc/nginx/conf.d/default /etc/nginx/conf.d/default.conf
fi
nginx -g "daemon off;"