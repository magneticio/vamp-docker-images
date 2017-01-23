FROM magneticio/vamp-clique-zookeeper-marathon:VAMP_VERSION

ADD artifacts /usr/local/vamp/artifacts
ADD ui.tar.bz2 vamp-*.tar.gz  application.conf logback.xml /usr/local/vamp/
ADD vamp.sh /usr/local/vamp/vamp
RUN chmod +x /usr/local/vamp/vamp

ADD supervisord.conf /etc/supervisor/supervisord.conf
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
