FROM nginx:1.7
MAINTAINER tim@magnetic.io

# This Dockerfile packages nginx instance specifically configured to function as a proxy for a Docker registry.
# It is based on the containersol/docker-registry-proxy image.

COPY default.conf /etc/nginx/conf.d/default.conf
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]

CMD ["nginx", "-g", "daemon off;"]