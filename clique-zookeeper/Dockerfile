FROM magneticio/vamp-clique-base:VAMP_VERSION

ENV ZOOKEEPER_VERSION 3.4.10

RUN set -ex && \
    URL=$(curl -s 'https://www.apache.org/dyn/closer.cgi?as_json=1' | grep preferred | sed -e 's,.*preferred[^:]*:[^"]*",,g' -e 's,"$,,g' -e 's,/$,,g') && \
    wget -q -O - ${URL}/zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz | tar -xzf - -C /usr/local && \
		mv /usr/local/zookeeper-$ZOOKEEPER_VERSION /usr/local/zookeeper && \
		mv /usr/local/zookeeper/bin/zkServer.sh /usr/local/zookeeper/bin/zookeeper && \
		cp /usr/local/zookeeper/conf/zoo_sample.cfg /usr/local/zookeeper/conf/zoo.cfg && \
		mkdir -p /tmp/zookeeper

ENV PATH /usr/local/zookeeper/bin:$PATH
ADD log4j.properties usr/local/zookeeper/conf/

ADD zk.sh zk-web.jar /usr/local/zookeeper/
ADD zk-web-conf.clj /usr/local/zookeeper/conf

RUN chmod +x /usr/local/zookeeper/zk.sh

EXPOSE 2181 2888 3888 8989

ADD supervisord.conf /etc/supervisor/supervisord.conf
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
