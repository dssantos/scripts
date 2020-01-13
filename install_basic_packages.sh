#!/bin/bash
# Install basics packages after reinstall debian based systems

while read package; do
  sudo apt-get -y install "$package"
done <packages.txt
