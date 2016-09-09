#!/usr/bin/env bash

zookeeper start

cd /usr/local/zookeeper/
java -jar zk-web.jar
