FROM magneticio/vamp-clique-common:0.8.2

ENV VERSION 2.2.3

RUN set -ex && \
    wget https://github.com/coreos/etcd/releases/download/v$VERSION/etcd-v$VERSION-linux-amd64.tar.gz && \
    tar xzvf etcd-v$VERSION-linux-amd64.tar.gz && \
    mv etcd-v$VERSION-linux-amd64/etcd* /bin/ && \
    rm -Rf etcd-v$VERSION-linux-amd64* /var/cache/apk/*

EXPOSE 2379 2380 4001 7001

ADD supervisord.conf /etc/supervisor/supervisord.conf
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
