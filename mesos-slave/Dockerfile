FROM magneticio/vamp-mesos-0.25.0:0.8.0

ADD supervisord.conf /etc/supervisor/supervisord.conf
ADD start-slave.sh /usr/local/bin/mesos-start-slave

RUN chmod u+x /usr/local/bin/mesos-start-slave
