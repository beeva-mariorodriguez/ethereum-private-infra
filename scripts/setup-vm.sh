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

function run_rpc_revproxy {
    sudo mkdir -p /etc/nginx/conf.d
    sudo mv /tmp/default.conf /etc/nginx/conf.d/
    docker container run \
        --detach \
        --name proxy \
        --net host \
        --volume /etc/nginx/conf.d:/etc/nginx/conf.d \
        --restart always \
        nginx:stable
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
             -rpcapi "db,eth,net,web3,personal" \
             -nat "extip:${public_ip}" \
             -rpccorsdomain '*' \
             -gasprice 0
}

function run_light_client {
    public_ip=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
    pubkey=$(cat /tmp/boot.pub)
    networkid=$(jq .config.chainId < /tmp/genesis.json)
    # initialize geth using genesis.json, .ethereum files stored at volume dotethereum
    sudo docker container run \
        --name gethinit \
        --net host \
        --rm \
        --volume /tmp/genesis.json:/genesis.json \
        --volume dotethereum:/root/.ethereum \
        "${ETHEREUM_IMAGE}" \
        geth init /genesis.json

    sudo docker container run \
        --name importaccount \
        --net host \
        --rm \
        --volume /tmp/keystore:/keystore \
        --volume dotethereum:/root/.ethereum \
        "${ETHEREUM_IMAGE}" \
        cp -av /keystore /root/.ethereum

    # run the client
    sudo docker container run \
        --detach \
        --name geth \
        --net host \
        --restart always \
        --volume dotethereum:/root/.ethereum \
        "${ETHEREUM_IMAGE}" \
        geth -networkid "${networkid}" \
             -maxpeers 128 \
             -bootnodes "enode://${pubkey}@${BOOTNODE_IP}:30301" \
             -rpc
}

function install_docker {
    sudo apt-get remove -y docker docker-engine docker.io
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       test"
    sudo apt-get update
    sudo apt-get install -y docker-ce
    sudo usermod -a -G docker ubuntu
}

function install_nodejs_truffle {
    curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
    sudo apt-get install -y nodejs
    sudo npm install -g truffle
    sudo npm install -g solium
}

function install_ethereum {
    sudo add-apt-repository -y ppa:ethereum/ethereum
    sudo apt-get update
    sudo apt-get install -y ethereum
}

case $1 in
    "bootnode")
        echo "REBOOT_STRATEGY=off" | sudo tee -a /etc/coreos/update.conf
        run_bootnode
        ;;
    "miner")
        echo "REBOOT_STRATEGY=off" | sudo tee -a /etc/coreos/update.conf
        run_miner
        run_rpc_revproxy
        ;;
    "bastion")
        sudo apt-get update
        sudo apt-get install -y git jq
        install_docker
        install_nodejs_truffle
        install_ethereum
        git clone https://github.com/beeva-mariorodriguez/innovation_day_token
        run_light_client
        ;;
esac

