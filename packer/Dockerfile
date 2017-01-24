FROM alpine:3.4

ADD stash.sh /bin/stash
RUN chmod u+x /bin/stash && mkdir -p /usr/local/src && mkdir -p /usr/local/stash

VOLUME /usr/local/src
VOLUME /usr/local/stash

ENTRYPOINT ["/bin/stash"]
