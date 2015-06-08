FROM ubuntu

MAINTAINER matthijs@magnetic.io

# This Dockerfile packages Vamp-pulse. The resulting container can be used for basic testing
# kicking the tires. It is not meant for production or any other serious work.
# For more info, see the accompanying README.md

RUN apt-get install software-properties-common -y

# Install Java 8
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle


# Install Supervisor

RUN apt-get update && \
    apt-get install -y supervisor


# Get Vamp-Pulse
RUN wget https://bintray.com/artifact/download/magnetic-io/downloads/vamp-pulse/pulse-server-assembly-0.7.7-rc1.jar


COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf


# expose the Vamp-pulse and Elasticsearch
EXPOSE 8083 9300

# Run all parts using a single supervisor command
CMD ["/usr/bin/supervisord"]

