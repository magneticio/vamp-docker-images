FROM magneticio/vamp-clique:0.8.1

RUN set -ex && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF && \
    echo "deb http://repos.mesosphere.io/debian jessie main" | tee /etc/apt/sources.list.d/mesosphere.list && \
    apt-get update && \
    apt-get -y install lxc marathon=0.13.0-1.0.440.debian81 mesos=0.24.1-0.2.35.debian81 && \
    apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/* && \
    mkdir -p /usr/local/marathon

ADD mesos-master.sh mesos-slave.sh marathon.sh /usr/local/marathon/

ADD supervisord.conf /etc/supervisor/supervisord.conf
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
