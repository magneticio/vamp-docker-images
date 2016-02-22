# Vamp Docker

This repo contains a number of `Dockerfile` files and bash scripts to help setting up Vamp in different situations. 

## Prerequisites

1. [Docker](https://docs.docker.com/)
2. For building: Git, JDK 8, sbt and Go

## Images

- **vamp-clique**: HAProxy, ZooKeeper, Elasticsearch, Logstash, Kibana, Vamp Gateway Agent. Suitable for Vamp development.
- **vamp-clique-marathon**: `vamp-clique` + Mesos (1 master, 1 slave) and Marathon. Suitable for Vamp development.
- **vamp-quick-start**: `vamp-clique` + Vamp. Suitable for trying out Vamp without Marathon (i.e. Docker driver).
- **vamp-quick-start-marathon**: `vamp-clique-marathon` + Vamp. Suitable for trying out Vamp with Marathon.
 
## Building

```
./build.sh

Usage of ./build.sh:

  -h  |--help       Help.
  -l  |--list       List all available and built images.
  -c  |--clean      Remove image(s).
  -m  |--make       Copy Docker file(s) to 'target/docker' directory.
  -b  |--build      Build image(s).
  -v=*|--version=*  Specifying Vamp version, e.g. -v=0.9.0
  -i=*|--image=*    Specifying single image to be processed, e.g. `-i=marathon` otherwise all.
```

**Note:** depending on the Vamp image, the image dependency (Dockerfile `FROM`) won't be built automatically. 

## Running

```
./run.sh

Usage: ./run.sh clique|clique-marathon|quick-start|quick-start-marathon [options] 

  clique               Run HAProxy, ZooKeeper, Elasticsearch, Logstash, Kibana and Vamp Gateway Agent.
  clique-marathon      Run everything from `clique` + Mesos and Marathon.
  quick-start          Vamp without Marathon (i.e. Docker driver).
  quick-start-marathon Vamp with Marathon.
  -h  |--help          Help.
  -v=*|--version=*     Specifying Vamp version, e.g. -v=0.9.0
```

Exposed services depending on the image type:

- HAProxy statistics [http://localhost:1988](http://localhost:1988)
- Elasticsearch HTTP [http://localhost:9200](http://localhost:9200)
- Kibana [http://localhost:5601](http://localhost:5601)
- Sense [http://localhost:5601/app/sense](http://localhost:5601/app/sense)
- Mesos [http://localhost:5050](http://localhost:5050)
- Marathon [http://localhost:9090](http://localhost:9090)
- Consul UI [http://localhost:8500](http://localhost:8500)
- Vamp [http://localhost:8080](http://localhost:8080)

NOTE: If you are using Docker Toolbox (Mac OS X or Windows), you should use docker-machine IP address instead of localhost, for instance to get the IP:
```
docker-machine ip default
```
