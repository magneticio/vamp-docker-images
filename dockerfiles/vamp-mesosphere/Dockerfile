FROM ubuntu

MAINTAINER tim@magnetic.io

# This Dockerfile packages all Vamp components in one container. The resulting container can be used for basic testing
# kicking the tires. It is not meant for production or any other serious work.

RUN apt-get -y install software-properties-common apt-transport-https curl zip

# Install Java 8
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
 add-apt-repository -y ppa:webupd8team/java && \
 apt-get update && \
 apt-get install -y oracle-java8-installer && \
 rm -rf /var/lib/apt/lists/* && \
 rm -rf /var/cache/oracle-jdk8-installer

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Install Haproxy & Supervisor

RUN sudo apt-get update && \
    sudo apt-get install -y supervisor

# More dynamic stuff

# Add bintray key
RUN curl https://bintray.com/user/downloadSubjectPublicKey?username=bintray | apt-key add -

RUN echo "deb https://dl.bintray.com/magnetic-io/upstart trusty main" >> /etc/apt/sources.list && \
    apt-get update

# Get Vamp-Core
RUN apt-get install -y vamp-core

# Get Vamp-Pulse
RUN apt-get install -y vamp-pulse


COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY vamp-core.conf /usr/share/vamp-core/conf/application.conf
COPY vamp-pulse.conf /usr/share/vamp-pulse/conf/application.conf

# expose the Vamp-core, Vamp-pulse, Vamp-router, Haproxy and Elasticsearch
EXPOSE 8080 8083 9200 9300

# Run all parts using a single supervisor command
CMD ["/usr/bin/supervisord"]

