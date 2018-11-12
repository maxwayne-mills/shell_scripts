#!/bin/bash

play=$(which ansible-playbook)
server=$1
domain=$2
git_repo=$3

$play ~/github/ansible/playbooks/publish_website.yml -i ~/.ansible/inventory -e "server_name=$server domain_name=$domain repo_name=$git_repo" -vv
