FROM nginx:1.11.5-alpine

MAINTAINER Stephen Hoogendijk <stephen@mycujoo.tv>

ADD nginx.conf /etc/nginx/nginx.conf
ADD proxy.conf /etc/nginx/conf.d/proxy.conf

RUN chown nginx /etc/nginx/nginx.conf /etc/nginx/conf.d/proxy.conf
