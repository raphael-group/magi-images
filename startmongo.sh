#!/bin/bash
# This script builds and then starts a mongo container. 
# 
# Usage: ./startmongo.sh [container_name] [db_directory]
#
# container_name: The name of the mongo container
# db_directory: The database directory to mount the mongo soolution on magi
#
# Defaults:
# container_name: $MONGO_CONTAINER, then "test-mongo" 
# db_directory: none (don't mount)

### parse the command line as above

if [[ $# > 0 ]]; then
	CONTAINER_NAME=$1	
fi
if [[ -z ${CONTAINER_NAME} ]]; then 
	CONTAINER_NAME=$MONGO_CONTAINER
fi
if [[ -z ${CONTAINER_NAME} ]]; then
	CONTAINER_NAME="test-mongo"
fi

MOUNT_DB="" # the directory to mount mongo's db
if [[ $# > 1 ]]; then
	MOUNT_DB=$2
fi

# start the other services if they aren't already there
exited_mongo=$(docker ps -aq -f "name=$CONTAINER_NAME" -f "status=exited")
if [[ -n ${exited_mongo} ]] # container is exited
then
	echo "Restarting mongo container $CONTAINER_NAME"
	docker rm ${CONTAINER_NAME}
	docker run -d ${linkarg} --name ${CONTAINER_NAME} mongo
fi

existing_mongo=$(docker ps -aq -f "name=$CONTAINER_NAME")
if [[ -z ${existing_mongo} ]]  
then
	# run mongo with a directory to mount from outside, if available
	echo "Starting a mongo container $CONTAINER_NAME"

	linkArg=""
	if [[ -n ${MOUNT_DB} ]]
	then
		linkArg="-v ${MOUNT_DB}:/data/db"
	fi
	docker run -d ${linkarg} --name ${CONTAINER_NAME} mongo
else
	# we assume that if the container is up it's the right container
	echo "Mongo container $CONTAINER_NAME already up"
fi

