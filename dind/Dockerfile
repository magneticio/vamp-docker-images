FROM ubuntu:14.04

# Based on docker:1.9-dind

RUN apt-get update -qq && \
		apt-get install -qqy curl wget btrfs-tools e2fsprogs iptables xz-utils supervisor && \
		apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 1.9.0
ENV DOCKER_SHA256 5d46455aac507e231fd2a558459779f1994f7151d6cb027efabfa36f568cf017

RUN curl -fSL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-$DOCKER_VERSION" -o /usr/local/bin/docker \
	&& echo "${DOCKER_SHA256}  /usr/local/bin/docker" | sha256sum -c - \
	&& chmod +x /usr/local/bin/docker

# TODO aufs-tools

ENV DIND_COMMIT 4e899d64e020a67ca05f913d354aa8d99a341a7b

RUN wget "https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind" -O /usr/local/bin/dind \
	&& chmod +x /usr/local/bin/dind

COPY dockerd.sh /usr/local/bin/
RUN chmod u+x /usr/local/bin/dockerd.sh

COPY supervisord.conf /etc/supervisor/supervisord.conf

VOLUME /var/lib/docker
EXPOSE 2375

CMD ["supervisord", "-n"]
