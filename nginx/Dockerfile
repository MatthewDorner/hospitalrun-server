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

COPY conf/default.conf.tmpl /etc/nginx/conf.d/default.conf
COPY conf/defaultssl.conf.tmpl /etc/nginx/conf.d/defaultssl.conf.tmpl
COPY conf/defaultownssl.conf.tmpl /etc/nginx/conf.d/defaultownssl.conf
COPY conf/fullchain.pem /etc/nginx/conf.d/fullchain.pem
COPY conf/privkey.pem /etc/nginx/conf.d/privkey.pem
COPY conf/entrypoint.sh entrypoint.sh

RUN chmod +x entrypoint.sh
RUN envsubst < /etc/nginx/conf.d/defaultssl.conf.tmpl > /etc/nginx/conf.d/defaultssl.conf

ENTRYPOINT /etc/nginx/entrypoint.sh
EXPOSE 80 443