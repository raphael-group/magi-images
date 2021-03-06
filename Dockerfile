FROM node 

MAINTAINER John Shen

# allow a TCP port tunnel to the container
EXPOSE 80

# add some utils: adduser for correct mongod install
# and netcat-traditional to wait on a port to open
RUN apt-get update && apt-get install -y \
 apt-transport-https \ 
 netcat-traditional \
 wget \
 sudo \
 lsof \
 vim 

# add a new user with passwordless sudo
RUN adduser --disabled-password --gecos 'Magi Administrator' melchior && \
 adduser melchior sudo && \
 echo "melchior ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/01-melchior

# update sources & install some basics; 
# python is required for npm install
RUN apt-get update && apt-get install -y \
  nginx \
  apache2-utils 

# switch to magi user
USER melchior 

# clone versioned magi build from git
RUN cd ~ && git clone https://github.com/raphael-group/magi.git magi && \
 cd ~melchior/magi && git checkout tags/v0.0.2

# we should 
# add npm packages for magi
# git config url is for bower install - for some reason it stalls out on some repos
# better to change the bowerirc
RUN cd ~melchior/magi && git config --global url."https://".insteadOf git:// && \
 npm install && \
 sudo npm -g install forever 

# clone gd3
RUN cd ~melchior/magi/public/components/ && \
  git clone https://github.com/raphael-group/gd3

# copy the loading script
COPY load-TCGA-data.sh /home/melchior/magi/db/

# copy the nginx conf file
COPY magi-site.conf /etc/nginx/conf.d/

# copy the startup script and run it 
COPY run-server.sh /home/melchior/

CMD ~melchior/run-server.sh
