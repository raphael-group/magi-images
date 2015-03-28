FROM python:2.7.9

MAINTAINER John Shen

RUN apt-get update && \
 apt-get install -y liblapack-dev \
 libblas-dev \
 gfortran \
 python-dev  

#RUN pip install tornado numpy scipy scikit-learn requests

EXPOSE 8888
# todo: replace with github once public server is available
COPY src /src

#CMD ["python", "/src/statserver.py", "--port", "8888"]

