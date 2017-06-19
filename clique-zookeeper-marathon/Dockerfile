FROM magneticio/vamp-clique-zookeeper:VAMP_VERSION

RUN set -ex && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF && \
    echo "deb http://repos.mesosphere.io/debian jessie main" | tee /etc/apt/sources.list.d/mesosphere.list && \
    apt-get update && \
    apt-get -y install lxc marathon=1.4.3-1.0.649.debian81 mesos=1.2.0-2.0.6 chronos=2.4.0-0.1.20151007110204.debian81 && \
    apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/* && \
    mkdir -p /usr/local/marathon

ADD mesos-master.sh mesos-slave.sh marathon.sh chronos.sh /usr/local/marathon/

ADD supervisord.conf /etc/supervisor/supervisord.conf
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
