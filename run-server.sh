#!/bin/bash

function error {
  echo $1 && exit 0 
}

nc -zw2 mongo 27017 || error "Mongo database not available, exiting..."
nc -zw2 statserver $ENRICHMENT_PORT || error "Statistics server not available, exiting..."

sudo /etc/init.d/nginx start 
echo "Starting server with forever" 

LOGFILE="cobra-server.log"
forever start -c "node --harmony" -l $LOGFILE ~/magi/server.js 
echo "Writing server output to ~/.forever/$LOGFILE"
bash
