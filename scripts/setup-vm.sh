#!/bin/bash

function run_bootnode {
    privkey=$(cat /tmp/boot.key)
    sudo docker container run \
        --detach \
        --name bootnode \
        --net host \
        --restart always \
        "${ETHEREUM_IMAGE}" \
        bootnode -nodekeyhex "${privkey}"
}

function run_nginx {
    sudo mkdir -p /etc/nginx/conf.d
    sudo cp /tmp/default.conf /etc/nginx/conf.d/
    sudo docker container run \
        --detach \
        --name nginx \
        --net host \
        --volume /etc/nginx/conf.d:/etc/nginx/conf.d \
        --volume /srv:/srv \
        --restart always \
        nginx:stable
}

function init_geth_container {
    # initialize geth using genesis.json, .ethereum files stored at volume dotethereum
    sudo docker container run \
        --name gethinit \
        --net host \
        --rm \
        --volume /tmp/genesis.json:/genesis.json \
        --volume dotethereum:/root/.ethereum \
        "${ETHEREUM_IMAGE}" \
        geth init /genesis.json    
}

function add_eth_account {
    # add private keys @ ./keystore to the dotethereum volume
    sudo docker container run \
        --name importaccount \
        --net host \
        --rm \
        --volume /tmp/keystore:/keystore \
        --volume dotethereum:/root/.ethereum \
        "${ETHEREUM_IMAGE}" \
        cp -av /keystore /root/.ethereum
}

function run_miner {
    private_ip=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
    pubkey=$(cat /tmp/boot.pub)
    networkid=$(jq .config.chainId < /tmp/genesis.json)

    # run the miner, 
    sudo docker container run \
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
             -gasprice 0
}

function run_light_client {
    private_ip=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
    pubkey=$(cat /tmp/boot.pub)
    networkid=$(jq .config.chainId < /tmp/genesis.json)

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
             -rpccorsdomain '*' \
             -rpc \
             -rpcapi "db,eth,net,web3,personal"
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

function setup_coreos {
    sudo systemctl enable docker
    echo "REBOOT_STRATEGY=off" | sudo tee -a /etc/coreos/update.conf
}

function setup_ubuntu {
    sudo apt-get update
    sudo apt-get install -y git jq
    install_docker
}

case $1 in
    "bootnode")
        setup_coreos
        run_bootnode
        ;;
    "miner")
        setup_coreos
        init_geth_container
        run_miner
        ;;
    "proxy")
        setup_coreos
        init_geth_container
        run_light_client
        run_nginx
        ;;
    "bastion")
        setup_ubuntu
        install_nodejs_truffle
        install_ethereum
        git clone https://github.com/beeva-mariorodriguez/innovation_day_token
        init_geth_container
        add_eth_account
        run_light_client
        sudo mkdir -p /srv/contracts
        run_nginx
        ;;
esac
