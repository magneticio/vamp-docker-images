FROM magneticio/java:openjdk-8-jre-alpine

RUN mkdir -p /usr/local/vamp/conf
ADD vamp-artifacts /usr/local/vamp/artifacts
ADD vamp-ui /usr/local/vamp/ui
ADD vamp /usr/local/vamp/bin
ADD logback.xml /usr/local/vamp/
ADD vamp.sh /usr/local/vamp/vamp
RUN chmod +x /usr/local/vamp/vamp

ENV VAMP_REST_API_UI_DIRECTORY /usr/local/vamp/ui
ENV VAMP_REST_API_UI_INDEX     /usr/local/vamp/ui/index.html

VOLUME /usr/local/vamp/conf

CMD ["/usr/local/vamp/vamp"]
