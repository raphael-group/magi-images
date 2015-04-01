#!/bin/bash
# This script starts the magi statistics server container (raphaelgroup/magi:stat-server)
# 
# Usage: ./startstats.sh [container_name]
#
# container_name: The name of the statisticscontainer
#
# Defaults:
# container_name: $STATS_CONTAINER, then test-stats 

### parse the command line as above
if [[ $# > 0 ]]; then
	CONTAINER_NAME=$1	
fi
if [[ -z ${CONTAINER_NAME} ]]; then
	CONTAINER_NAME=$STATS_CONTAINER
fi
if [[ -z ${CONTAINER_NAME} ]]; then
	CONTAINER_NAME="test-stats"
fi

# start the other services if they aren't already there
exited_stats=$(docker ps -aq -f "name=$CONTAINER_NAME" -f "status=exited")
if ! [[ -z ${exited_stats} ]]; then 
	# container is exited
	# run mongo with a directory to mount from outside, if available
	echo "Stopping current container $CONTAINER_NAME"
	docker rm ${CONTAINER_NAME}
fi

existing_stats=$(docker ps -aq -f "name=$CONTAINER_NAME")
if [[ -z ${existing_stats} ]]; then
	echo "Starting a statisics server container $CONTAINER_NAME"
	docker run -d --name ${CONTAINER_NAME} raphaelgroup/magi:stat-server
else
	# we assume that if the container is up it's the right container
	echo "Statistics container $CONTAINER_NAME already up"
fi

