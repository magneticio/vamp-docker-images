#!/usr/bin/env bash

mesos-master --registry=in_memory \
             --cluster=VAMP \
             --quorum=1 \
             --zk=zk://127.0.0.1:2181/mesos \
             --work_dir=/var/lib/mesos \
             --hostname=$DOCKER_HOST_IP \
             --quiet \
             --logging_level=ERROR \
             --log_dir=/var/log/mesos
