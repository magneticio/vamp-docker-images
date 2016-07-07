FROM magneticio/vamp-clique-zookeeper-marathon:VAMP_VERSION

RUN mkdir -p /usr/local/vamp

ADD ui.tar.bz2 vamp.jar application.conf logback.xml vamp.sh /usr/local/vamp/
RUN chmod +x /usr/local/vamp/vamp.sh

ADD supervisord.conf /etc/supervisor/supervisord.conf
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
