FROM ubuntu:latest

WORKDIR /tests
RUN mkdir -p /tests/roles/

# pull down the latest package lists
RUN apt-get update

# install basic packages we'll need later
RUN apt-get -fy install curl aptitude git

# install Python-related packages
RUN apt-get -fy install python python-apt python-mysqldb

# download and install the latest, greatest Python packages using pip
RUN curl "https://bootstrap.pypa.io/2.6/get-pip.py" > /usr/bin/get-pip.py \
&& python /usr/bin/get-pip.py \
&& pip install pip --upgrade \
&& pip install  ansible ansible-lint --upgrade

# add repo for installing Google Cloud SDK packages
RUN echo "deb http://packages.cloud.google.com/apt cloud-sdk-xenial main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
&& curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
&& apt-get update

# add supplementary ansible-lint rules
RUN git clone https://github.com/tsukinowasha/ansible-lint-rules.git /ansible_lint_rules

# copy over our testing scaffolding and convenience scripts
COPY test_ansible_role.sh /bin/test_ansible_role.sh
COPY lint_ansible_role.sh /bin/lint_ansible_role.sh
COPY inventory /tests/inventory
COPY site.yml /tests/site.yml
COPY ansible-lint.yml /ansible-lint.yml

# make sure the convenience scripts are executable
RUN chmod 755 /bin/test_ansible_role.sh /bin/lint_ansible_role.sh
