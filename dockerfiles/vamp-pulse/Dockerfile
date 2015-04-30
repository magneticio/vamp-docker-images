FROM dockerfile/java:oracle-java8

MAINTAINER matthijs@magnetic.io

# This Dockerfile packages Vamp-pulse. The resulting container can be used for basic testing
# kicking the tires. It is not meant for production or any other serious work.
# For more info, see the accompanying README.md

# Install Supervisor

RUN apt-get update && \
    apt-get install -y supervisor


# Get Vamp-Pulse
RUN wget https://bintray.com/artifact/download/magnetic-io/downloads/vamp-pulse/pulse-assembly-0.7.5.jar


COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf


# expose the Vamp-pulse and Elasticsearch
EXPOSE 8083 9300

# Run all parts using a single supervisor command
CMD ["/usr/bin/supervisord"]

