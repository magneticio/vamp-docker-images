#!/usr/bin/env bash

# Wait for Elasticsearch to be ready before starting Kibana.
while true; do
    sleep 1
    status=$(curl -s --head -w %{http_code} http://${ELASTICSEARCH}:9200 -o /dev/null)
    if [ ${status} -eq 200 ]; then
        break
    fi
done

echo "Starting Kibana"
kibana -c /usr/share/kibana/config/kibana.yml