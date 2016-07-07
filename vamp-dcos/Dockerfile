FROM magneticio/vamp:VAMP_VERSION

ADD vamp.sh /usr/local/vamp/
ADD application.conf /usr/local/vamp/conf/

RUN set -ex && \
    apk --update add curl && \
    rm /var/cache/apk/* && \
    chmod +x /usr/local/vamp/vamp.sh

EXPOSE 8080
