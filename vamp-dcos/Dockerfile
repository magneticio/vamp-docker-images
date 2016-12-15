FROM magneticio/vamp:VAMP_VERSION-custom

ADD artifacts/breeds/vga.js /usr/local/vamp/artifacts/breeds/
ADD artifacts/workflows/vga.js /usr/local/vamp/artifacts/workflows/
ADD application.conf /usr/local/vamp/conf/

ENV VAMP_WAIT_FOR http://elasticsearch-executor.elasticsearch.mesos:9200/.kibana
