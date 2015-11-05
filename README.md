# Vamp Docker

This repo contains a number of `Dockerfile` files and bash scripts to help setting up Vamp in different situations. 

## Prerequisites

1. [Docker](https://docs.docker.com/) installed.
2. [Docker Compose](https://docs.docker.com/compose/) installed.

## Building Vamp Docker Images Locally

```
./build.sh

Usage of ./build.sh:
  -h|--help   Help.
  -l|--list   List all available images.
  -c|--clean  Remove all available images.
  -m|--make   Copy all available Docker files to 'target/docker' directory.
  -b|--build  Build all available images.
```

For instance run `./build.sh -b`

## Run Vamp with Docker driver

`./run-vamp-docker-driver.sh`

This will run the following containers:

- vamp-elasticsearch, based on official elasticsearch:2.0
- vamp-kibana, based on official kibana:4.2
- vamp-logstash, based on official logstash:2.0
- vamp-zookeeper, based on jplock/zookeeper:3.4.6
- vamp-gateway-agent

## Run Vamp with Marathon driver

TODO