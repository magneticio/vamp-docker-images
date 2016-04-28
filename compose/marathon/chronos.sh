#!/usr/bin/env bash

# Wait for Mesos master to be ready.
while true; do
  sleep 1
  status=$(curl -s --head -w %{http_code} http://0.0.0.0:5050 -o /dev/null)
  if [ ${status} -eq 200 ]; then
      break
  fi
done

echo "starting Chronos"

chronos run_jar \
        --http_port 4400 \
        --zk_hosts ${ZOOKEEPER}:2181 \
        --master zk://${ZOOKEEPER}:2181/mesos \
        --hostname ${DOCKER_HOST_IP}
