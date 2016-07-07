#!/usr/bin/env bash

export LANG=en_US.UTF-8

# Wait for Elasticsearch before starting Vamp.
while true; do
    sleep 1
    status=$(curl -s --head -w %{http_code} http://elasticsearch-executor.elasticsearch.mesos:9200 -o /dev/null)
    if [ ${status} -eq 200 ]; then
        break
    fi
done

LOG_CONFIG=/usr/local/vamp/logback.xml
APP_CONFIG=/usr/local/vamp/conf/application.conf

if [ -e "/usr/local/vamp/conf/logback.xml" ] ; then
    LOG_CONFIG=/usr/local/vamp/conf/logback.xml
fi

java -Dlogback.configurationFile=${LOG_CONFIG} -Dconfig.file=${APP_CONFIG} -jar /usr/local/vamp/vamp.jar
