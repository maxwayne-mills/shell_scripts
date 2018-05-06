#!/usr/bin/env bash

## Install dropbox
# link: https://www.dropbox.com/install-linux
arch=$(uname -a | awk 'BEGIN {fs=" "};{print $12}')
if [ "$arch" = "x86_64" ];then
	dropboxlink=https://www.dropbox.com/download?plat=lnx.x86_64
	cd ~ && wget -O - $dropboxlink | tar xzvf -

	echo "Starting dropbox"
	~/.dropbox-dist/dropboxd &
	curl -L  https://www.dropbox.com/download?dl=packages/dropbox.py --progress-bar -o dropbox.py
	mv dropbox.py ~/bin
	chmod +x ~/bin/dropbox.py
else
	droplink=https://www.dropbox.com/download?plat=lnx.x86_64
	cd ~ && wget -O - $droplink | tar xzvf -

	echo "Starting dropbox"
	~/.dropbox-dist/dropboxd &
	curl -L  https://www.dropbox.com/download?dl=packages/dropbox.py --progress-bar -o dropbox.py
	mv dropbox.py ~/bin
	chmod +x ~/bin/dropbox.py
fi