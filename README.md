# Vamp-docker

This repo contains a number of `Dockerfile` files and `docker-compose.yml` to help setup Vamp in 
different situations. They should run anywhere Docker runs, but most situations will probably be on your laptop. 
Probably a recent Macbook.

## Prerequisites

1. You should have Docker installed which, on a Macbook with OSX, means [Boot2Docker](http://boot2docker.io/) and its dependencies.
2. For Docker compositions, you should have [Docker compose](https://docs.docker.com/compose/install/) installed. Luckily,
that's a two-liner:

        curl -L https://github.com/docker/compose/releases/download/1.1.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
3. Some patience, as some of the container are somewhat big due to Java dependencies.
4. You are most probably on Github. You should have git.

## Run it

If you have the prerequisites sorted, pick the thing you want to do...

### Option 1: Run Vamp on Docker

This setup will run Vamp inside a Docker container with Vamp's Docker driver. This allows you to test drive Vamp really easily.

A typical command on Macbook running Boot2Docker would be:

```
docker run --net=host -v ~/.boot2docker/certs/boot2docker-vm:/certs -e "DOCKER_TLS_VERIFY=1" -e "DOCKER_HOST=tcp://`boot2docker ip`:2376" -e "DOCKER_CERT_PATH=/certs" magneticio/vamp-docker:latest
```

**Please notice** the mounting of the boot2docker certificates. Please set this to your specific environment. You can get this info by running `boot2docker config`.

If you don't use Boot2Docker, set the `DOCKER_HOST` variable to whatever is relevant to your system.

## Option 2: Run Vamp with a Mesos and Marathon cluster

    git clone https://github.com/magneticio/vamp-docker.git && cd vamp-docker/docker-compositions/vamp-marathon-mesos/ && docker-compose up    
*Note 1: grab a coffee while everything gets installed on the first run.*
*Note 2: This runs all of Vamp's components in one container. This is not ideal, but works fine for testing stuff out.*


## Option 3: Build the all-in-one Vamp container, run it with an external Mesos/Marathon

    git clone https://github.com/magneticio/vamp-docker.git && docker build -t my_vamp_image vamp-docker/dockerfiles/vamp-mesosphere/    

With this image, you should provide the Marathon endpoint on startup by setting the `VAMP_MARATHON_URL` enviroment variable, like this:

    docker run -i -t -p 81:80 -p 8081:8080 -p 10002:10001 -p 8084:8083 -e VAMP_MARATHON_URL=http://10.143.22.49:8080 my_vamp_image