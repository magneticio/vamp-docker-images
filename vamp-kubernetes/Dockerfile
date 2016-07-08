FROM magneticio/vamp:VAMP_VERSION-custom

ADD application.conf /usr/local/vamp/conf/

ENV VAMP_WAIT_FOR http://elasticsearch:9200/.kibana
