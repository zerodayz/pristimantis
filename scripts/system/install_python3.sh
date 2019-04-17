#!/bin/bash

cd /tmp
echo "Downloading python 3"
wget https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tar.xz
echo "Extracting python3"
tar -xf Python-3.7.3.tar.xz
cd Python-3.7.3
echo "Configuring python3"
./configure --enable-optimizations
echo "Installing python3"
make altinstall                     
echo "Making symlink"
ln -s /usr/local/bin/python3.7 /usr/bin/python3
