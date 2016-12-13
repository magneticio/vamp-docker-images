# Vamp Docker

This repo contains a number of `Dockerfile` files and bash scripts to help setting up Vamp in different situations. 

## Prerequisites

1. [Docker](https://docs.docker.com/)
2. For building: Git, JDK 8, sbt, Leiningen and Go

## Images

- **clique-base**: Elasticsearch, Logstash, Kibana and Vamp Gateway Agent
- **clique-zookeeper**: `clique-base` + ZooKeeper
- **clique-etcd**: `clique-base` + etcd
- **clique-consul**: `clique-base` + Consul
- **clique-zookeeper-marathon**: `clique-zookeeper` + Mesos (1 master, 2 slaves), Marathon and Chronos. Suitable for Vamp development.
- **quick-start**: `clique-zookeeper-marathon` + Vamp. Suitable for trying out Vamp with Marathon.
 
## Building

```bash
./build.sh

Usage of ./build.sh:

  -h  |--help       Help.
  -l  |--list       List all available and built images.
  -c  |--clean      Remove image(s).
  -m  |--make       Copy Docker file(s) to 'target/docker' directory.
  -b  |--build      Build image(s).
  -v=*|--version=*  Specifying Vamp version, e.g. -v=katana
  -i=*|--image=*    Specifying single image to be processed, e.g. `-i=marathon` otherwise all.
```

**Note:** depending on the Vamp image, the image dependency (Dockerfile `FROM`) won't be built automatically. 

#### Example 1: building Vamp Quick Start

```bash
./build.sh -b -i=clique-base
./build.sh -b -i=clique-zookeeper
./build.sh -b -i=clique-zookeeper-marathon
./build.sh -b -i=quick-start
```

#### Example 2: building all tutorial images (DC/OS, Kubernetes and Rancher)

```bash
./build.sh -b -i=vamp
./build.sh -b -i=vamp-*
```

## Running

```bash
./run.sh

Usage: ./run.sh clique-*|quick-start [options]
  clique-etcd                Run etcd, Elasticsearch, Logstash, Kibana and Vamp Gateway Agent.
  clique-consul              Run Consul, Elasticsearch, Logstash, Kibana and Vamp Gateway Agent.
  clique-zookeeper           Run ZooKeeper, Elasticsearch, Logstash, Kibana and Vamp Gateway Agent.
  clique-zookeeper-marathon  Run all from 'clique-zookeeper' and Mesos, Marathon and Chronos.
  quick-start                Vamp quick start with Marathon.
  -h  |--help                Help.
  -v=*|--version=*           Specifying Vamp version, e.g. -v=katana
```

For instance to run Vamp quick start:

```bash
./run.sh quick-start
```

Exposed services depending on the image type:

- Elasticsearch HTTP [http://localhost:9200](http://localhost:9200)
- Kibana [http://localhost:5601](http://localhost:5601)
- Sense [http://localhost:5601/app/sense](http://localhost:5601/app/sense)
- Mesos [http://localhost:5050](http://localhost:5050)
- Marathon [http://localhost:9090](http://localhost:9090)
- Chronos [http://localhost:4400](http://localhost:4400)
- ZooKeeper UI [http://localhost:8989](http://localhost:8989)
- Consul UI [http://localhost:8500](http://localhost:8500)
- Vamp [http://localhost:8080](http://localhost:8080)

NOTE: If you are using Docker Toolbox (Mac OS X or Windows), you should use docker-machine IP address instead of localhost, for instance to get the IP:
```
docker-machine ip default
```
