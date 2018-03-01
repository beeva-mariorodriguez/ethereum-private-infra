#!/bin/bash

function install_docker {
    sudo apt-get remove -y docker docker-engine docker.io
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg2 \
        software-properties-common \
        jq
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
        $(lsb_release -cs) \
        stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce
    sudo adduser vagrant docker
}

function run_miner {
    pubkey=$(cat /tmp/boot.pub)
    networkid=$(jq .config.chainId < /tmp/genesis.json)
    # initialize geth using genesis.json, .ethereum files stored at volume dotethereum
    docker container run \
        --name gethinit \
        --net host \
        --rm \
        --volume /tmp/genesis.json:/genesis.json \
        --volume dotethereum:/root/.ethereum \
        "${ETHEREUM_IMAGE}" \
        geth init /genesis.json

    # run the miner, 
    docker container run \
        --detach \
        --name miner \
        --net host \
        --restart always \
        --volume dotethereum:/root/.ethereum \
        "${ETHEREUM_IMAGE}" \
        geth -networkid "${networkid}" \
             -maxpeers 128 \
             -bootnodes "enode://${pubkey}@${BOOTNODE_IP}:30301" \
             -mine \
             -minerthreads 1 \
             -etherbase "0x${ETHERBASE}" \
             -rpc
}

case $1 in
    "docker")
        install_docker
        ;;
    "miner")
        run_miner
        ;;
esac

