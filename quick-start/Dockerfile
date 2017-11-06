FROM magneticio/vamp-clique-zookeeper-marathon:VAMP_VERSION

ADD vamp-artifacts /usr/local/vamp/artifacts
ADD vamp-lifter /usr/local/vamp/lifter
ADD vamp-lifter-ui /usr/local/vamp/lifter/ui
ADD vamp-ui /usr/local/vamp/ui
ADD vamp /usr/local/vamp/bin
ADD application.conf logback.xml vamp.sh lifter.sh /usr/local/vamp/
RUN chmod +x /usr/local/vamp/vamp.sh /usr/local/vamp/lifter.sh && mkdir /usr/local/vamp/persistence

ADD supervisord.conf /etc/supervisor/supervisord.conf
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
