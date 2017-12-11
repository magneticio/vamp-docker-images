FROM magneticio/vamp-clique-zookeeper:VAMP_VERSION

RUN set -ex && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF && \
    echo "deb http://repos.mesosphere.io/debian jessie main" | tee /etc/apt/sources.list.d/mesosphere.list && \
    apt-get update && \
    apt-mark hold openjdk-9-jre-headless && \
    apt-get -y install lxc marathon=0.15.6-1.0.484.debian81 mesos=0.27.0-0.2.190.debian81 chronos=2.4.0-0.1.20151007110204.debian81 && \
    apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/* && \
    mkdir -p /usr/local/marathon

COPY mesos-master.sh mesos-slave.sh marathon.sh chronos.sh /usr/local/marathon/

COPY supervisord.conf /etc/supervisor/supervisord.conf
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
