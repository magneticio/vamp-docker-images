FROM magneticio/vamp-dind-1.9:0.8.0

RUN echo "deb http://repos.mesosphere.io/ubuntu/ trusty main" > /etc/apt/sources.list.d/mesosphere.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF && \
    apt-get update -qq && \
    apt-get install -qqy mesos=0.22.0-1.0.ubuntu1404 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY start-slave.sh /start-slave.sh
RUN chmod +x /start-slave.sh

COPY supervisord.conf /etc/supervisor/supervisord.conf

CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
