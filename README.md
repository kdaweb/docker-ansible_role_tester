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

There were a number of existing projects on Docker Hub that were really close to what I needed right from the start, but none really met my exact needs or build process.  For example, one project on Docker Hub started with Ubutntu and installed Python, pip, Ansible, etc. and to use it, you write your own Dockerfile to COPY files and run ansible-playbook to do the check.  However, I didn't need the image with the tested playbook afterwards and the base image didn't have some of the tools I needed (e.g., python-apt, aptitude, etc.) for some of the roles I was testing.

So, I put together my own image -- the one who's README.md you're reading right now.

## Details
This Dockerfile includes:
- aptitude
- curl
- python
- pip
- python-apt
- ansible
- ansible-lint
- the Google repository for the Google Cloud SDK
- an Ansible inventory and playbook

### Ansible Inventory and Playbook
The inventory and playbook are designed to test an Ansible role located at ```/tests/roles/test``` with the reasoning that the role will be mounted to that location at Docker runtime (i.e., the '-v' flag).

The inventory is located at ```/tests/inventory``` and looks like this:

```
localhost
```

The playbook is located at ```/tests/site.yml``` and looks like this:

```
- hosts: localhost
  remote_user: root
  roles:
    - test
```

### Repository Layout
The reasoning behind this project is that each Ansible role is a separate repository and that these repositories are added as submodules to projects as they're needed.  Therefore, the root of the repository includes the directories created by ```ansible-galaxy --init```:

```
.
├── defaults
│   └── main.yml
├── handlers
│   └── main.yml
├── Jenkinsfile
├── meta
│   └── main.yml
├── README.md
├── tasks
│   └── main.yml
├── tests
│   ├── inventory
│   └── test.yml
└── vars
    └── main.yml
```

#### Including a Role in a Project
To include this role in a project, use ```git submodule add``` to add the repository into the project's "roles" directory.

```
cd /path/to/project/root
git submodule add 'repository URL' roles/rolename
```

To bring in any updates, use ```git submodule update``` from the project's root directory:

```
cd /path/to/project/root
git submodule update --remote --recursive
```

## Running a Test
### Shell
To run a test, use ```docker run``` with the ```ansible-playbook``` command.  Again, the reasoning is that the role to be tested will be mounted as a volume at ```/tests/roles/test```; therefore, ```docker``` should be invoked with -v putting the current working directory at /tests/roles/test so that when ```ansible-playbook``` is run, it tests the current working directory.  Consider the following:

```shell
docker run -v $(pwd):/tests/roles/test wesleydean/playbooktester ansible-playbook -i /tests/inventory --check --connection=local /tests/site.yml
```

### Jenkinsfile
A Jenkins Pipeline to further automate the role testing is also very straight-forward.  To set this up, include the following contents in a file named ```Jenkinsfile``` which should be added to the repository.  Here's an example:

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

