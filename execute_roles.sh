#!/bin/bash

play=$(which ansible-playbook)
domain=$1
git_repo=$2

$play ansible/playbooks/publish_website.yml -e "server_name=srv1 domain_name=$domain repo_name=$git_repo" -vv
