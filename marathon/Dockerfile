FROM magneticio/vamp-mesos-0.25.0:0.8.0

ADD marathon.jar /usr/local/marathon/
ADD start.sh /usr/local/bin/marathon

RUN chmod u+x /usr/local/bin/marathon

ENTRYPOINT ["/usr/local/bin/marathon"]
