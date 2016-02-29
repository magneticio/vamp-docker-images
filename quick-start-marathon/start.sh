#!/usr/bin/env bash

# Wait for Kibana before starting Vamp.
while true; do
    sleep 1
    status=$(curl -s --head -w %{http_code} http://0.0.0.0:9200/.kibana -o /dev/null)
    if [ ${status} -eq 200 ]; then
        break
    fi
done

export LANG=en_US.UTF-8

java -Dvamp.gateway-driver.host=${DOCKER_HOST_IP} -Dlogback.configurationFile=/usr/local/vamp/logback.xml -Dconfig.file=/usr/local/vamp/application.conf -jar /usr/local/vamp/vamp.jar
