#!/usr/bin/env bash

export LANG=en_US.UTF-8

APP_CONFIG=/usr/local/vamp/conf/application.conf
LOG_CONFIG=/usr/local/vamp/logback.xml

if [ -e "/usr/local/vamp/conf/logback.xml" ] ; then
    LOG_CONFIG=/usr/local/vamp/conf/logback.xml
fi

java -Dlogback.configurationFile=${LOG_CONFIG} -Dconfig.file=${APP_CONFIG} -jar /usr/local/vamp/vamp.jar
