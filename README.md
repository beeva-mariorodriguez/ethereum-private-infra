# private ethereum network

## requirements
* geth tools (https://geth.ethereum.org/downloads/)
* terraform

## instructions

0. backup and delete your .ethereum if you have real ethereum accounts!
1. [optional] create a local ethereum account to store mining profits
    ```
    geth init files/genesis.json
    geth account new
    ```
2. use terraform to deploy infrastructure 
    * install terraform
    * run terraform:
        ```
        terraform init
        terraform plan
        terraform apply -var 'keyname=YOUR AWS KEYNAME' -var 'etherbase=ETHEREUM_ADDRESS'
        ```
3. local miner
    * initialize using genesis.json
        ```bash
        geth init files/genesis.json
        ```
    * create ethereum account to store mining profits
        ```bash
        geth account new
        ```
    * bootnode address
        ```bash
        BOOTNODE_ADDRESS="enode://$(cat keys/boot.pub)@$(terraform output bootnode_public_ip):30301"
        echo $BOOTNODE_ADDRESS
        ```
    * run miner
        ```bash
        geth -networkid $(jq .config.chainId < files/genesis.json) \
             -maxpeers 128 \
             -bootnodes "${BOOTNODE_ADDRESS}" \
             -mine -minerthreads=1 \
             -etherbase=0x$(jq -r .address < ~/.ethereum/keystore/UTC*) \
             -rpc
        ```
    * attach to console: ``geth attach``
    * install and run mist: https://github.com/ethereum/mist

