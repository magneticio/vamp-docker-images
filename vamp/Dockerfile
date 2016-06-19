FROM java:openjdk-8-jre

RUN mkdir -p /usr/local/vamp/log && mkdir -p /usr/local/vamp/conf

ADD ui.tar.bz2 vamp.jar vamp-cli.jar vamp.sh /usr/local/vamp/
ADD vamp-cli.sh /usr/local/bin/vamp

RUN chmod +x /usr/local/bin/vamp && chmod +x /usr/local/vamp/vamp.sh

ENV VAMP_REST_API_UI_DIRECTORY /usr/local/vamp/ui
ENV VAMP_REST_API_UI_INDEX     /usr/local/vamp/ui/index.html

VOLUME /usr/local/vamp/log
VOLUME /usr/local/vamp/conf

CMD ["/usr/local/vamp/vamp.sh"]
