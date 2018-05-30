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
    "${aws_security_group.ethereum_bastion.id}",
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

  provisioner "file" {
    source      = "files/bastion.conf"
    destination = "/tmp/default.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "export ETHEREUM_IMAGE=${var.ethereum_image}",
      "export ETHERBASE=${var.etherbase}",
      "export BOOTNODE_IP=${aws_instance.ethereum_bootnode.private_ip}",
      "chmod +x /tmp/setup-vm.sh",
      "/tmp/setup-vm.sh bastion",
    ]
  }

  connection {
    type = "ssh"
    user = "ubuntu"
  }
}

resource "aws_security_group" "ethereum_bastion" {
  name   = "ethereum_bastion"
  vpc_id = "${aws_vpc.ethereum.id}"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
