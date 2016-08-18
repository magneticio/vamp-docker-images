#!/usr/bin/env sh

export LANG=en_US.UTF-8

# Wait for dependency before starting Vamp.
while true; do
  sleep 5
  status=$(curl -s -w %{http_code} ${VAMP_WAIT_FOR} -o /dev/null)
  if [ ${status} -eq 200 ]; then
    break
  else
    echo "waiting for ${VAMP_WAIT_FOR}"
  fi
done

LOG_CONFIG=/usr/local/vamp/logback.xml
APP_CONFIG=/usr/local/vamp/conf/application.conf

if [ -e "/usr/local/vamp/conf/logback.xml" ] ; then
    LOG_CONFIG=/usr/local/vamp/conf/logback.xml
fi

java -Dlogback.configurationFile=${LOG_CONFIG} -Dconfig.file=${APP_CONFIG} -jar /usr/local/vamp/vamp.jar
