FROM ubuntu:latest

WORKDIR /playbooktester
RUN mkdir -p /playbooktester/roles/

RUN apt-get update \
&& apt-get -y install python curl python-apt \
&& curl "https://bootstrap.pypa.io/2.6/get-pip.py" > /usr/bin/get-pip.py \
&& python /usr/bin/get-pip.py \
&& pip install pip --upgrade \
&& pip install ansible ansible-lint --upgrade

