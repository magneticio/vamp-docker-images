# Vamp Docker

This repo contains a number of `Dockerfile` files and bash scripts to help setting up Vamp in different situations. 

## Prerequisites

1. [Docker](https://docs.docker.com/)
2. [Docker Compose](https://docs.docker.com/compose/)
3. Git, JDK 8, sbt, Go

## Distinctive Images

- vamp-clique - HAProxy, ZooKeeper, Elasticsearch, Logstash, Kibana, Vamp Gateway Agent. Suitable for Vamp development (alternative to `./run.sh docker`).
- vamp-quick-start - vamp-clique + Vamp. Suitable for trying out Vamp.
 
## Building Vamp Docker Images Locally

```
./build.sh

Usage of ./build.sh:
  -h  |--help       Help.
  -l  |--list       List all available and built images.
  -c  |--clean      Remove all available images.
  -m  |--make       Copy all available Docker files to 'target/docker' directory.
  -b  |--build      Build all available images.
  -v=*|--version=*  Specifying Vamp version, e.g. -v=0.8.0
  -i=*|--image=*    Specifying single image to be processed, e.g. -i=marathon
```

## Running Vamp

```
./run.sh

Usage: ./run.sh docker|marathon [options] 
  docker            Running Vamp using Docker driver.
  marathon          Running Vamp using Marathon driver..
  -h  |--help       Help.
  -v=*|--version=*  Specifying Vamp version, e.g. -v=0.8.0

```

Vamp with Docker driver: `./run.sh docker`

This will run the following containers:

- vamp-zookeeper, version 3.4.6
- vamp-elasticsearch, based on official [elasticsearch](https://hub.docker.com/_/elasticsearch):2.0
- vamp-kibana, based on official [kibana](https://hub.docker.com/_/kibana):4.2
- vamp-logstash, based on official [logstash](https://hub.docker.com/_/logstash):2.0
- [vamp-gateway-agent](https://github.com/magneticio/vamp-gateway-agent)

Exposed services:

- HAProxy (Vamp Gateway Agent) statistics [http://localhost:1988](http://localhost:1988)
- Elasticsearch HTTP [http://localhost:9200](http://localhost:9200)
- Kibana [http://localhost:5601](http://localhost:5601)
- Sense [http://localhost:5601/app/sense](http://localhost:5601/app/sense)

Vamp with Marathon driver: `./run.sh marathon`, additional containers:

- vamp-mesos-master and vamp-mesos-slave, Apache Mesos 0.25.0
- vamp-marathon, Marathon 0.13.0

Additional services:

- Mesos [http://localhost:5050](http://localhost:5050)
- Marathon [http://localhost:8080](http://localhost:8080)

NOTE: If you are using Docker Toolbox, you should use docker-machine IP address instead of localhost, for instance to get the IP:
```
docker-machine ip default
```
