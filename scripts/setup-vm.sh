#!/bin/bash

sudo apt install -y jq
wget https://gethstore.blob.core.windows.net/builds/geth-alltools-linux-amd64-1.7.3-4bb3c89d.tar.gz
tar xf geth-alltools-linux-amd64-1.7.3-4bb3c89d.tar.gz
sudo cp geth-alltools-linux-amd64-1.7.3-4bb3c89d/* /usr/local/bin

