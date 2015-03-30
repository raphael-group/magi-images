FROM python:2.7.9

MAINTAINER John Shen

RUN apt-get update && \
 apt-get install -y liblapack-dev \
 libblas-dev \
 gfortran \
 python-dev && \
 git clone https://github.com/raphael-group/magi-stat-server.git src

EXPOSE 8888 
# todo: replace with github once public server is available

CMD ["python", "/src/statserver.py", "--port", "8888"]

