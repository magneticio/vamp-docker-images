FROM dockerfile/ubuntu

MAINTAINER tim@magnetic.io

# This Dockerfile packages all Vamp components in one container. The resulting container can be used for basic testing
# kicking the tires. It is not meant for production or any other serious work.
# For more info, see the accompanying README.md and mesos_bootstrap.sh script


#
# First the mostly stable stuff to optimize cache usage
#

# Install Java 8
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Install Haproxy & Supervisor

RUN add-apt-repository -y ppa:vbernat/haproxy-1.5 && \
    apt-get update && \
    apt-get install -y haproxy supervisor


#
# More dynamic stuff
#


# Get Vamp-Core
RUN wget https://bintray.com/artifact/download/magnetic-io/downloads/vamp-core/core-assembly-0.7.5.jar

# Get Vamp-Pulse
RUN wget https://bintray.com/artifact/download/magnetic-io/downloads/vamp-pulse/pulse-assembly-0.7.5.jar

# Get Vamp-Router
RUN wget https://bintray.com/artifact/download/magnetic-io/downloads/vamp-router/vamp-router_0.7.0-RC3_linux_386.zip && \
    unzip vamp-router_0.7.0-RC3_linux_386.zip

COPY logback.xml /root/logback.xml

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY vamp-core.conf /root/vamp-core.conf

# expose the Vamp-core, Vamp-pulse, Vamp-router, Haproxy and Elasticsearch
EXPOSE 8080 8083 10001 1980 9300
# expose lower part of Vamp dynamic port range for initial test
EXPOSE 9050 9051 9052 9053 9054 9055 33000 33001 33003 33004 33005

# Run all parts using a single supervisor command
CMD ["/usr/bin/supervisord"]

