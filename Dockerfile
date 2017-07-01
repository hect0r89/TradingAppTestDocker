# Copyright 2013 Thatcher Peskens
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:16.04

MAINTAINER Dockerfiles

# Install required packages and remove the apt packages cache when done.

RUN apt-get update && \
    apt-get upgrade -y && \ 	
    apt-get install -y \
	git \
	python3 \
	python3-dev \
	python3-setuptools \
	python3-pip \
	nginx \
        nodejs \
        npm \
	supervisor \
	sqlite3 && \
	pip3 install -U pip setuptools && \
   rm -rf /var/lib/apt/lists/*

# install uwsgi now because it takes a little while
RUN pip3 install uwsgi

# setup all the configfiles
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
COPY nginx-app.conf /etc/nginx/sites-available/default
COPY supervisor-app.conf /etc/supervisor/conf.d/

# clone repositories server and client. Install requirements and migrations
RUN git clone https://github.com/hect0r89/TradingAppTestServer.git /home/docker/code/app/
RUN ls /home/docker/code/app/
RUN pip3 install -r /home/docker/code/app/requirements.txt
RUN python3 /home/docker/code/app/manage.py migrate
RUN git clone https://github.com/hect0r89/TradingAppTestClient.git /home/docker/code/app/static/
RUN cd /home/docker/code/app/static/ && git pull
RUN chmod -R 777 /home/docker/code/app/static/
RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN cd /home/docker/code/app/static/ &&  npm install --unsafe-perm

# add (the rest of) our code
COPY . /home/docker/code/

EXPOSE 80
CMD ["supervisord", "-n"]
