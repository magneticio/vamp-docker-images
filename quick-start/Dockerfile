FROM magneticio/vamp-clique-zookeeper-marathon:VAMP_VERSION

ADD vamp-artifacts /usr/local/vamp/artifacts
ADD vamp-ui /usr/local/vamp/ui
ADD vamp /usr/local/vamp/bin
ADD application.conf logback.xml /usr/local/vamp/
ADD vamp.sh /usr/local/vamp/vamp
RUN chmod +x /usr/local/vamp/vamp

ADD supervisord.conf /etc/supervisor/supervisord.conf
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
