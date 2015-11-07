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
  -l|--list   List all available and built images.
  -c|--clean  Remove all available images.
  -m|--make   Copy all available Docker files to 'target/docker' directory.
  -b|--build  Build all available images.
```

For instance run `./build.sh -b`

## Running Vamp

Vamp with Docker driver: `./run.sh docker`

This will run the following containers:

- vamp-zookeeper, based on [jplock/zookeeper:3.4.6](https://hub.docker.com/r/jplock/zookeeper/)
- vamp-elasticsearch, based on official [elasticsearch](https://hub.docker.com/_/elasticsearch):2.0
- vamp-kibana, based on official [kibana](https://hub.docker.com/_/kibana):4.2
- vamp-logstash, based on official [logstash](https://hub.docker.com/_/logstash):2.0
- [vamp-gateway-agent](https://github.com/magneticio/vamp-gateway-agent)

Exposed services:

- HAProxy (Vamp Gateway Agent) statistics [http://localhost:1988](http://localhost:1988)
- Elasticsearch HTTP [http://localhost:9200](http://localhost:9200)
- Kibana [http://localhost:5601](http://localhost:5601)
- Marvel [http://localhost:5601/app/marvel](http://localhost:5601/app/marvel)
- Sense [http://localhost:5601/app/sense](http://localhost:5601/app/sense)

Vamp with Marathon driver: `./run.sh marathon`

- vamp-zookeeper, based on [jplock/zookeeper:3.4.6](https://hub.docker.com/r/jplock/zookeeper/)
- vamp-mesos-master, vamp-mesos-slave1 and vamp-mesos-slave2
- vamp-marathon
- vamp-elasticsearch, based on official [elasticsearch](https://hub.docker.com/_/elasticsearch):2.0
- vamp-kibana, based on official [kibana](https://hub.docker.com/_/kibana):4.2
- vamp-logstash, based on official [logstash](https://hub.docker.com/_/logstash):2.0
- [vamp-gateway-agent](https://github.com/magneticio/vamp-gateway-agent)

Additional services:

- Mesos [http://localhost:5050](http://localhost:5050), based on version 0.24.1
- Marathon [http://localhost:8080](http://localhost:8080), based on version 0.14.0-SNAPSHOT

NOTE: If you are using Docker Toolbox, you should use docker-machine IP address instead of localhost, e.g.:
```
docker-machine ip default
```
