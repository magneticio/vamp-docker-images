#!/usr/bin/env bash

# Wait for Mesos master to be ready.
while true; do
    sleep 1
    status=$(curl -s --head -w %{http_code} http://0.0.0.0:5050 -o /dev/null)
    if [ ${status} -eq 200 ]; then
        break
    fi
done

mesos-slave --containerizers="docker,mesos" \
            --executor_registration_timeout=5mins \
            --docker_stop_timeout=10secs \
            --isolation="cgroups/cpu,cgroups/mem" \
            --master=zk://localhost:2181/mesos \
            --work_dir=/var/run/mesos \
            --hostname=$DOCKER_HOST_IP \
            --log_dir=/var/log/mesos
