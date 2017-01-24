FROM alpine:3.5

ADD push.sh /bin/push
ADD pull.sh /bin/pull

RUN chmod u+x /bin/push && \
    chmod u+x /bin/pull && \
    mkdir -p /usr/local/src && \
    mkdir -p /usr/local/dst && \
    mkdir -p /usr/local/stash

VOLUME /usr/local/src
VOLUME /usr/local/dst
VOLUME /usr/local/stash

ENTRYPOINT ["/bin/push"]
