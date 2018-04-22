#!/usr/bin/env bash

web_dir=/var/www
domain_name=$1
git_repo=$2

# Delete exisiting domain directory
rm -rf  $web_dir/$domain_name

# clone directory
git clone --depth=1 $git_repo $web_dir/$domain_name

# change ownership to web www-data
chown -R www-data:www-data $web_dir/$domain_name

# change permission
chmod 0755 $web_dir/$domain_name/*
