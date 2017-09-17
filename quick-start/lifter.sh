#!/usr/bin/env bash

# Wait for Elasticsearch before starting Vamp.
while true; do
    sleep 3
    status=$(curl -s -w %{http_code} http://0.0.0.0:9200/.kibana -o /dev/null)
    if [ ${status} -eq 200 ]; then
        break
    else
        echo "********* Waiting for ElasticSearch to be ready before starting Vamp Lifter... *********"
    fi
done

export LANG=en_US.UTF-8

APP_CONFIG=/usr/local/vamp/lifter/application.conf
LOG_CONFIG=/usr/local/vamp/logback.xml

java -Dvamp.gateway-driver.host=${DOCKER_HOST_IP} \
     -Dlogback.configurationFile=${LOG_CONFIG} \
     -Dconfig.file=${APP_CONFIG} \
     -cp "/usr/local/vamp/lifter/*:/usr/local/vamp/lifter/lib/*" \
     io.vamp.lifter.Lifter -initialize
