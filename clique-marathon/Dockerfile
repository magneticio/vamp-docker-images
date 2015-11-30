FROM magneticio/vamp-clique:0.8.0

RUN set -ex && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF && \
    echo deb http://repos.mesosphere.io/ubuntu trusty main > /etc/apt/sources.list.d/mesosphere.list && \
    apt-get update && \
    apt-get -y install lxc marathon=0.11.1-1.0.432.ubuntu1404 mesos=0.24.1-0.2.35.ubuntu1404 && \
    apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/* && \
    mkdir -p /usr/local/marathon

ADD mesos-master.sh mesos-slave.sh marathon.sh /usr/local/marathon/

ADD supervisord.conf /etc/supervisor/supervisord.conf
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]