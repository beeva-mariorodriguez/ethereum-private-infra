#!/bin/bash

function install_docker {
	sudo apt-get remove -y docker docker-engine docker.io
	sudo apt-get install -y \
		apt-transport-https \
		ca-certificates \
		curl \
		gnupg2 \
		software-properties-common
	curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
        $(lsb_release -cs) \
        stable"
	sudo apt-get update
	sudo apt-get install -y docker-ce
}

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

function run_miner {
    public_ip=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
    pubkey=$(cat /tmp/boot.pub)
    networkid=$(jq .config.chainId < /tmp/genesis.json)
    # initialize geth using genesis.json, .ethereum files stored at volume dotethereum
    sudo docker container run \
        --name gethinit \
        --net host \
        --rm \
        --volume /tmp/genesis.json:/genesis.json \
        --volume dotethereum:/.ethereum \
        "${ETHEREUM_IMAGE}" \
        geth init /genesis.json

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
             -minerthreads 1 \
             -etherbase "${ETHERBASE}" \
             -rpc \
             -nat "extip:${public_ip}"
}

case $1 in
    "bootnode")
        install_docker
        run_bootnode
        ;;
    "miner")
        install_docker
        sudo apt-get install -y jq
        run_miner
        ;;
esac

