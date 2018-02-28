# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
	config.vm.box = "debian/stretch64"
  config.vm.box_check_update = false

	(1..4).each do |i|
		config.vm.define "n#{i}" do |node|
      node.vm.provider "virtualbox" do |vb|
        vb.gui = false
        vb.memory = "1024"
      end
      node.vm.provision "file", source: "scripts/setup-vm.sh", destination: "/tmp/setup-vm.sh"
      node.vm.provision "file", source: "files/genesis.json", destination: "/tmp/genesis.json"
      node.vm.provision "shell", inline: <<-SHELL
        chmod +x /tmp/setup-vm.sh
        /tmp/setup-vm.sh
      SHELL
    end
  end
end
