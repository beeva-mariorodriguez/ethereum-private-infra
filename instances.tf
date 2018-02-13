resource "aws_instance" "ethereum_bootnode" {
  ami           = "${data.aws_ami.stretch.image_id}"
  instance_type = "t2.medium"
  subnet_id     = "${aws_subnet.ethereum.id}"
  key_name      = "mrc"

  vpc_security_group_ids = [
    "${aws_security_group.allow_outbound.id}",
    "${aws_security_group.ssh.id}",
    "${aws_security_group.ethereum_bootnode.id}",
  ]

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
      "chmod +x /tmp/setup-vm.sh",
      "/tmp/setup-vm.sh bootnode",
    ]
  }
}

resource "aws_instance" "ethereum_node" {
  ami           = "${data.aws_ami.stretch.image_id}"
  instance_type = "t2.medium"
  subnet_id     = "${aws_subnet.ethereum.id}"
  key_name      = "mrc"
  count         = 2

  vpc_security_group_ids = [
    "${aws_security_group.allow_outbound.id}",
    "${aws_security_group.ssh.id}",
    "${aws_security_group.ethereum_node.id}",
  ]

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
      "chmod +x /tmp/setup-vm.sh",
      "/tmp/setup-vm.sh miner",
    ]
  }
}
