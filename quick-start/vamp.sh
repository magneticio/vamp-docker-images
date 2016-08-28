#!/usr/bin/env bash

# Wait for Elasticsearch before starting Vamp.
while true; do
    sleep 3
    status=$(curl -s -w %{http_code} http://0.0.0.0:9200/.kibana -o /dev/null)
    if [ ${status} -eq 200 ]; then
        break
    else
        echo "********* Waiting for ElasticSearch to be ready before starting Vamp... *********"
    fi
done

export LANG=en_US.UTF-8

APP_CONFIG=/usr/local/vamp/application.conf
LOG_CONFIG=/usr/local/vamp/logback.xml

if [ -e "/usr/local/vamp/conf/application.conf" ] ; then
    APP_CONFIG=/usr/local/vamp/external.conf
fi

if [ -e "/usr/local/vamp/conf/logback.xml" ] ; then
    LOG_CONFIG=/usr/local/vamp/conf/logback.xml
fi

java -Dvamp.gateway-driver.host=${DOCKER_HOST_IP} -Dlogback.configurationFile=${LOG_CONFIG} -Dconfig.file=${APP_CONFIG} -jar /usr/local/vamp/vamp.jar
