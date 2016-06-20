# Base Vamp Docker Image

In order to run this image it is mandatory an additional configuration to be provided.
This can be done in few way:
- providing `application.conf` file and/or
- setting environment variables

Let's say `application.conf` is stored in `/MY/APP/CONF/PATH` directory (absolute path), then:
```
docker run -v /MY/APP/CONF/PATH:/usr/local/vamp/conf magneticio/vamp:0.9.0
```

Required minimal configuration is:
```yaml
vamp {

  persistence {

    database.elasticsearch.url = *** # e.g. "http://elasticsearch:9200"

    key-value-store {
      type = *** # zookeeper, etcd or consul
      # one of the following 3 parameters depending on type:
      zookeeper.servers = *** # e.g. "127.0.0.1:2181"
      etcd.url = *** # e.g. "http://etcd-client:2379"
      consule.url = *** # e.g. "http://consul:8500"
    }
  }

  container-driver {

    type = *** # marathon, kubernetes or rancher

    # one of the following 4 sections depending on type:
    mesos { *** }
    marathon { *** }
    kubernetes { *** }
    rancher { *** }
  }

  gateway-driver {
    logstash.host = "logstash"
    kibana.elasticsearch.url = *** # e.g. "http://elasticsearch:9200"
  }

  workflow-driver {
    type = *** # marathon, chronos, kubernetes, rancher or none.
               # multiple values are possible (csv) refer to docs.
    vamp-url = *** # e.g. "http://vamp:8080"
  }

  pulse.elasticsearch.url = *** # e.g. "http://elasticsearch:9200"

  operation {

    deployment.arguments: [ # default docker run arguments
      "privileged=true"     # depends on Docker version and securty model
    ]
  }
}

```

Good examples can be found in `../vamp-kubernetes` and `../vamp-rancher` directories.
These images are configured for use in our Vamp quick start tutorials.

A part of using `application.conf` file it is also possible to use environment variables.
Each configuration parameter can be overriden by an environment variable.
Name of the variable is based on configuration parameter name: uppercase and all non alphanumerics are replaced with underscores.
For instance:
```
vamp.container-driver.type ⇒ VAMP_CONTAINER_DRIVER_TYPE
```
An example can be found also in `Dockerfile`:
```bash
ENV VAMP_REST_API_UI_DIRECTORY /usr/local/vamp/ui
ENV VAMP_REST_API_UI_INDEX     /usr/local/vamp/ui/index.html
```