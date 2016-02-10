FROM magneticio/vamp-clique-base:0.8.3

ENV ZOOKEEPER_VERSION 3.4.6

RUN set -ex && \
    wget -q -O - http://apache.mirrors.pair.com/zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz | tar -xzf - -C /usr/local && \
		mv /usr/local/zookeeper-$ZOOKEEPER_VERSION /usr/local/zookeeper && \
		mv /usr/local/zookeeper/bin/zkServer.sh /usr/local/zookeeper/bin/zookeeper && \
		cp /usr/local/zookeeper/conf/zoo_sample.cfg /usr/local/zookeeper/conf/zoo.cfg && \
		mkdir -p /tmp/zookeeper

ENV PATH /usr/local/zookeeper/bin:$PATH

EXPOSE 2181 2888 3888

ADD supervisord.conf /etc/supervisor/supervisord.conf
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
