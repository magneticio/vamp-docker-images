FROM magneticio/vamp-clique-base:VAMP_VERSION

ENV CONSUL_VERSION 0.7.0
ENV CONSUL_SHA256 b350591af10d7d23514ebaa0565638539900cdb3aaa048f077217c4c46653dd8

ENV DNS_RESOLVES consul
ENV DNS_PORT 8600

ADD ./conf /config/
ADD https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip /tmp/consul.zip
ADD https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_web_ui.zip /tmp/webui.zip

RUN set -ex && \
    echo "${CONSUL_SHA256} /tmp/consul.zip" > /tmp/consul.sha256 && \
    sha256sum -c /tmp/consul.sha256 && \
    cd /bin && \
    unzip /tmp/consul.zip && \
    chmod +x /bin/consul && \
    rm /tmp/consul.zip && \
    cd /tmp && \
    mkdir /ui && \
    unzip webui.zip -d /ui && \
    rm webui.zip

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 8600 8600/udp

ADD supervisord.conf /etc/supervisor/supervisord.conf
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
