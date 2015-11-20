#!/usr/bin/env bash

marathon --no-logger \
         --master zk://localhost:2181/mesos \
         --zk zk://localhost:2181/marathon \
         --task_launch_timeout 300000 \
         --http_port 9090