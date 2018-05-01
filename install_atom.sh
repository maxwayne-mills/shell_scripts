#!/usr/bin/env bash

# Install Atom
cd /tmp
echo "Installing Atom"
curl -L https://atom.io/download/deb/ --progress-bar -o atom.deb
sudo dpkg -i atom.deb
rm atom.deb