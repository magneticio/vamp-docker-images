FROM magneticio/java:openjdk-8-jre-alpine

# https://github.com/peterbourgon/runsvinit
ENV RUNSVINIT_URL=https://github.com/peterbourgon/runsvinit/releases/download/v2.0.0/runsvinit-linux-amd64.tgz

ENV HTTPBEAT_VER=4.0.0
ENV HTTPBEAT_URL=https://github.com/christiangalsterer/httpbeat/releases/download/${HTTPBEAT_VER}/httpbeat-${HTTPBEAT_VER}-linux-x86_64.tar.gz

RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
    ALPINE_GLIBC_PACKAGE_VERSION="2.23-r3" && \
    ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    wget \
        "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/sgerrand.rsa.pub" \
        -O "/etc/apk/keys/sgerrand.rsa.pub" && \
    wget \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    apk add --no-cache \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true && \
    echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
    \
    apk del glibc-i18n && \
    \
    rm "/root/.wget-hsts" && \
    apk del .build-dependencies && \
    rm \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"

ENV LANG=C.UTF-8

RUN set -xe \
    && apk add --no-cache \
      bash \
      curl \
      runit \
    && curl --location --silent --show-error $RUNSVINIT_URL --output - | tar zxf - -C /sbin \
    && chown 0:0 /sbin/runsvinit \
    && chmod 0775 /sbin/runsvinit \
    && mkdir -p /usr/local/httpbeat/ \
    && curl --location --silent --show-error $HTTPBEAT_URL --output - | tar zxf - -C /tmp \
    && mv /tmp/httpbeat-5.2.1-SNAPSHOT-linux-x86_64/httpbeat /usr/local/httpbeat/ \
    && rm -rf /tmp/httpbeat-5.2.1-SNAPSHOT-linux-x86_64

RUN mkdir -p /usr/local/vamp/conf
ADD vamp-artifacts /usr/local/vamp/artifacts
ADD vamp-lifter /usr/local/vamp/lifter
ADD vamp-lifter-ui /usr/local/vamp/lifter/ui
ADD vamp-ui /usr/local/vamp/ui
ADD vamp /usr/local/vamp/bin
ADD files/ /

ENV VAMP_REST_API_UI_DIRECTORY /usr/local/vamp/ui
ENV VAMP_REST_API_UI_INDEX     /usr/local/vamp/ui/index.html

VOLUME /usr/local/vamp/conf

CMD ["/sbin/runsvinit"]
