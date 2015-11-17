#!/usr/bin/env bash

# Wait for the Elasticsearch container to be ready before starting Kibana.
echo "Stalling for Elasticsearch"
while true; do
    sleep 1
    status=$(curl -s --head -w %{http_code} http://0.0.0.0:9200 -o /dev/null)
    if [ ${status} -eq 200 ]; then
        break
    fi
done

echo "Starting Kibana"
gosu kibana kibana