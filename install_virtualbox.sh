#!/usr/bin/env bash

app_url="https://download.virtualbox.org/virtualbox/5.2.10/virtualbox-5.2_5.2.10-122088~Ubuntu~xenial_i386.deb"

#curl -O $app_url
#sudo dpkg -i virtualbox-5.2_5.2.10-122088~Ubuntu~xenial_i386.deb

echo ""
echo "Adding virtualbox key"
sudo apt-key add https://www.virtualbox.org/download/oracle_vbox_2016.asc

echo ""
echo "Adding Virtualbox source to repository"
sudo apt-add-repository "deb https://download.virtualbox.org/virtualbox/debian xenial contrib"

echo ""
echo "Updating system"
sudo apt-get update

echo ""
echo "Installing Virtualbox"
sudo apt-get -y install lynx virtualbox-5.2 --allow-unauthenticated

## Sign kernel modules
lynx https://askubuntu.com/questions/760671/could-not-load-vboxdrv-after-upgrade-to-ubuntu-16-04-and-i-want-to-keep-secur/768310#768310
