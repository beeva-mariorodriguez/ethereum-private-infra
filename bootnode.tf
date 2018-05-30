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

resource "aws_security_group" "ethereum_bootnode" {
  name   = "bootnode"
  vpc_id = "${aws_vpc.ethereum.id}"

  ingress {
    from_port       = 30301
    to_port         = 30301
    protocol        = "udp"
    security_groups = ["${aws_security_group.ethereum_node.id}"]
  }
}
