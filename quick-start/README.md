# Vamp Quick Start

## Running on Mac (katana)

```bash
docker run -v /var/run/docker.sock:/var/run/docker.sock \
           -v /usr/bin/docker:/bin/docker \
           -v "/sys/fs/cgroup:/sys/fs/cgroup" \
           -e "DOCKER_HOST_IP=192.168.65.2" \
           -p 8081:8081 -p 8080:8080 \
           -p 5050:5050 -p 9090:9090 \
           -p 8989:8989 -p 4400:4400 \
           -p 9200:9200 -p 5601:5601 \
           -p 2181:2181 \
           magneticio/vamp-quick-start:katana
```

To persist data between runs:


```bash
docker volume create vamp
docker run -v vamp:/usr/local/vamp/persistence \
           -v /var/run/docker.sock:/var/run/docker.sock \
           -v /usr/bin/docker:/bin/docker \
           -v "/sys/fs/cgroup:/sys/fs/cgroup" \
           -e "DOCKER_HOST_IP=192.168.65.2" \
           -p 8081:8081 -p 8080:8080 \
           -p 5050:5050 -p 9090:9090 \
           -p 8989:8989 -p 4400:4400 \
           -p 9200:9200 -p 5601:5601 \
           -p 2181:2181 \
           magneticio/vamp-quick-start:katana
```

Exposed services depending on the image type:

- Elasticsearch HTTP [http://localhost:9200](http://localhost:9200)
- Kibana [http://localhost:5601](http://localhost:5601)
- Sense [http://localhost:5601/app/sense](http://localhost:5601/app/sense)
- Mesos [http://localhost:5050](http://localhost:5050)
- Marathon [http://localhost:9090](http://localhost:9090)
- Chronos [http://localhost:4400](http://localhost:4400)
- ZooKeeper UI [http://localhost:8989](http://localhost:8989)
- Vamp [http://localhost:8080](http://localhost:8080)
- Vamp Lifter [http://localhost:8081](http://localhost:8081)
