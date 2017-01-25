FROM magneticio/vamp:VAMP_VERSION-custom

ADD application.conf /usr/local/vamp/conf/

ENV VAMP_WAIT_FOR http://elasticsearch-executor.elasticsearch.mesos:9200/.kibana
