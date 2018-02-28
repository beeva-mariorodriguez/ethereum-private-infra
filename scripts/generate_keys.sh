#!/bin/bash
if [[ ! -f files/boot.key ]]
then
    mkdir -p keys
    bootnode -genkey keys/boot.key
    bootnode -nodekey keys/boot.key -writeaddress > keys/boot.pub
fi

