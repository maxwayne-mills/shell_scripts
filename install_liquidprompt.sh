#!/usr/bin/env bash

if [ -d /tmp/liquidprompt ]; then rm -rf /tmp/liquidprompt; fi

git_script_home=~/github
# Liquid-prompt requirement
sudo apt-get -y install acpi

# Install liquid-prompt
cd /tmp
git clone https://github.com/nojhan/liquidprompt.git

if [ -d $git_script_home ];then
	cp -Rnpv /tmp/liquidprompt $git_script_home
	source $git_script_home/liquidprompt/liquidprompt
else
	mkdir $git_script_home
	cp -Rnpv /tmp/liquidprompt $git_script_home
fi

# Set permissions
sudo chown -R cmills:cmills $git_script_home/liquidprompt
#source $git_script_home/liquidprompt/liquidprompt

## Update bashrc
echo "if [ -f $HOME/github/liquidprompt/liquidprompt ]; then source ~/github/liquidprompt/liquidprompt; fi" >> $HOME/.bashrc