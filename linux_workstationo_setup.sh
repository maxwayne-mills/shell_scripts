#!/usr/bin/env bash

# Exit if any errors
clear
set -e

echo updating and upgrading packages
sudo apt-get -y update
sudo apt-get -y upgrade

# Install Applications
# Gnome Control Center
sudo apt install gnome-control-center gnome-online-accounts
sudo apt-get -y install tree
sudo apt-get -y install rsync
sudo apt-get -y install curl
sudo apt-get -y install git
sudo apt-get -y install screen
sudo apt-get -y install golang

# Creature compfort stuff
# Install aliases
cd /tmp
git clone https://github.com/maxwayne-mills/workstation.git
cd workstation/system-setup
cp bash_aliases ~/.bash_aliases
cp gitconfig ~/.gitconfig

# Move ubuntu toolbar to the bottom
gsettings set com.canonical.Unity.Launcher launcher-position Bottom

cd /tmp
git clone https://github.com/maxwayne-mills/scripts.git
cd /tmp/scripts/shell

cp show_wireless.sh ~/bin
cp manage-vm.sh ~/bin
cp manage_virt.sh ~/bin
cp backup_to_usb_drives.sh ~/bin

# Install envchain
./install_envchain.sh

# Install Ansible
./install_ansible.sh

# Install Packer
./install_packer.sh

# Install Terraform
./install_terraform.sh

# Install vagrant
./install_vagrant.sh

# Install Vault
./install_vault.sh

#Install Dropbox
./install_dropbox.sh

# Install grive
./install_grive.sh

# Install atom
./install_atom.sh

# Install slack
./install_slack.sh

# Install passsword gorilla
curl -L http://ftp.us.debian.org/debian/pool/main/p/password-gorilla/password-gorilla_1.5.3.7-1_all.deb --progress-bar -o password-gorilla.deb
sudo dpkg -i password-gorilla.deb

echo "Finished"
