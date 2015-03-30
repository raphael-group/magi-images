# MAGI
![Magi logo](http://magi.cs.brown.edu/img/magiTitle.svg)

**MAGI** is a platform for interactive visualization and collaborative annotation of combinations of genetic aberrations. MAGI allows users to upload their own private datasets and view and annotate them in combination with public datasets.

This Docker image automatically installs the prerequisites for MAGI within its own container.  It is written in [Node.js](http://nodejs.org/) with a [MongoDB](http://docs.mongodb.org/manual/tutorial/install-mongodb-on-os-x/) database. MAGI uses [D3](http://d3js.org/), [jQuery](http://jquery.com/), and [GD3](https://github.com/raphael-group/gd3) on the front-end. Below, we describe how to get a version of MAGI running on your personal machine.

# Background
The image runs nginx as a reverse proxy to port 8000 within the container.  MAGI listens on port 8000.  
The MAGI container requires links to two other docker containers for full functionality, mongo and a statistics server.
The statistics server can be found at [magi-images/statistics](https://github.com/johndashen/tree/magi-images/statistics).  

# Usage

For use with linked containers:
```
docker run -d --name mongo mongo
docker run -d --name enricher magi:stats-server
docker run --link mongo:mongo --link enricher:statserver -p --env-file=local.env 80:80 magi
```
Alternately, you can run start.sh from the host machine. 
In either case, the web application can then be viewed at localhost:80.  

#### Environment variables ####
There are various items that are configured in the local.env file.

The SITE_URL should contain the address used to access MAGI.

The MONGO_HOST and MONGO_PORT variables should contain the IP address and the port on which mongod listens (usually 27017).

Likewise, The ENRICHMENT_HOST and ENRICHMENT_PORT should contain the IP address and the port on which the statistics server listens (defaults to 8888).

#### Authentication ####

MAGI uses the Google OAuth2 protocol for authentication. To set up authentication on your own personal version of MAGI:

1. Visit the [Google OAuth2 documentation](https://developers.google.com/accounts/docs/OAuth2) and obtain credentials.  When you apply, list the exact URL of the site as the Javascript origin and the exact URL followed by "auth/google/callback"  
2. Fill in the following fields in local.env with the resulting data:

* GOOGLE_CLIENT_ID
* GOOGLE_CLIENT_SECRET 

If you do not set up authentication, you will not be able to use the `/upload` feature, and attempting to "Login via Google" will result in server errors. You will, however, be able to view public datasets and upload additional datasets to MongoDB from the command line.Annotations are done with Google OAuth2. 

# Loading data

The mongo TCP port can be probed with 
```
$ nc -zw2 mongo 27017 && echo "Mongo open"
```
within the container.

Public data associated with the TCGA project can be uploaded and placed onto the database with the load-TCGA-data.sh script within the container once the mongo instance is up and running.  

```
$ /home/melchior/magi/db/load-TCGA-data.sh
```

If you have private data, security can be provided with password protection by properly configuring nginx.  See [here](https://www.digitalocean.com/community/tutorials/how-to-set-up-http-authentication-with-nginx-on-ubuntu-12-10) for details.

# Stack
* Nginx
* Node.js
* Jquery
* Bower 
* Mongo
