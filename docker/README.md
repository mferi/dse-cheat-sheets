# All docker stuff

### Basic Docker Commands:
`docker ps  --> Show current running containers`
`docker ps -a`  --> Show all containers including stopped in the past
`docker inspect <container_name or container_id>`
`docker stop <container_name or container_id>`  --> stop the docker container but not remove it
`docker rm <container_name or container_id>`  --> remove the docker container but not the image
`docker images` --> list existing images on disk
`docker rmi` <container_name or container_id>  --> delete the image; it requires to stop and delete all dependent containers

`docker pull <image_name>` This run command download an image if it doesn't exist

`docker run <image_name>` --> try to find the image locally and download it if not find it and initialise a container and exit immediately as no command provided
`docker run <image_name> <command>` --> pull the image if it's not locally and initialise a new container and run a command on the foreground
`docker run -d <image_name> <command>`  --> run a container in detached mode or background
`docker run -i <image_name> <command>`  --> -i allow to listen standard input (eg keyboard) from the host to the container
`docker run -it <image_name> <command>`  --> run a container iteratively; attach input and terminal
`docker exec <container_name or container_id> <command>`  --> run a command on a given running container

##### Every container is assigned a private IP address
-p 8080:8080 mapping host port to container port

##### Volume mapping
-v <host_directory> <container_directory>  --> mount the container directory out on the host

##### Creating a docker image (given a Dockerfile)
`docker build . -t <docker_user_or_account/image_name>`

##### Load a image on docker hub
`docker login`
`docker push <docker_user_or_account/image_name>`


### Docker setup

Add yourself to the docker group (creating it if required) to avoid having to use sudo to run docker commands.

###### You'll have to log off your devbox then back in, as this usermod change doesn't seem to affect any existing connection.
`sudo usermod -a -G docker $USER`

Make sure you’re running at least version 1.11.2 of docker, and upgrade if necessary.
`docker --version`

##### Stop any old running docker daemon.
`sudo su - root`

root> `service docker stop`

root> `pkill -9 docker`

##### Remove old docker cache - this removes cached images.
Skipping this step can lead to crashing issues with docker,
as the cache files layout can change between versions.

root> `rm -rf /var/lib/docker`

##### Install docker from most recent Amazon Linux AMI.

root> `yum --releasever=2016.09 install docker`

root> `service docker start`

root> `exit`

`docker --version`

##### Make sure you're running at least version 1.9.0 of docker-compose, otherwise upgrade it.
Check https://github.com/docker/compose/releases for latest version
 and check against installed version.
`docker-compose --version`

##### To upgrade, check for the latest instructions from https://github.com/docker/compose/releases
This is currently equivilent to:
``curl -L https://github.com/docker/compose/releases/download/1.9.0/docker-compose-`uname -s`-`uname -m` > docker-compose``

`chmod +x docker-compose`

`sudo mv docker-compose /usr/local/bin/docker-compose`


Make sure you have the following setting in /etc/sysconfig/docker:
OPTIONS="--default-ulimit nofile=10240:256000 --insecure-registry docker.endpoint --log-level warning"

