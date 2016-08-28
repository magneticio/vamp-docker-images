#!/usr/bin/env bash

# Wait for Mesos master to be ready.
while true; do
  sleep 1
  status=$(curl -s --head -w %{http_code} http://0.0.0.0:5050 -o /dev/null)
  if [ ${status} -eq 200 ]; then
      break
  fi
done

marathon --no-logger \
         --logging_level error \
         --master zk://127.0.0.1:2181/mesos \
         --zk zk://127.0.0.1:2181/marathon \
         --task_launch_timeout 300000 \
         --http_port 9090 \
         --hostname ${DOCKER_HOST_IP}