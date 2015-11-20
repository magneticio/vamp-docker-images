#!/usr/bin/env bash

mesos-master --registry=in_memory \
             --cluster=VAMP \
             --quorum=1 \
             --zk=zk://localhost:2181/mesos \
             --work_dir=/var/lib/mesos \
             --hostname=$DOCKER_HOST_IP \
             --log_dir=/var/log/mesos
