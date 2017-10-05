# Docker Compose + Vamp

Containers:

- Vamp + VGA
- Mesos + Marathon
- ZooKeeper + Exhibitor
- Elasticsearch
- MySQL

Exposed:

- [Vamp](http://localhost:8080) 
- [Vamp Lifter](http://localhost:8081) 
- [ZooKeeper Exhibitor](http://localhost:8989/exhibitor/v1/ui/index.html) 
- [Marathon](http://localhost:8090) 
- [Mesos](http://localhost:5050)

## Building Docker images

- `vamp` (dependency)
- `vamp-compose`

This can be done:
- build `magneticio/java:openjdk-8-jre-alpine` and then using `build.sh -b -i=...` from the parent directory build `vamp` and `vamp-compose`, or
- just running `./build.sh` from current directory - it will call parent directory build scripts

## Running

All separate containers: Mesos, Marathon, Elasticsearch etc.: `./run.sh` or `./run.sh docker-compose.yml`

Or in case to have lighter resource usage (e.g. 4GB or less available for Docker machine): `./run.sh clique-docker-compose.yml`. 
Now `clique-zookeeper-marathon` will be used but that means running older versions of Mesos/Marathon/Elasticsearch etc.
Note that `./build.sh` does not build `clique-zookeeper-marathon` or its dependencies.
