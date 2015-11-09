FROM kibana:4.2

ADD start.sh /start.sh

RUN chmod u+x /start.sh && \
    apt-get update && apt-get install -y netcat && \
    kibana plugin --install elastic/sense

CMD ["/start.sh"]
