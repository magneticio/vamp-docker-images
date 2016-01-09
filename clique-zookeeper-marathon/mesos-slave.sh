#!/usr/bin/env bash

# Wait for Mesos master to be ready.
while true; do
  sleep 1
  status=$(curl -s --head -w %{http_code} http://0.0.0.0:5050 -o /dev/null)
  if [ ${status} -eq 200 ]; then
      break
  fi
done

echo "starting Mesos slave: $1"

mkdir -p /var/run/mesos/slave$1 2> /dev/null
mkdir -p /var/log/mesos/slave$1 2> /dev/null

mesos-slave --containerizers="docker,mesos" \
            --executor_registration_timeout=5mins \
            --docker_stop_timeout=10secs \
            --isolation="cgroups/cpu,cgroups/mem" \
            --master=zk://127.0.0.1:2181/mesos \
            --work_dir=/var/run/mesos/slave$1 \
            --log_dir=/var/log/mesos/slave$1 \
            --port=505$1
