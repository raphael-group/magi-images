#!/bin/bash
# This script builds and then starts the MAGI site
# 
# Usage: ./start.sh [port] [image_name] [db_directory]
#
# port: The host machine port for MAGI to listen on
# image_name: The name of the docker image, use an existing container to skip the build step
# db_directory: The database directory to mount the mongo soolution on magi
#
# Defaults:
# port: 80
# container_name: magi
# db_directory: none (don't mount)

### parse the command line as above
MAGI_PORT=80 # the outside port
IMAGE_NAME="raphaelgroup/magi:latest"
MOUNT_DB="" # the directory to mount mongo's db

if [[ $# > 0 ]]
then
	MAGI_PORT=$1	
	shift
fi

if [[ $# > 0 ]] 
then
	IMAGE_NAME=$1
	shift
fi

if [[ $# > 0 ]]
then
	MOUNT_DB = $1
	shift
fi

# names of the containers - export outside for customization
export MONGO_CONTAINER="test-magi-mongo"
export STATS_CONTAINER="test-magi-stats"

# build the magi container 
docker build --force-rm=true --tag="$IMAGE_NAME" .

# start the other services if they aren't already there
bash ./startmongo.sh "" ${MOUNT_DB}
bash ./startstats.sh 
 
# wrap the command within an interactive docker container
dockercmd="docker run -i -t --env-file=local.env "

# connect the host port to port 80
dockercmd+="-p $MAGI_PORT:80 "

# link the mongo and enrichment stats ontainer 
# this adds the ip addresses of the containers into our /etc/hosts
dockercmd+="--link $MONGO_CONTAINER:mongo --link $STATS_CONTAINER:statserver "   

# run the dockerfile
echo "Running [${dockercmd} ${IMAGE_NAME}]"
${dockercmd} ${IMAGE_NAME}
