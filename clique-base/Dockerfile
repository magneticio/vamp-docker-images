FROM ubuntu:16.04

# Elasticsearch and Kibana

ENV ELASTICSEARCH_MAJOR 2.4
ENV ELASTICSEARCH_VERSION 2.4.4
ENV ELASTICSEARCH_REPO_BASE http://packages.elasticsearch.org/elasticsearch/2.x/debian

ENV KIBANA_VERSION 4.6.4

RUN set -ex && \
    groupadd -r elasticsearch && useradd -r -m -g elasticsearch elasticsearch && \
    groupadd -r kibana && useradd -r -m -g kibana kibana && \
		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    arch="$(dpkg --print-architecture)" && \
	  apt-get update && \
    apt-get install -y curl locales && \
    locale-gen en_US.UTF-8 && \
    curl -o /usr/local/bin/gosu -fSL "https://github.com/tianon/gosu/releases/download/1.3/gosu-$arch" && \
	  curl -o /usr/local/bin/gosu.asc -fSL "https://github.com/tianon/gosu/releases/download/1.3/gosu-$arch.asc" && \
	  gpg --verify /usr/local/bin/gosu.asc && \
	  rm /usr/local/bin/gosu.asc && \
	  chmod +x /usr/local/bin/gosu && \
		apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 46095ACC8548582C1A2699A9D27D666CD88E42B4 && \
    echo "deb $ELASTICSEARCH_REPO_BASE stable main" > /etc/apt/sources.list.d/elasticsearch.list && \
	  apt-get update && \
	  apt-get install -y wget supervisor openjdk-8-jre unzip && \
		apt-get install -y --no-install-recommends elasticsearch=$ELASTICSEARCH_VERSION && \
	  for path in \
		  /usr/share/elasticsearch/data \
		  /usr/share/elasticsearch/logs \
		  /usr/share/elasticsearch/config \
		  /usr/share/elasticsearch/config/scripts \
	  ; do \
		  mkdir -p "$path"; \
		  chown -R elasticsearch:elasticsearch "$path"; \
	  done && \
		curl -fSL "https://download.elastic.co/kibana/kibana/kibana-${KIBANA_VERSION}-linux-x86_64.tar.gz" -o kibana.tar.gz && \
	  mkdir -p /usr/share/kibana && \
	  tar -xz --strip-components=1 -C /usr/share/kibana -f kibana.tar.gz && \
	  chown -R kibana:kibana /usr/share/kibana && \
	  rm kibana.tar.gz && \
	  /usr/share/kibana/bin/kibana plugin --install elastic/sense && \
	  chown -R elasticsearch:elasticsearch /usr/share/elasticsearch && \
	  chown -R kibana:kibana /usr/share/kibana && \
	  mkdir -p /usr/local/vamp && \
	  apt-get purge -y gcc make && \
	  apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV PATH /usr/share/elasticsearch/bin:/usr/share/kibana/bin:$PATH

ADD elasticsearch/elasticsearch.yml elasticsearch/logging.yml /usr/share/elasticsearch/config/
ADD kibana/kibana.yml /usr/share/kibana/config/kibana.yml
ADD kibana/start.sh /usr/share/kibana/bin/kibana-start

EXPOSE 9200 9300
EXPOSE 5601

ADD supervisord.conf /etc/supervisor/supervisord.conf
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
