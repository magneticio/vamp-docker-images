FROM magneticio/vamp-clique-base:VAMP_VERSION

ENV ETCD_VERSION 2.3.7

RUN wget https://github.com/coreos/etcd/releases/download/v$ETCD_VERSION/etcd-v$ETCD_VERSION-linux-amd64.tar.gz

RUN set -ex && \
    tar xzvf etcd-v$ETCD_VERSION-linux-amd64.tar.gz && \
    mv etcd-v$ETCD_VERSION-linux-amd64/etcd* /bin/ && \
    rm -Rf etcd-v$ETCD_VERSION-linux-amd64* /var/cache/apk/*

EXPOSE 2379 2380 4001 7001

# workaround, etcd will parse ETCD_VERSION as boolean
ENV ETCD_VERSION true

ADD supervisord.conf /etc/supervisor/supervisord.conf
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
