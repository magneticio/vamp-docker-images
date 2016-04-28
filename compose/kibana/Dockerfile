FROM kibana:4.5.0

ADD start.sh /start.sh

RUN chmod u+x /start.sh && \
    apt-get update && apt-get install -y curl && \
    kibana plugin --install elastic/sense

ADD kibana.yml /usr/share/kibana/config/kibana.yml

ENTRYPOINT ["/start.sh"]
