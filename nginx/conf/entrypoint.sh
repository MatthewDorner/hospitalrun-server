#!/usr/bin/env bash
if [ ! -z "$DOMAIN_NAME" ]; then
	echo "DOMAIN_NAME was set, gonna use letsencrypt" \
	&& (crontab -l 2>/dev/null; echo "30 2 * * 1 /usr/bin/certbot-auto renew --quiet --no-self-upgrade >> /var/log/letsencrypt/le-renew.log") | crontab - \
	&& mkdir -p /var/log/letsencrypt && touch /var/log/letsencrypt/install.log \
	&& if [ ! -f /etc/letsencrypt/live/${DOMAIN_NAME}/cert.pem ]; then
		echo "there was no cert, gonna try letsencrypt" \
	    && certbot-auto certonly --standalone --non-interactive --agree-tos --email admin@${DOMAIN_NAME} -d ${DOMAIN_NAME} 2>&1 | tee /var/log/letsencrypt/install.log \
	   	&& if [ -f /etc/letsencrypt/live/${DOMAIN_NAME}/cert.pem ]; then
	       	echo "letsencrypt was successful, use generated cert" \
	        && rm /etc/nginx/conf.d/defaultownssl.conf && rm /etc/nginx/conf.d/default.conf && nginx -s reload
	    else
			echo "letsencrypt failed, use regular http" \
		   	&& rm /etc/nginx/conf.d/defaultownssl.conf && rm /etc/nginx/conf.d/defaultssl.conf
		fi
	fi
elif [ -e /etc/nginx/conf.d/fullchain.pem -a -e /etc/nginx/conf.d/privkey.pem ]; then
    echo "DOMAIN_NAME was not set, but there was a user cert" \
    && rm /etc/nginx/conf.d/defaultssl.conf && rm /etc/nginx/conf.d/default.conf
else
	echo "there was no DOMAIN_NAME or user cert, use http" \
   	&& rm /etc/nginx/conf.d/defaultownssl.conf && rm /etc/nginx/conf.d/defaultssl.conf
fi
nginx -g "daemon off;"