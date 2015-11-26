#!/usr/bin/env bash

marathon --no-logger \
         --master zk://127.0.0.1:2181/mesos \
         --zk zk://127.0.0.1:2181/marathon \
         --task_launch_timeout 300000 \
         --http_port 9090