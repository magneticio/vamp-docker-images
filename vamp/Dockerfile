FROM java:openjdk-8-jre

RUN mkdir -p /usr/local/vamp/log && mkdir -p /usr/local/vamp/conf

ADD ui.tar.bz2 vamp.jar vamp-cli.jar start.sh /usr/local/vamp/
ADD vamp-cli.sh /usr/local/bin/vamp/

RUN chmod +x /usr/local/bin/vamp && chmod +x /usr/local/vamp/start.sh

VOLUME /usr/local/vamp/log
VOLUME /usr/local/vamp/conf

CMD ["/usr/local/vamp/start.sh"]
