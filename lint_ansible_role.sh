#!/bin/bash
ansible-lint -p -R -r /ansible_lint_rules/rules/ /tests/site.yml
