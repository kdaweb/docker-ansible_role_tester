#!/bin/bash
ansible-playbook -i /tests/inventory --check --connection=local /tests/site.yml
