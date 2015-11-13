FROM ubuntu:14.04

# Docker in Docker (based on docker:1.9-dind) + Java 8 (OpenJDK)

ENV DEBIAN_FRONTEND noninteractive
ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 1.9.0
ENV DOCKER_SHA256 5d46455aac507e231fd2a558459779f1994f7151d6cb027efabfa36f568cf017
ENV DIND_COMMIT 4e899d64e020a67ca05f913d354aa8d99a341a7b

ADD dockerd.sh /usr/local/bin/

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv 86F44E2A && \
		echo "deb http://ppa.launchpad.net/openjdk-r/ppa/ubuntu trusty main" > /etc/apt/sources.list.d/openjdk.list && \
    apt-get update -qq && \
		apt-get install -qqy --no-install-recommends --force-yes curl wget btrfs-tools e2fsprogs iptables xz-utils supervisor openjdk-8-jdk && \
		apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
		curl -fSL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-$DOCKER_VERSION" -o /usr/local/bin/docker && \
		echo "${DOCKER_SHA256}  /usr/local/bin/docker" | sha256sum -c - && \
		chmod +x /usr/local/bin/docker && \
    wget "https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind" -O /usr/local/bin/dind && \
	  chmod +x /usr/local/bin/dind && \
	  chmod u+x /usr/local/bin/dockerd.sh

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV PATH $PATH:$JAVA_HOME/bin
ENV LD_LIBRARY_PATH /usr/local/lib

ADD supervisord.conf /etc/supervisor/supervisord.conf

VOLUME /var/lib/docker
EXPOSE 2375

CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
