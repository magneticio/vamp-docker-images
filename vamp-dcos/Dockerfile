FROM magneticio/vamp:VAMP_VERSION-custom

ADD application.conf /usr/local/vamp/conf/
ADD https://raw.githubusercontent.com/magneticio/vamp-artifacts/master/breeds/vga.js /usr/local/vamp/artifacts/breeds/
ADD https://raw.githubusercontent.com/magneticio/vamp-artifacts/master/workflows/vga.yml /usr/local/vamp/artifacts/workflows/

ENV VAMP_WAIT_FOR http://elasticsearch-executor.elasticsearch.mesos:9200/.kibana
