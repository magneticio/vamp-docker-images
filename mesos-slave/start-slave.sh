#!/usr/bin/env bash

supervisord -n -c /etc/supervisor/supervisord.conf &

sleep 6
exec mesos-slave "$@"