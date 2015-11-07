FROM magneticio/vamp-dind-1.9:0.8.0

WORKDIR /opt/marathon
ADD marathon.jar start /opt/marathon/

ENV DEBIAN_FRONTEND noninteractive
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF && \
    echo "deb http://ppa.launchpad.net/openjdk-r/ppa/ubuntu trusty main" > /etc/apt/sources.list.d/openjdk.list && \
    echo "deb http://repos.mesosphere.io/ubuntu/ trusty main" > /etc/apt/sources.list.d/mesosphere.list && \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends --force-yes openjdk-8-jre mesos=0.25.0-0.2.70.ubuntu1404 && \
    apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/opt/marathon/start"]
