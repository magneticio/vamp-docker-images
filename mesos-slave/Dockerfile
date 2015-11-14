FROM magneticio/vamp-mesos-0.25.0:0.8.0


ADD start-slave.sh /usr/local/bin/mesos-start-slave

RUN chmod u+x /usr/local/bin/mesos-start-slave && mkdir -p /mnt/mesos/sandbox

ENTRYPOINT ["/usr/local/bin/mesos-start-slave"]
