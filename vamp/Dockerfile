FROM java:openjdk-8-jre

RUN mkdir -p /usr/local/vamp/log && mkdir -p /usr/local/vamp/conf

ADD vamp.jar vamp-cli.jar /usr/local/vamp/
ADD conf /usr/local/vamp/conf
ADD vamp-cli.sh /usr/local/bin/vamp

RUN chmod +x /usr/local/bin/vamp

VOLUME /usr/local/vamp/log
VOLUME /usr/local/vamp/conf

CMD ["java", "-Dlogback.configurationFile=/usr/local/vamp/conf/logback.xml", "-Dconfig.file=/usr/local/vamp/conf/application.conf", "-jar", "/usr/local/vamp/vamp.jar"]
