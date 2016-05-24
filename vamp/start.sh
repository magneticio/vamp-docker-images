#!/usr/bin/env bash

java -Dvamp.gateway-driver.host=$(hostname) \
     -Dlogback.configurationFile=/usr/local/vamp/conf/logback.xml \
     -Dconfig.file=/usr/local/vamp/conf/application.conf \
     -jar /usr/local/vamp/vamp.jar
