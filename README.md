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

- vamp-elasticsearch, based on official [elasticsearch](https://hub.docker.com/_/elasticsearch):2.0
- vamp-kibana, based on official [kibana](https://hub.docker.com/_/kibana):4.2
- vamp-logstash, based on official [logstash](https://hub.docker.com/_/logstash):2.0
- vamp-zookeeper, based on [jplock/zookeeper:3.4.6](https://hub.docker.com/r/jplock/zookeeper/)
- [vamp-gateway-agent](https://github.com/magneticio/vamp-gateway-agent)

## Run Vamp with Marathon driver

TODO

## Exposed Services

- HAProxy (Vamp Gateway Agent) statistics [http://localhost:1988](http://localhost:1988)
- Elasticsearch HTTP [http://localhost:9200](http://localhost:9200)
- Kibana UI [http://localhost:5601](http://localhost:5601)
- Marvel [http://localhost:5601/app/marvel](http://localhost:5601/app/marvel)
- Sense [http://localhost:5601/app/sense](http://localhost:5601/app/sense)

If you are using Docker Toolbox, you should use docker-machine IP address instead of localhost, e.g.:
```
docker-machine ip default
```
