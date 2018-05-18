resource "aws_instance" "ethereum_bootnode" {
  ami           = "${data.aws_ami.coreos.image_id}"
  instance_type = "t2.medium"
  subnet_id     = "${aws_subnet.ethereum.id}"
  key_name      = "${var.keyname}"
  tags {
    Name = "bootnode"
  }

  vpc_security_group_ids = [
    "${aws_security_group.allow_outbound.id}",
    "${aws_security_group.ssh.id}",
    "${aws_security_group.ethereum_bootnode.id}",
  ]

  provisioner "local-exec" {
    command = "scripts/generate_keys.sh"
  }

  provisioner "file" {
    source      = "keys/boot.key"
    destination = "/tmp/boot.key"
  }

  provisioner "file" {
    source      = "scripts/setup-vm.sh"
    destination = "/tmp/setup-vm.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "export ETHEREUM_IMAGE=${var.ethereum_image}",
      "chmod +x /tmp/setup-vm.sh",
      "/tmp/setup-vm.sh bootnode",
    ]
  }

  connection {
    type = "ssh"
    user = "core"
  }
}

resource "aws_instance" "ethereum_node" {
  ami           = "${data.aws_ami.coreos.image_id}"
  instance_type = "t2.medium"
  subnet_id     = "${aws_subnet.ethereum.id}"
  key_name      = "${var.keyname}"
  count         = 2
  depends_on    = ["aws_instance.ethereum_bootnode"]
  tags {
    Name = "miner"
  }

  vpc_security_group_ids = [
    "${aws_security_group.allow_outbound.id}",
    "${aws_security_group.ssh.id}",
    "${aws_security_group.ethereum_node.id}",
  ]

  provisioner "file" {
    source      = "files/default.conf"
    destination = "/tmp/default.conf"
  }

  provisioner "file" {
    source      = "keys/boot.pub"
    destination = "/tmp/boot.pub"
  }

  provisioner "file" {
    source      = "scripts/setup-vm.sh"
    destination = "/tmp/setup-vm.sh"
  }

  provisioner "file" {
    source      = "files/genesis.json"
    destination = "/tmp/genesis.json"
  }

  provisioner "remote-exec" {
    inline = [
      "export ETHEREUM_IMAGE=${var.ethereum_image}",
      "export ETHERBASE=${var.etherbase}",
      "export BOOTNODE_IP=${aws_instance.ethereum_bootnode.public_ip}",
      "chmod +x /tmp/setup-vm.sh",
      "/tmp/setup-vm.sh miner",
    ]
  }

  connection {
    type = "ssh"
    user = "core"
  }
}

resource "aws_instance" "bastion" {
  ami           = "${data.aws_ami.bionic.image_id}"
  instance_type = "t2.medium"
  subnet_id     = "${aws_subnet.ethereum.id}"
  key_name      = "${var.keyname}"
  depends_on    = ["aws_instance.ethereum_bootnode"]
  tags {
    Name = "bastion"
  }

  vpc_security_group_ids = [
    "${aws_security_group.allow_outbound.id}",
    "${aws_security_group.ssh.id}",
    "${aws_security_group.ethereum_node.id}",
  ]

  provisioner "local-exec" {
    command = "scripts/generate_account.sh"
  }

  provisioner "file" {
    source      = "scripts/setup-vm.sh"
    destination = "/tmp/setup-vm.sh"
  }

  provisioner "file" {
    source      = "keys/boot.pub"
    destination = "/tmp/boot.pub"
  }

  provisioner "file" {
    source      = "files/genesis.json"
    destination = "/tmp/genesis.json"
  }

  provisioner "file" {
    source      = "keystore"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "export ETHEREUM_IMAGE=${var.ethereum_image}",
      "export ETHERBASE=${var.etherbase}",
      "export BOOTNODE_IP=${aws_instance.ethereum_bootnode.public_ip}",
      "chmod +x /tmp/setup-vm.sh",
      "/tmp/setup-vm.sh bastion",
    ]
  }

  connection {
    type = "ssh"
    user = "ubuntu"
  }
}
