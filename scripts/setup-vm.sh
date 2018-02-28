#!/bin/bash

sudo apt-get install -y jq
wget https://gethstore.blob.core.windows.net/builds/geth-alltools-linux-amd64-1.8.1-1e67410e.tar.gz
tar xf geth-alltools-linux-amd64-1.8.1-1e67410e.tar.gz
sudo cp geth-alltools-linux-amd64-1.8.1-1e67410e/* /usr/local/bin

