FROM jpetazzo/dind
MAINTAINER tim@magnetic.io

# This Dockerfile packages mesos in a Docker-in-Docker container. It is based on the breerly/mesos image.

RUN echo "deb http://repos.mesosphere.io/ubuntu/ trusty main" > /etc/apt/sources.list.d/mesosphere.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF

RUN apt-get -y update

RUN apt-get -y install mesos=0.22.0-1.0.ubuntu1404

RUN apt-get -y install supervisor
COPY supervisord.conf /etc/supervisor/supervisord.conf

COPY start-slave.sh /start-slave.sh
RUN chmod +x /start-slave.sh