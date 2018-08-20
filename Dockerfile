FROM ubuntu:latest

WORKDIR //tests
RUN mkdir -p /tests/roles/
RUN apt-get update \
&& apt-get -y install python curl python-apt aptitude

RUN curl "https://bootstrap.pypa.io/2.6/get-pip.py" > /usr/bin/get-pip.py \
&& python /usr/bin/get-pip.py \
&& pip install pip --upgrade \
&& pip install ansible ansible-lint --upgrade

RUN echo "deb http://packages.cloud.google.com/apt cloud-sdk-xenial main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
&& curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
&& apt-get update

RUN echo localhost > /tests/inventory \
&& echo "---" > /tests/site.yml \
&& echo "- hosts: localhost" >> /tests/site.yml \
&& echo "  remote_user: root" >> /tests/site.yml \
&& echo "  roles:" >> /tests/site.yml \
&& echo "    - test" >> /tests/site.yml
