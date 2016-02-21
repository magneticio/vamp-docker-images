#!/usr/bin/env bash

marathon --no-logger \
         --master zk://${DOCKER_HOST_IP}:2181/mesos \
         --zk zk://${DOCKER_HOST_IP}:2181/marathon \
         --task_launch_timeout 300000 \
         --http_port 9090 \
         --hostname ${DOCKER_HOST_IP}