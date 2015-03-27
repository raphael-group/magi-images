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
CONTAINER_NAME="magi"
MOUNT_DB = "" # the directory to mount mongo's db

if [[ $# > 0 ]]
	MAGI_PORT=$1	
	shift

if [[ $# > 0 ]] 
	CONTAINER_NAME=$1
	shift

if [[ $# > 0 ]]
	MOUNT_DB = $1
	shift

# build the magi container 
docker build --force-rm=true --tag="$CONTAINER_NAME" .

# start the other services if they aren't already there
existing_mongo=$(docker ps -q -f "name=mongo")
if [[ -z existing_mongo ]]  
	# run mongo with a directory to mount from outside, if available
	docker run -d -v "$MOUNT_DB":/data/db --name mongo mongo

existing_enricher=$(docker ps -q -f "name=magi-stats")
if [[ -z existing_enricher ]]
	docker run -d --name enricher magi-stats
 
# the link takes the imports from ~/magi/STAD
# establish the environment for the server to work within
env = "MONGO_HOST=mongo ENRICHMENT_HOST=magi-stats ENRICHMENT_PORT=13370"

# inside the container, start nginx and then run a shell 
cmd = " sudo /etc/init.d/nginx start && bash"

# wrap the command within an interactive docker container
dockercmd = "docker run -i -t --env ${env}"

# connect the host port to port 80
dockercmd += "-p $MAGI_PORT:80"

# link the mongo and enrichment stats ontainer 
# this adds the ip addresses of the containers into our /etc/hosts
dockercmd += "--link mongo:mongo --link $CONTAINER_NAME" 

# run the dockerfile
"$dockercmd" "$cmd"
