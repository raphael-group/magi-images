#!/bin/bash
# Note: this function is meant to run WITHIN the docker container

function error {
  echo $1 && exit 0 
}

 nc -zw2 mongo 27017 || error "Mongo database not available, exiting..."
 nc -zw2 statserver $ENRICHMENT_PORT || error "Statistics server not available, exiting..."
 
# prepare /etc/nginx/conf.d/magi-site.conf
TRIM_NAME=${SITE_URL%:*} # trim port name
TRIM_NAME=${TRIM_NAME#*://} # trim protocol name

# bash hackery
sed -i -e "s%\$SERVER_NAME_TO_REPLACE%${TRIM_NAME}%;s/\$PORT_TO_REPLACE/${PORT}/" /etc/nginx/conf.d/magi-site.conf

sudo /etc/init.d/nginx start 
echo "Starting server with forever" 

LOGFILE="server.log"
forever start -c "node --harmony" -l $LOGFILE ~/magi/server.js 
echo "Writing server output to ~/.forever/$LOGFILE"
bash
