FROM ubuntu

MAINTAINER tim@magnetic.io

# This Dockerfile packages all Vamp components in one container. The resulting container can be used for basic testing
# kicking the tires. It is not meant for production or any other serious work.
# For more info, see the accompanying README.md and mesos_bootstrap.sh script

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

RUN sudo add-apt-repository -y ppa:vbernat/haproxy-1.5 && \
    sudo apt-get update && \
    sudo apt-get install -y haproxy supervisor
# More dynamic stuff
#

# Add bintray key
RUN curl https://bintray.com/user/downloadSubjectPublicKey?username=bintray | apt-key add -

RUN echo "deb https://dl.bintray.com/magnetic-io/upstart trusty main" >> /etc/apt/sources.list && \
    apt-get update

# Get Vamp-Core
RUN apt-get install -y vamp-core

# Get Vamp-Pulse
RUN apt-get install -y vamp-pulse

# Get Vamp-Router
RUN apt-get install -y vamp-router

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# expose the Vamp-core, Vamp-pulse, Vamp-router, Haproxy and Elasticsearch
# expose lower part of Vamp dynamic port range for initial test
EXPOSE 8080 8083 10001 1980 9300

EXPOSE 9050 9051 9052 9053 9054 9055 33000 33001 33003 33004 33005

# Run all parts using a single supervisor command
CMD ["/usr/bin/supervisord"]

