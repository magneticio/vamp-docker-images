# Starting a private Docker registry with an Nginx proxy

Use these instructions to create a private Docker registry, fronted by an Nginx proxy: all running
from Docker containers. The registry is the [2.0 version](https://docs.docker.com/registry/) which was released in April of 2015 and surpasses the deprecated, python based registry. This registry works well with Docker 1.6.0 clients and up.


## 1. Setup a machine and some storage

Boot up a machine (on GCE or AWS) and a nicely sized disk (say 2TB). Format and mount the disk, i.e. to  `/mnt/docker_images`

## 2. Run the registry

Now start the a `registry:2.0` container with right settings. Notice we mount the `/mnt/docker_images` volume
and then pass it into the `REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY` environment variable.

    $ docker run -d -v /mnt/docker_registry:/mnt/docker_registry -p 5000:5000 --name docker-registry -e REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/mnt/docker_registry registry:2.0


## 3. Run the insecure Nginx proxy

Now start the Nginx proxy.

    $ docker run -d -p 80:80 -e REGISTRY_HOST="docker-registry" -e REGISTRY_PORT="5000" \
    -e SERVER_NAME="localhost" --link docker-registry:docker-registry \
    --name registry-proxy magneticio/registry-proxy-insecure:0.1.0    


## 4. Run the secure Nginx proxy

If you want to lock things up, start an Nginx proxy with SSL and basic authentication enabled. For this to work, you need to have some things in place:

- an SSL certificate and private key. See [the docker docs](https://docs.docker.com/registry/deploying/) for details, or just use:
```
$ openssl req \
  -newkey rsa:2048 -nodes -keyout domain.key \
  -x509 -days 365 -out domain.crt 
```
- A .htpasswd file that contains some credentials. Create it with the following command and replace the username: `$ htpasswd -c .htpasswd <username>`

Now grab all the files and put in some directory, maybe `$HOME`. Then start `magneticio/registry-proxy` container and mount
the correct volumes and set the correct environment variables to link everything together. Thanks to [container solutions](http://container-solutions.com/2015/04/running-secured-docker-registry-2-0/) for helping with this.

    $ docker run -d -p 443:443 -e REGISTRY_HOST="docker-registry" -e REGISTRY_PORT="5000" \
    -e SERVER_NAME="localhost" --link docker-registry:docker-registry \
    -v $(pwd)/.htpasswd:/etc/nginx/.htpasswd:ro -v $(pwd)/certs:/etc/nginx/ssl:ro \
    --name registry-proxy magneticio/registry-proxy:0.1.0


## 4. Prep your local Docker client

Regretfully, we didn't use an SSL certificat signed by a proper CA. This means the Docker client is going to complain. We can
stop this by starting the Docker daemon with the `--insecure-registry <your_registry>` flag. The command below sets up Boot2Docker for this to work for the `registry.magnetic.io` domain. 

    boot2docker ssh "echo $'EXTRA_ARGS=\"--insecure-registry=registry.magnetic.io\"' | sudo tee -a /var/lib/boot2docker/profile && sudo /etc/init.d/docker restart"

## 5. Push & Pull some images

Now authenticate yourself with the registry using the username and password you created with the `htpasswd` command:

    $ docker login -u <user> -p <password> registry.magnetic.io


This should log you in and write a `.dockercfg` file in your `$HOME` directory. This file you can distribute to other hosts also.
For instance to Mesos slaves so they can authenticate and pull down images from your private registry. 

In the end, you should be able to pull an image:

    $ docker pull registry.magnetic.io/dm_tomcat:0.1.34
    0.1.34: Pulling from registry.magnetic.io/dm_tomcat
    3cb35ae859e7: Pull complete 
    ...
    status: Downloaded newer image for registry.magnetic.io/dm_tomcat:0.1.34  
