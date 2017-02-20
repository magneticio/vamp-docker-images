FROM magneticio/java:openjdk-8-jre-alpine

# https://github.com/peterbourgon/runsvinit
ENV RUNSVINIT_URL=https://github.com/peterbourgon/runsvinit/releases/download/v2.0.0/runsvinit-linux-amd64.tgz

RUN set -xe \
    && apk add --no-cache \
      bash \
      curl \
      runit \
    && curl --location --silent --show-error $RUNSVINIT_URL --output - | tar zxf - -C /sbin \
    && chown 0:0 /sbin/runsvinit \
    && chmod 0775 /sbin/runsvinit

RUN mkdir -p /usr/local/vamp/conf
ADD vamp-artifacts /usr/local/vamp/artifacts
ADD vamp-ui /usr/local/vamp/ui
ADD vamp /usr/local/vamp/bin
ADD files/ /

ENV VAMP_REST_API_UI_DIRECTORY /usr/local/vamp/ui
ENV VAMP_REST_API_UI_INDEX     /usr/local/vamp/ui/index.html

VOLUME /usr/local/vamp/conf

CMD ["/sbin/runsvinit"]
