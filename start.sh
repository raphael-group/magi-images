#!/bin/bash
# This script builds and then starts the MAGI site
# 
# Usage: ./ start.sh [port] [container_name] [db_directory]
#
# port: The host machine port for MAGI to listen on
# container_name: The name of the docker container, use an existing container to skip the build step
# db_directory: The database directory to mount the mongo soolution on magi
#
# Defaults:
# port: 80
# container_name: magi
# db_directory: none (don't mount)

### parse the command line as above
MAGI_PORT=80 # the outside port
IMAGE_NAME="magi:latest"
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

# names of the containers
MONGO_CONTAINER_NAME="test-magi-mongo"
STAT_CONTAINER_NAME="test-magi-stats"

# build the magi container 
docker build --force-rm=true --tag="$IMAGE_NAME" .

# start the other services if they aren't already there
existing_mongo=$(docker ps -q -f "name=$MONGO_CONTAINER_NAME")
echo "[${existing_mongo}]"
if [[ -z ${existing_mongo} ]]  
then
	# run mongo with a directory to mount from outside, if available
	echo "Starting a mongo container $MONGO_CONTAINER_NAME"

	linkArg=""
	if [[ -n ${MOUNT_DB} ]]
	then
		linkArg="-v ${MOUNT_DB}:/data/db"
	fi
	docker run -d ${linkarg} --name $MONGO_CONTAINER_NAME mongo
else
	echo "Mongo container $MONGO_CONTAINER_NAME already up"
fi

# todo: automatically clean up stopped containers
existing_enricher=$(docker ps -q -f "name=$STAT_CONTAINER_NAME")
if [[ -z ${existing_enricher} ]]
then
	echo "Starting a statistics server container $STAT_CONTAINER_NAME" 
	docker run -d --name $STAT_CONTAINER_NAME raphaelgroup/magi:stat-server
else
	echo "Statistics server container $STAT_CONTAINER_NAME already up"
fi
 
# wrap the command within an interactive docker container
dockercmd="docker run -i -t --env-file=local.env "

# connect the host port to port 80
dockercmd+="-p $MAGI_PORT:80 "

# link the mongo and enrichment stats ontainer 
# this adds the ip addresses of the containers into our /etc/hosts
dockercmd+="--link $MONGO_CONTAINER_NAME:mongo --link $STAT_CONTAINER_NAME:statserver "   

# run the dockerfile
echo "Running [${dockercmd} ${IMAGE_NAME}]"
${dockercmd} ${IMAGE_NAME}
