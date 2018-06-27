FROM nginx:1.11.10
LABEL Maintainer Mofesola Babalola <me@mofesola.com>

ARG DOMAIN_NAME
ARG ENCRYPTION_TYPE

RUN apt-get -y update && apt-get install -y cron

COPY conf/certbot-auto /usr/bin/
RUN  certbot-auto --os-packages-only --non-interactive

ENV DOMAIN_NAME $DOMAIN_NAME
ENV ENCRYPTION_TYPE $ENCRYPTION_TYPE

WORKDIR /etc/nginx
COPY conf/nginx.conf /etc/nginx/nginx.conf

COPY conf/default.conf.tmpl /etc/nginx/conf.d/default
COPY conf/defaultautossl.conf.tmpl /etc/nginx/conf.d/defaultautossl.tmpl
COPY conf/defaultselfssl.conf.tmpl /etc/nginx/conf.d/defaultselfssl

COPY conf/fullchain.pem /etc/nginx/conf.d/fullchain.pem
COPY conf/privkey.pem /etc/nginx/conf.d/privkey.pem
COPY conf/entrypoint.sh entrypoint.sh

RUN chmod +x entrypoint.sh
RUN envsubst < /etc/nginx/conf.d/defaultssl.tmpl > /etc/nginx/conf.d/defaultssl

ENTRYPOINT /etc/nginx/entrypoint.sh
EXPOSE 80 443