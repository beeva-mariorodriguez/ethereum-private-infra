#!/bin/bash

function run_bootnode {
    privkey=$(cat /tmp/boot.key)
    docker container run \
        --detach \
        --name bootnode \
        --net host \
        --restart always \
        "${ETHEREUM_IMAGE}" \
        bootnode -nodekeyhex "${privkey}"
}

function run_miner {
    public_ip=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
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
             -minerthreads 2 \
             -etherbase "0x${ETHERBASE}" \
             -rpc \
             -nat "extip:${public_ip}" \
             -gasprice 0
}

function install_nodejs_truffle {
    curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
    sudo apt-get install -y nodejs
    sudo npm install -g truffle
}

function install_ethereum {
    sudo add-apt-repository -y ppa:ethereum/ethereum
    sudo apt-get update
    sudo apt-get install -y ethereum
}

case $1 in
    "bootnode")
        run_bootnode
        ;;
    "miner")
        run_miner
        ;;
    "bastion")
        sudo apt-get update
        sudo apt-get install -y git
        install_nodejs_truffle
        install_ethereum
        ;;
esac

