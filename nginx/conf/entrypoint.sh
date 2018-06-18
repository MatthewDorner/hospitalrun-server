#!/usr/bin/env bash
if [[ -f /etc/nginx/fullchain.pem ] && [ -f /etc/nginx/privkey.pem ]]; then
       mv /etc/nginx/conf.d/defaultssl /etc/nginx/conf.d/defaultssl.conf \
    && rm /etc/nginx/conf.d/default.conf  \
    && nginx -s reload
else
	(crontab -l 2>/dev/null; echo "30 2 * * 1 /usr/bin/certbot-auto renew --quiet --no-self-upgrade >> /var/log/letsencrypt/le-renew.log") | crontab -
	mkdir -p /var/log/letsencrypt && touch /var/log/letsencrypt/install.log
	if [ ! -f /etc/letsencrypt/live/${DOMAIN_NAME}/cert.pem ]; then
	    certbot-auto certonly --standalone --non-interactive --agree-tos --email admin@${DOMAIN_NAME} -d ${DOMAIN_NAME} 2>&1 | tee /var/log/letsencrypt/install.log \
	               && if [ -f /etc/letsencrypt/live/${DOMAIN_NAME}/cert.pem ]; then
	                       mv /etc/nginx/conf.d/defaultssl /etc/nginx/conf.d/defaultssl.conf \
	                    && rm /etc/nginx/conf.d/default.conf  \
	                    && nginx -s reload
	                  fi \
	               &
	fi
fi
nginx -g "daemon off;"



# should it be
# if you have user certs
#	try to use user's, if it fails it'll use unencrypted
# else
#	try to do letsencrypt, if it fails it'll use unencrypted





# if there is no DOMAIN_NAME
#	leave the regular default.conf in place
# else
# 	if letsencrypt is successful
#		use defaultssl.conf
#	else
#		leave the regular default.conf in place


# change to:
#
# if there is no DOMAIN_NAME
#	if there are user SSL certs copied:
#	  	use whatever is necessary for user SSL certs
#	else
#	  	leave the regular default.conf in place (do nothing but run nginx)
# else
# 	if letsencrypt is successful
#		use defaultssl.conf
#	else
#		leave the regular default.conf in place (do nothing but run nginx)


# ??? change to:
#
# if there is no DOMAIN_NAME && if there are user SSL certs copied:
#	  	use whatever is necessary for user SSL certs
# else if there is a DOMAIN_NAME
# 	if letsencrypt is successful
#		use defaultssl.conf

# run nginx


# letsencrypt puts its cert into a folder inside /letsencrypt/.
# the defaultssl.conf finds the cert by referring to $DOMAIN_NAME
#
# the regular conf doesn't need any change... unless possibly the default_server
#
# so how to handle the defaultssl.conf, between letsencrypt and user cert?
# can we keep the same defaultssl.conf? maybe a conditional?
#
# want to leave the letsencrypt ssl cert in its same location


# i had nginx dockerfile copy the self-signed keys to /etc/nginx.
#
# that dockerfile uses envsubst, so interestingly this could also be used to
# substitute the user's certs... maybe
#
#
#
#
#
#
# one issue here being that there are two conditions:
#	is there a $DOMAIN_NAME
#	is there user-defined certs
#
#	should they be treated as one and the same, and if they're not the user has committed an error?
#	or should they be handled best as possible independently, such as if no DOMAIN_NAME and no
#	user-defined certs..... well it will use the default config anyway.



# so in that dockerfile, I can change the env DOMAIN_NAME to an env CERT_PATH
#
# and if the user's certs exist, they will be copied AND the path will be set to that
#
#
# but there must consider the synchronizing of these conditionals with the conditionals in the entrypoint..
#
# so it'd have to be if there is an DOMAIN_NAME && there are user SSL certs, then change the path.. or whatever
# else, it'd have to match.

# so maybe it should be as simple as
#
# if you have DOMAIN_NAME
#	try to do letsencrypt, if it fails it'll use unencrypted
# else
#	try to use user's, if it fails it'll use unencrypted
#
# ^ here, if you left DOMAIN_NAME as is but also have user certs, it won't use the user certs if letsencrypt fails
#
#
#
#
#
# or should it be
# if you have user certs
#	try to use user's, if it fails it'll use unencrypted
# else
#	try to do letsencrypt, if it fails it'll use unencrypted
#
# ^ here, if you have user certs but... what? I guess this one is preferable.
#	since there is no failure (at least detectable) with user certs, this one is preferable???
#
#
#



