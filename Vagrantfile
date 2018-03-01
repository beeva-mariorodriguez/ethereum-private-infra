# -*- mode: ruby -*-
# vi: set ft=ruby :

ethereum_image = %x(terraform output ethereum_image)
etherbase = %x(terraform output etherbase)
bootnode_public_ip = %x(terraform output bootnode_public_ip)

Vagrant.configure("2") do |config|
	config.vm.box = "debian/stretch64"
  config.vm.box_check_update = false

	(1..4).each do |i|
		config.vm.define "n#{i}" do |node|
      node.vm.provider "virtualbox" do |vb|
        vb.gui = false
        vb.memory = "1024"
      end
      node.vm.provision "file", source: "scripts/setup-vagrant.sh", destination: "/tmp/setup-vagrant.sh"
      node.vm.provision "file", source: "files/genesis.json", destination: "/tmp/genesis.json"
      node.vm.provision "file", source: "keys/boot.pub", destination: "/tmp/boot.pub"
      node.vm.provision "shell", inline: <<-SHELL
        export ETHEREUM_IMAGE=#{ethereum_image}
        export ETHERBASE=#{etherbase}
        export BOOTNODE_IP=#{bootnode_public_ip}
        chmod +x /tmp/setup-vm.sh
        /tmp/setup-vagrant.sh docker
        /tmp/setup-vagrant.sh miner
      SHELL
    end
  end
end
