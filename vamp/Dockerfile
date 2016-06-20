FROM java:openjdk-8-jre-alpine

RUN mkdir -p /usr/local/vamp/conf

ADD ui.tar.bz2 vamp.jar vamp.sh logback.xml /usr/local/vamp/

RUN chmod +x /usr/local/vamp/vamp.sh

ENV VAMP_REST_API_UI_DIRECTORY /usr/local/vamp/ui
ENV VAMP_REST_API_UI_INDEX     /usr/local/vamp/ui/index.html

VOLUME /usr/local/vamp/conf

CMD ["/usr/local/vamp/vamp.sh"]
