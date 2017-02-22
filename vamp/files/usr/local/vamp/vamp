#!/usr/bin/env sh

export LANG=en_US.UTF-8

LOG_CONFIG=/usr/local/vamp/logback.xml
APP_CONFIG=/usr/local/vamp/conf/application.conf

if [ -e "/usr/local/vamp/conf/logback.xml" ] ; then
    LOG_CONFIG=/usr/local/vamp/conf/logback.xml
fi

if [ -e "${APP_CONFIG}" ] ; then
    java -Dlogback.configurationFile=${LOG_CONFIG} \
         -Dconfig.file=${APP_CONFIG} \
         -cp "/usr/local/vamp/bin/*:/usr/local/vamp/bin/lib/*" \
         io.vamp.bootstrap.Boot
else
    java -Dlogback.configurationFile=${LOG_CONFIG} \
         -cp "/usr/local/vamp/bin/*:/usr/local/vamp/bin/lib/*" \
         io.vamp.bootstrap.Boot
fi
