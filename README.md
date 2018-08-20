# docker-playbooktester
## Introduction
This tool is used to check Ansible roles using the --check flag to the ansible-playbook command.  The Dockerfile associated with this project is very simple and straight-forward -- it's based on the ':latest' Ubuntu image, adds the latest python, pip, and ansible, as well as several supporting packages (curl, python-apt, aptitude).  Additionally, it adds the Google Cloud SDK's repo so that the aforementioned can be installed and tested in --check mode.

## Background
Initially, when I started with Ansible, I found bringing in automated tests to be slightly counter-intuitive.  At first, I started with making sure the YAML would parse properly -- and this was good -- but there were a variety of Ansible-specific issues that just slipped through the cracks.  Then, I stepped up to using ansible-playbook's --syntax-check and this caught even more issues -- and this was also good.  However, things like undefined variables, typos in variable names, etc. wouldn't get caught.  So, I moved to using ansible-playbook --check and this caught even more issues.

Unfortunately, the model I was using -- each Ansible role would go in its own repository which would be added to projects as submodules -- didn't align with my testing strategy in a way that pleased me.

As each role (repository) was initialized with ansible-galaxy (with the --init flag), there was this directory called 'tests' that had an inventory and playbook that was perfect for making the tests work and it was already setup for me so I just needed to figure out the "syntactical sugar" to make it go.

To make a long story short, the command to use the generated testing scaffolding, use:

```shell
ANSIBLE_ROLES_PATH=.. ansible-playbook --check tests/test.yml
```

So, I added this to my testing processes and it was good.

My concern, however, was that a step or task that Ansible took would break out and do something to the underlying system or if things were setup as needed to run the tests on some other platform.

The short answer was Docker.

There were a number of existing projects on Docker Hub that were really close to what I needed right from the start, but none really met my exact needs or build process.  For example, one project on Docker Hub started with Ubutntu and installed Python, pip, Ansible, etc. and to use it, you write your own Dockerfile to COPY files and run ansible-playbook to do the check.



```shell
docker run -v $(pwd):/tests/roles/test wesleydean/playbooktester ansible-playbook -i /tests/inventory --check --connection=local /tests/site.yml
```



```Jenkinsfile
pipeline {
  agent any

  stages {
    stage('Build') {
      steps {
        sh 'docker run -v $(pwd):/tests/roles/test wesleydean/playbooktester ansible-playbook -i /tests/inventory --check --connection=local /tests/site.yml'
      }
    }
  }
}
```

