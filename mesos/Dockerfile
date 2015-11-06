FROM magneticio/vamp-dind:0.8.0

RUN echo "deb http://repos.mesosphere.io/ubuntu/ trusty main" > /etc/apt/sources.list.d/mesosphere.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
RUN apt-get update -qq && apt-get install -qqy supervisor mesos=0.25.0-0.2.70.ubuntu1404

COPY supervisord.conf /etc/supervisor/supervisord.conf

COPY start-slave.sh /start-slave.sh
RUN chmod +x /start-slave.sh
