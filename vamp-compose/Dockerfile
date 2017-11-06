FROM magneticio/vamp:VAMP_VERSION

ADD files/ /
ADD artifacts/ /usr/local/vamp/artifacts
ADD vamp.conf /usr/local/vamp/conf/application.conf
ADD lifter.conf /usr/local/vamp/lifter/application.conf
RUN rm /usr/local/vamp/vamp && \
    chmod +x /usr/local/vamp/vamp.sh /usr/local/vamp/lifter.sh

CMD ["/sbin/runsvinit"]
