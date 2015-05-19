# Vamp All-In-One with Docker driver

This container runs all of Vamp's components in one container and uses Docker as its container driver.
This effectively means you'll be talking to Docker from a Docker container. To make this work you have to
pass in some Docker environment variables to the container and run in it in "host" network mode.

A typical command would be:


```
docker run --net=host -v /Users/tim/.boot2docker/certs/boot2docker-vm:/certs -e "DOCKER_TLS_VERIFY=1" -e "DOCKER_HOST=tcp://192.168.59.103:2376" -e "DOCKER_CERT_PATH=/certs" -t -i magneticio/vamp-with-docker:experimental
```

Please notice the mounting (`-v /Users/tim/...`) of the boot2docker certificates. Please set this to your specific environment