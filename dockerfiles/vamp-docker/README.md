# Vamp with Docker driver

This container runs all of Vamp's components in one container and uses Docker as its container driver. This effectively means you'll be talking to the Docker daemon from a Docker container: it's Dockerception! To make this work you have to pass in some Docker environment variables to the container and run in it in "host" network mode.

A typical command on Macbook running Boot2Docker would be:


```
docker run --net=host -v /Users/tim/.boot2docker/certs/boot2docker-vm:/certs -e "DOCKER_TLS_VERIFY=1" -e "DOCKER_HOST=tcp://`boot2docker ip`:2376" -e "DOCKER_CERT_PATH=/certs" magneticio/vamp-with-docker:experimental
```

**Please notice** the mounting (`-v /Users/tim/...`) of the boot2docker certificates. Please set this to your specific environment.

If you don't use Boot2Docker, set the `DOCKER_HOST` variable to whatever is relevant to your system.